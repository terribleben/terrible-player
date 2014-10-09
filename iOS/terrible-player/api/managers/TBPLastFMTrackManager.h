//
//  TBPLastFMTrackManager.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMObjectManager.h"

#define TBP_LAST_FM_SCROBBLE_MIN_SECS 30.0f
#define TBP_LAST_FM_SCROBBLE_MAX_SECS (60.0f * 4.0f)

@interface TBPLastFMTrackManager : TBPLastFMObjectManager

+ (id) sharedInstance;

- (void)updateNowPlayingWithArtist: (NSString *)artistName
                             track: (NSString *)trackTitle
                             album: (NSString *)albumTitle
                          duration: (NSNumber *)duration
                           success: (void (^)(void))success
                           failure: (TBPObjectManagerFailure)failure;

- (void)scrobbleWithArtist: (NSString *)artistName
                     track: (NSString *)trackTitle
                     album: (NSString *)albumTitle
                  duration: (NSNumber *)duration
                 timestamp: (NSTimeInterval)unixTimestampSinceTrackStarted
                   success: (void (^)(void))success
                   failure: (TBPObjectManagerFailure)failure;

@end
