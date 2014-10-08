//
//  TBPLibraryModel.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kTBPLibraryModelDidChangeNotification;

@interface TBPLibraryModel : NSObject

+ (TBPLibraryModel *) sharedInstance;

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
- (void) playTrackWithId: (NSNumber *)trackPersistentId inAlbum: (NSNumber *)albumPersistentId;

@end
