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
#import "TBPLastFMTrackManager.h"

#import <MediaPlayer/MediaPlayer.h>

#define TBP_LAST_FM_NOW_PLAYING_DELAY 4.0f

NSString * const kTBPLibraryModelDidChangeNotification = @"TBPLibraryModelDidChangeNotification";

@interface TBPLibraryModel ()
{
    NSTimeInterval dtmLastUpdatedNowPlaying;
    NSInteger idLastUpdatedNowPlaying;
}

@property (nonatomic, strong) NSMutableOrderedSet *artists;
@property (nonatomic, strong) NSMutableOrderedSet *albums;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

@property (nonatomic, strong) NSTimer *tmrUpdateNowPlaying;
@property (nonatomic, strong) NSTimer *tmrScrobble;

- (void) recompute;
- (void) onNowPlayingItemChanged: (NSNotification *)notification;
- (void) onPlaybackStateChanged: (NSNotification *)notification;
- (void) updateLastFMNowPlaying;
- (void) scrobbleLastFM;

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
        dtmLastUpdatedNowPlaying = 0;
        idLastUpdatedNowPlaying = 0;
        
        self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
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

- (void) playTrackWithId:(NSNumber *)trackPersistentId inAlbum:(TBPLibraryItem *)album
{
    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:album.persistentId
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
        
        self.nowPlayingAlbumCache = album;
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
    MPMediaItem *nowPlayingItem = _musicPlayer.nowPlayingItem;
    
    // if the player has stopped altogether, clear the now playing context.
    if (!nowPlayingItem)
        self.nowPlayingAlbumCache = nil;

    NSInteger idNowPlaying = (nowPlayingItem) ? [[nowPlayingItem valueForKey:MPMediaItemPropertyPersistentID] integerValue] : 0;
    NSTimeInterval dtmNow = [[NSDate date] timeIntervalSince1970];
    
    if ((idLastUpdatedNowPlaying == idNowPlaying) && (dtmNow - dtmLastUpdatedNowPlaying <= 1.0f)) {
        // de-dup these updates... do nothing
    } else {
        NSLog(@"TBPLibraryModel: now playing change: %d", idNowPlaying);
        
        idLastUpdatedNowPlaying = idNowPlaying;
        dtmLastUpdatedNowPlaying = dtmNow;
        
        // kill any outstanding scheduled tasks
        if (_tmrUpdateNowPlaying) {
            [_tmrUpdateNowPlaying invalidate];
            _tmrUpdateNowPlaying = nil;
        }
        if (_tmrScrobble) {
            [_tmrScrobble invalidate];
            _tmrScrobble = nil;
        }
        
        if (nowPlayingItem) {
            // schedule a last.fm now playing update (a few seconds into the song)
            _tmrUpdateNowPlaying = [NSTimer scheduledTimerWithTimeInterval:TBP_LAST_FM_NOW_PLAYING_DELAY target:self
                                                                  selector:@selector(updateLastFMNowPlaying) userInfo:nil repeats:NO];
            
            // schedule a last.fm scrobble
            NSTimeInterval duration = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
            if (duration > TBP_LAST_FM_SCROBBLE_MIN_SECS) {
                _tmrScrobble = [NSTimer scheduledTimerWithTimeInterval:MIN(duration * 0.5f, TBP_LAST_FM_SCROBBLE_MAX_SECS) target:self
                                                              selector:@selector(scrobbleLastFM) userInfo:nil repeats:NO];
            }
        }
        
        // inform everybody else in the app
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification
                                                            object:@(kTBPLibraryModelChangeNowPlaying)];
    }
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
            TBPLibraryItem *result = [TBPLibraryItem itemWithMediaCollection:artistGrouping grouping:MPMediaGroupingArtist];
            
            // start with an empty list of albums for this artist
            [artistAlbumMap setObject:[NSMutableOrderedSet orderedSet] forKey:result.persistentId];
            
            // add artist to index
            [orderedArtistSet addObject:result];
        }
        
        // recompute index of albums
        MPMediaQuery *qAlbums = [MPMediaQuery albumsQuery];
        NSArray *albums = [qAlbums collections];
        
        for (MPMediaItemCollection *albumGrouping in albums) {
            TBPLibraryItem *result = [TBPLibraryItem itemWithMediaCollection:albumGrouping grouping:MPMediaGroupingAlbum];
            
            // add album to list of albums by artist
            MPMediaItem *groupItem = [albumGrouping representativeItem];
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

- (void) updateLastFMNowPlaying
{
    MPMediaItem *nowPlaying = _musicPlayer.nowPlayingItem;
    if (nowPlaying) {
        NSString *trackTitle = [nowPlaying valueForProperty:MPMediaItemPropertyTitle];
        NSString *artistName = [nowPlaying valueForProperty:MPMediaItemPropertyArtist];
        NSString *albumTitle = [nowPlaying valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSNumber *duration = [nowPlaying valueForProperty:MPMediaItemPropertyPlaybackDuration];
        
        [[TBPLastFMTrackManager sharedInstance] updateNowPlayingWithArtist:artistName track:trackTitle album:albumTitle duration:duration success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Warning: TBPLibraryModel failed to update last.fm now playing: %@", error);
        }];
    }
}

- (void) scrobbleLastFM
{
    MPMediaItem *nowPlaying = _musicPlayer.nowPlayingItem;
    if (nowPlaying) {
        NSString *trackTitle = [nowPlaying valueForProperty:MPMediaItemPropertyTitle];
        NSString *artistName = [nowPlaying valueForProperty:MPMediaItemPropertyArtist];
        NSString *albumTitle = [nowPlaying valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSNumber *duration = [nowPlaying valueForProperty:MPMediaItemPropertyPlaybackDuration];
        
        [[TBPLastFMTrackManager sharedInstance] scrobbleWithArtist:artistName track:trackTitle album:albumTitle duration:duration timestamp:dtmLastUpdatedNowPlaying success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Warning: TBPLibraryModel failed to scrobble: %@", error);
        }];
    }
}

@end
