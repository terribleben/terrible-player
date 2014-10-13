//
//  TBPLastFMScrobbleQueue.h
//  terrible-player
//
//  This class will scrobble tracks, or queue them in CoreData when it can't.
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TBPLastFMScrobbleQueue : NSObject

+ (instancetype) sharedInstance;

- (void) scrobbleMediaItem: (MPMediaItem *)item withTimestamp: (NSTimeInterval)timestamp;

- (void) submitQueuedScrobbles;

@end
