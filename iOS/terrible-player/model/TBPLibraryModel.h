//
//  TBPLibraryModel.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBPLibraryItem.h"

/**
 *  Passed with a TBPLibraryModelChangeReason
 */
FOUNDATION_EXPORT NSString * const kTBPLibraryModelDidChangeNotification;

typedef enum TBPLibraryModelChangeReason : NSUInteger {
    kTBPLibraryModelChangeUnknown           = 0,
    kTBPLibraryModelChangeNowPlaying        = 1 << 0,
    kTBPLibraryModelChangePlaybackState     = 1 << 1,
    kTBPLibraryModelChangeLibraryContents   = 1 << 2
} TBPLibraryModelChangeReason;

@class TBPLibraryModel;

@protocol TBPLibraryDelegate <NSObject>

- (void) libraryDidBeginReload: (TBPLibraryModel *)library;
- (void) libraryDidEndReload: (TBPLibraryModel *)library;

@end

@interface TBPLibraryModel : NSObject

+ (TBPLibraryModel *) sharedInstance;

@property (nonatomic, assign) id <TBPLibraryDelegate> delegate;

/**
 *  Re-scan the library on the device.
 *  Won't redundantly scan the library if nothing has changed.
 */
- (void) readMediaLibrary;

/**
 *  Represents the currently-queued album. Not computed from MPMusicPlayer.
 */
@property (nonatomic, strong) TBPLibraryItem *nowPlayingAlbumCache;

/**
 *  Now playing track, computed from the underlying MPMusicPlayer.
 */
@property (nonatomic, readonly) TBPLibraryItem *nowPlayingItem;

/**
 *  Current playback status, computed from the underlying MPMusicPlayer.
 */
@property (nonatomic, readonly) BOOL isPlaying;

/**
 *  Current playback progress, floating from 0-1, computed from the underlying MPMusicPlayer.
 */
@property (nonatomic, readonly) CGFloat nowPlayingProgress;

/**
 *  Set of TPLibraryItem artists
 */
@property (nonatomic, readonly) NSOrderedSet *artists;

/**
 *  Set of TPLibraryItem albums
 */
@property (nonatomic, readonly) NSOrderedSet *albums;

/**
 *  Subset of albums belonging to a particular artist
 */
- (NSOrderedSet *)albumsForArtistWithId: (NSNumber *)artistPersistentId;

/**
 *  Tracks for a particular album (never cached)
 */
- (NSOrderedSet *)tracksForAlbumWithId: (NSNumber *)albumPersistentId;

/**
 *  Play a track in an album.
 */
- (void) playTrackWithId: (NSNumber *)trackPersistentId inAlbum: (TBPLibraryItem *)album;

/**
 *  Change playback state.
 */
- (void) playPause;

@end
