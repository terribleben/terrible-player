//
//  TBPLastFMScrobbleQueue.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMScrobbleQueue.h"
#import "TBPLastFMTrackManager.h"
#import "TBPQueuedScrobble.h"
#import "TBPDatabase.h"

@implementation TBPLastFMScrobbleQueue

+ (instancetype) sharedInstance
{
    static TBPLastFMScrobbleQueue *theQueue = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theQueue) {
            theQueue = [[TBPLastFMScrobbleQueue alloc] init];
        }
    });
    return theQueue;
}

- (void) scrobbleMediaItem:(MPMediaItem *)item withTimestamp:(NSTimeInterval)timestamp
{
    if (item) {
        NSString *trackTitle = [item valueForProperty:MPMediaItemPropertyTitle];
        NSString *artistName = [item valueForProperty:MPMediaItemPropertyArtist];
        NSString *albumTitle = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSNumber *duration = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
        
        __block TBPQueuedScrobble *existing = [TBPQueuedScrobble selectWithPredicate:[TBPQueuedScrobble identityPredicateForId:@(item.persistentID) timestamp:@(timestamp)]];
        
        [[TBPLastFMTrackManager sharedInstance] scrobbleWithArtist:artistName track:trackTitle album:albumTitle duration:duration timestamp:timestamp success:^{
            // delete existing from queue
            if (existing) {
                // TODO delete
            }
                
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"TBPLastFMScrobbleQueue will enqueue failed scrobble: %@ - %@", artistName, trackTitle);
            
            // update existing or create new
            if (!existing) {
                existing = [TBPQueuedScrobble insert];
            }
            existing.track = trackTitle;
            existing.artist = artistName;
            existing.album = albumTitle;
            existing.duration = duration;
            existing.timestamp = @(floorf(timestamp));
            
            [[TBPDatabase sharedInstance] save];
        }];
    }
}

@end
