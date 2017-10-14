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
#import "TBPLastFMScrobbleQueue.h"

#import <MediaPlayer/MediaPlayer.h>

#define TBP_LAST_FM_NOW_PLAYING_DELAY 4.0f
#define TBP_RECOMPUTE_DELAY 3.0f
#define TBP_NOTIFY_DELAY 0.1f

NSString * const kTBPLibraryModelDidChangeNotification = @"TBPLibraryModelDidChangeNotification";
NSString * const kTBPLibraryDateRecomputedDefaultsKey = @"TBPLibraryDateRecomputedDefaultsKey";

@interface TBPLibraryModel ()
{
    NSTimeInterval dtmLastUpdatedNowPlaying;
}

@property (nonatomic, strong) NSMutableOrderedSet *artists;
@property (nonatomic, strong) NSMutableOrderedSet *albums;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

@property (nonatomic, strong) NSTimer *tmrUpdateLastFMNowPlaying;
@property (nonatomic, strong) NSTimer *tmrScrobble;
@property (nonatomic, strong) NSTimer *tmrRecompute;
@property (nonatomic, strong) NSTimer *tmrNotifyNowPlaying;
@property (nonatomic, strong) NSTimer *tmrNotifyPlaybackState;

@property (nonatomic, assign) BOOL isListeningToMediaLibraryNotifications;
@property (atomic, strong) NSNumber *isLoading;
@property (nonatomic, readwrite) NSDate *dtmLastRecomputed;

- (void) onNowPlayingItemChanged: (NSNotification *)notification;
- (void) onPlaybackStateChanged: (NSNotification *)notification;
- (void) onMediaLibraryChanged: (NSNotification *)notification;

- (void) fireNowPlayingNotification;
- (void) firePlaybackStateNotification;
- (void) recompute;

- (void) scheduleLastFMUpdates;
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
        
        // init scrobble queue
        [TBPLastFMScrobbleQueue sharedInstance];
        
        // init device media player
        self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onIsPreparedToPlayChanged:)
                                                     name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void) dealloc
{
    [self setIsListeningToMediaLibraryNotifications:NO];
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
    return (nowPlayingDuration) ? (_musicPlayer.currentPlaybackTime / nowPlayingDuration) : 0;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            // workaround from stack overflow
            [_musicPlayer play];
            [_musicPlayer pause];
        });
    } else {
        if (_musicPlayer.nowPlayingItem != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // workaround from stack overflow
                [_musicPlayer pause];
                [_musicPlayer play];
            });
        }
    }
}

- (void) readMediaLibrary
{
    if (!self.albumsByArtist) {
        // zero cache yet, recompute immediately.
        [self recompute];
    } else {
        // we've got a cache, it might need updating.
        NSDate *dtmMediaLibraryUpdated = [MPMediaLibrary defaultMediaLibrary].lastModifiedDate;
        NSDate *dtmCacheUpdated = self.dtmLastRecomputed;
        
        if (!dtmCacheUpdated || [dtmMediaLibraryUpdated compare:self.dtmLastRecomputed] == NSOrderedDescending) {
            // yes, our cache is old.
            // in order to avoid duplicate hits, recompute after a few seconds.
            if (_tmrRecompute) {
                [_tmrRecompute invalidate];
                _tmrRecompute = nil;
            }
            self.tmrRecompute = [NSTimer scheduledTimerWithTimeInterval:TBP_RECOMPUTE_DELAY target:self selector:@selector(recompute) userInfo:nil repeats:NO];
        }
    }
}


#pragma mark - internal methods

- (void)onIsPreparedToPlayChanged:(NSNotification *)notification
{
    if (_musicPlayer.isPreparedToPlay) {
        [_musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [_musicPlayer setRepeatMode: MPMusicRepeatModeNone];
        
        [self setIsListeningToMediaLibraryNotifications:YES];
    } else {
        [self setIsListeningToMediaLibraryNotifications:NO];
    }
}

- (void)setIsListeningToMediaLibraryNotifications:(BOOL)isListening
{
    if (isListening != _isListeningToMediaLibraryNotifications) {
        _isListeningToMediaLibraryNotifications = isListening;
        if (isListening) {
            // listen to the device media player
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(onNowPlayingItemChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
            [notificationCenter addObserver:self selector:@selector(onPlaybackStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
            [_musicPlayer beginGeneratingPlaybackNotifications];
            
            // listen to the device media library (for syncs / changes)
            [notificationCenter addObserver:self selector:@selector(onMediaLibraryChanged:) name:MPMediaLibraryDidChangeNotification object:nil];
            [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
            
            // sometimes these fire before we are listening. trigger them both once right now.
            [self onNowPlayingItemChanged:nil];
            [self onPlaybackStateChanged:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            [_musicPlayer endGeneratingPlaybackNotifications];
            [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
        }
    }
}

- (void) onNowPlayingItemChanged:(__unused NSNotification *)notification
{
    // if the player has stopped altogether, clear the now playing context.
    if (!_musicPlayer.nowPlayingItem)
        self.nowPlayingAlbumCache = nil;
    
    // notify the rest of the app after a slight delay, to prevent dupes
    if (_tmrNotifyNowPlaying) {
        [_tmrNotifyNowPlaying invalidate];
        _tmrNotifyNowPlaying = nil;
    }
    self.tmrNotifyNowPlaying = [NSTimer scheduledTimerWithTimeInterval:TBP_NOTIFY_DELAY target:self selector:@selector(fireNowPlayingNotification) userInfo:nil repeats:NO];
}

- (void) fireNowPlayingNotification
{
    NSLog(@"now playing item changed (debounced from system notif)");
    dtmLastUpdatedNowPlaying = [[NSDate date] timeIntervalSince1970];
    
    // inform the rest of the app about the now playing change
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification
                                                        object:@(kTBPLibraryModelChangeNowPlaying)];
    
    [self scheduleLastFMUpdates];
}

- (void) onPlaybackStateChanged:(__unused NSNotification *)notification
{
    NSLog(@"playback state changed");
    // notify the rest of the app after a slight delay, to prevent dupes
    if (_tmrNotifyPlaybackState) {
        [_tmrNotifyPlaybackState invalidate];
        _tmrNotifyPlaybackState = nil;
    }
    self.tmrNotifyPlaybackState = [NSTimer scheduledTimerWithTimeInterval:TBP_NOTIFY_DELAY target:self selector:@selector(firePlaybackStateNotification) userInfo:nil repeats:NO];
}

- (void) firePlaybackStateNotification
{
    // inform the rest of the app about the playback state change
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification
                                                        object:@(kTBPLibraryModelChangePlaybackState)];
    
    [self scheduleLastFMUpdates];
}

- (void) onMediaLibraryChanged:(NSNotification *)notification
{
    NSLog(@"TBPLibraryModel: media library change");
    [self readMediaLibrary];
}

- (void) recompute
{
    if (![self.isLoading boolValue]) {
        self.isLoading = @(YES);
        NSDate *dtmRecomputeStarted = [NSDate date];
        
        if (_delegate) {
            [_delegate libraryDidBeginReload:self];
        }
        
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification
                                                                object:@(kTBPLibraryModelChangeLibraryContents)];
            
            if (_delegate) {
                [_delegate libraryDidEndReload:self];
            }
            
            self.isLoading = @(NO);
            self.dtmLastRecomputed = dtmRecomputeStarted;
        });
    }
}

- (NSDate *)dtmLastRecomputed
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTBPLibraryDateRecomputedDefaultsKey];
}

- (void)setDtmLastRecomputed:(NSDate *)dtmLastRecomputed
{
    [[NSUserDefaults standardUserDefaults] setObject:dtmLastRecomputed forKey:kTBPLibraryDateRecomputedDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)scheduleLastFMUpdates
{
    // kill any outstanding scheduled tasks
    if (_tmrUpdateLastFMNowPlaying) {
        [_tmrUpdateLastFMNowPlaying invalidate];
        _tmrUpdateLastFMNowPlaying = nil;
    }
    if (_tmrScrobble) {
        [_tmrScrobble invalidate];
        _tmrScrobble = nil;
    }
    
    MPMediaItem *nowPlayingItem = _musicPlayer.nowPlayingItem;
    
    if (nowPlayingItem && self.isPlaying) {
        NSLog(@"TBPLibrary: Scheduling scrobble");
        // schedule a last.fm now playing update (a few seconds into the song)
        _tmrUpdateLastFMNowPlaying = [NSTimer scheduledTimerWithTimeInterval:TBP_LAST_FM_NOW_PLAYING_DELAY target:self
                                                              selector:@selector(updateLastFMNowPlaying) userInfo:nil repeats:NO];
        
        // schedule a last.fm scrobble
        NSTimeInterval duration = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
        if (duration > TBP_LAST_FM_SCROBBLE_MIN_SECS) {
            _tmrScrobble = [NSTimer scheduledTimerWithTimeInterval:MIN(duration * 0.5f, TBP_LAST_FM_SCROBBLE_MAX_SECS) target:self
                                                          selector:@selector(scrobbleLastFM) userInfo:nil repeats:NO];
        }
    } else
        NSLog(@"TBPLibrary: Aborting scrobble");
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
    [[TBPLastFMScrobbleQueue sharedInstance] scrobbleMediaItem:nowPlaying withTimestamp:dtmLastUpdatedNowPlaying];
}

@end
