//
//  TBPQueuedScrobble.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPQueuedScrobble.h"

NSString * const kTBPQueuedScrobbleTimestamp = @"timestamp";

@implementation TBPQueuedScrobble

@dynamic artist, track, album, duration, timestamp;

+ (instancetype)insertWithMediaItem:(MPMediaItem *)item timestamp:(NSTimeInterval)timestamp
{
    TBPQueuedScrobble *scrobble = [[self class] insert];
    
    NSString *trackTitle = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *artistName = [item valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumTitle = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSNumber *duration = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    
    scrobble.track = trackTitle;
    scrobble.artist = artistName;
    scrobble.album = albumTitle;
    scrobble.duration = duration;
    scrobble.timestamp = @(floorf(timestamp));
    
    return scrobble;
}

+ (NSString *)entityName
{
    return @"QueuedScrobble";
}

+ (NSPredicate *)identityPredicateForId:(NSNumber *)persistentId timestamp:(NSNumber *)timestamp
{
    if (persistentId && timestamp)
        return [NSPredicate predicateWithFormat:@"((%K=%llu) AND (%K=%d))",
                kTBPDatabaseObjectPersistentId, persistentId.unsignedLongLongValue,
                kTBPQueuedScrobbleTimestamp, timestamp.integerValue
                ];
    else
        return nil;
}

@end
