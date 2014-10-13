//
//  TBPQueuedScrobble.h
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPDatabaseObject.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TBPQueuedScrobble : TBPDatabaseObject

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *track;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSNumber *duration;  // NSTimeInterval / float
@property (nonatomic, strong) NSNumber *timestamp; // int32

+ (instancetype)insertWithMediaItem: (MPMediaItem *)item timestamp: (NSTimeInterval)timestamp;

/**
 *  Scrobble is uniquely identified by both its persistentId and the timestamp.
 */
+ (NSPredicate *)identityPredicateForId: (NSNumber *)persistentId timestamp: (NSNumber *)timestamp;

@end
