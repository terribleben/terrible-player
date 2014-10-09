//
//  TBPLibraryModel.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLibraryModel.h"
#import "NSString+TBP.h"
#import "TBPLibraryItem.h"

#import <MediaPlayer/MediaPlayer.h>

NSString * const kTBPLibraryModelDidChangeNotification = @"TBPLibraryModelDidChangeNotification";

@interface TBPLibraryModel ()

- (void) recompute;
- (void) onNowPlayingItemChanged: (NSNotification *)notification;
- (void) onPlaybackStateChanged: (NSNotification *)notification;

@property (nonatomic, strong) NSMutableOrderedSet *artists;
@property (nonatomic, strong) NSMutableOrderedSet *albums;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

/**
 *  Artist persistent id => albums
 */
@property (nonatomic, strong) NSMutableDictionary *albumsByArtist;

@end

@implementation TBPLibraryModel

+ (TBPLibraryModel *) sharedInstance
{
    static TBPLibraryModel *theModel = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theModel) {
            theModel = [[TBPLibraryModel alloc] init];
        }
    });
    return theModel;
}

- (id) init
{
    if (self = [super init]) {
        self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        [_musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [_musicPlayer setRepeatMode: MPMusicRepeatModeNone];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onNowPlayingItemChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(onPlaybackStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
        [_musicPlayer beginGeneratingPlaybackNotifications];
        
        [self recompute];
    }
    return self;
}

- (void) dealloc
{
    // [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_musicPlayer endGeneratingPlaybackNotifications];
}


#pragma mark external methods

- (TBPLibraryItem *)nowPlayingItem
{
    MPMediaItem *nowPlaying = [_musicPlayer nowPlayingItem];
    if (nowPlaying)
        return [TBPLibraryItem itemWithMediaItem:nowPlaying grouping:MPMediaGroupingTitle];
    return nil;
}

- (BOOL) isPlaying
{
    return (_musicPlayer.playbackState == MPMusicPlaybackStatePlaying);
}

- (CGFloat)nowPlayingProgress
{
    MPMediaItem *nowPlaying = [_musicPlayer nowPlayingItem];
    NSTimeInterval nowPlayingDuration = [[nowPlaying valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    return (_musicPlayer.currentPlaybackTime / nowPlayingDuration);
}

- (NSOrderedSet *)albumsForArtistWithId:(NSNumber *)artistPersistentId
{
    if (_albumsByArtist)
        return [_albumsByArtist objectForKey:artistPersistentId];
    return nil;
}

- (NSOrderedSet *)tracksForAlbumWithId:(NSNumber *)albumPersistentId
{
    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:albumPersistentId
                                                                                forProperty:MPMediaItemPropertyAlbumPersistentID];
    MPMediaQuery *albumQuery = [[MPMediaQuery alloc] init];
    [albumQuery addFilterPredicate:albumPredicate];
    // [albumQuery setGroupingType:MPMediaGroupingTitle];
    
    NSMutableOrderedSet *tracks = [NSMutableOrderedSet orderedSet];
    for (MPMediaItem *item in albumQuery.items) {
        TBPLibraryItem *result = [TBPLibraryItem itemWithMediaItem:item grouping:MPMediaGroupingTitle];
        [tracks addObject:result];
    }
    return tracks;
}

- (void) playTrackWithId:(NSNumber *)trackPersistentId inAlbum:(NSNumber *)albumPersistentId
{
    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:albumPersistentId
                                                                                forProperty:MPMediaItemPropertyAlbumPersistentID];
    MPMediaQuery *albumQuery = [[MPMediaQuery alloc] init];
    [albumQuery addFilterPredicate:albumPredicate];
    [albumQuery setGroupingType:MPMediaGroupingAlbum];
    
    NSArray *collections = albumQuery.collections;
    if (collections && collections.count) {
        MPMediaItemCollection *albumToEnqueue = [albumQuery.collections objectAtIndex:0];
        MPMediaItem *trackToEnqueue;
        for (MPMediaItem *track in albumToEnqueue.items) {
            NSNumber *otherTrackId = [track valueForProperty:MPMediaItemPropertyPersistentID];
            if ([otherTrackId isEqualToNumber:trackPersistentId])
                trackToEnqueue = track;
        }
        
        // if we're already playing this item, just seek to the beginning
        BOOL didSeek = NO;
        if (_musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
            MPMediaItem *nowPlaying = _musicPlayer.nowPlayingItem;
            if ([nowPlaying isEqual:trackToEnqueue]) {
                [_musicPlayer skipToBeginning];
                didSeek = YES;
            }
        }
        
        // otherwise, queue up the album and the correct track
        if (!didSeek) {
            [_musicPlayer setQueueWithItemCollection:albumToEnqueue];
            [_musicPlayer setNowPlayingItem:trackToEnqueue];
            [_musicPlayer play];
        }
    }
}

- (void) playPause
{
    if (_musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [_musicPlayer pause];
    } else {
        if (_musicPlayer.nowPlayingItem != nil) {
            [_musicPlayer play];
        }
    }
}


#pragma mark internal methods

- (void) onNowPlayingItemChanged:(NSNotification *)notification
{
    NSLog(@"TBPLibraryModel: now playing change");
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification
                                                        object:@(kTBPLibraryModelChangeNowPlaying)];
}

- (void) onPlaybackStateChanged:(NSNotification *)notification
{
    NSLog(@"TBPLibraryModel: playback state change");
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification
                                                        object:@(kTBPLibraryModelChangePlaybackState)];
}

- (void) recompute
{
    // TODO caching
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableOrderedSet *orderedArtistSet = [NSMutableOrderedSet orderedSet];
        NSMutableOrderedSet *orderedAlbumSet = [NSMutableOrderedSet orderedSet];
        NSMutableDictionary *artistAlbumMap = [NSMutableDictionary dictionary];
        
        // recompute index of artists
        MPMediaQuery *qArtists = [MPMediaQuery artistsQuery];
        NSArray *artists = [qArtists collections];
        
        for (MPMediaItemCollection *artistGrouping in artists) {
            MPMediaItem *groupItem = [artistGrouping representativeItem];
            
            TBPLibraryItem *result = [TBPLibraryItem itemWithMediaItem:groupItem grouping:MPMediaGroupingArtist];
            
            // start with an empty list of albums for this artist
            [artistAlbumMap setObject:[NSMutableOrderedSet orderedSet] forKey:result.persistentId];
            
            // add artist to index
            [orderedArtistSet addObject:result];
        }
        
        // recompute index of albums
        MPMediaQuery *qAlbums = [MPMediaQuery albumsQuery];
        NSArray *albums = [qAlbums collections];
        
        for (MPMediaItemCollection *albumGrouping in albums) {
            MPMediaItem *groupItem = [albumGrouping representativeItem];
            
            TBPLibraryItem *result = [TBPLibraryItem itemWithMediaItem:groupItem grouping:MPMediaGroupingAlbum];
            
            // add album to list of albums by artist
            NSNumber *artistId = [groupItem valueForProperty:MPMediaItemPropertyArtistPersistentID];
            if ([artistAlbumMap objectForKey:artistId]) {
                NSMutableOrderedSet *byArtist = [artistAlbumMap objectForKey:artistId];
                [byArtist addObject:result];
            }
            
            // add to overall album index
            [orderedAlbumSet addObject:result];
        }
        
        self.albums = orderedAlbumSet;
        self.artists = orderedArtistSet;
        self.albumsByArtist = artistAlbumMap;
        
        NSLog(@"TBPLibraryModel: library contents change");
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification
                                                            object:@(kTBPLibraryModelChangeLibraryContents)];
    });
}

@end
