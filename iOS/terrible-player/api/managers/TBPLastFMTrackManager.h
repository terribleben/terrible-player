//
//  TBPLastFMTrackManager.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMObjectManager.h"

@interface TBPLastFMTrackManager : TBPLastFMObjectManager

+ (id) sharedInstance;

- (void)updateNowPlayingWithArtist: (NSString *)artistName
                             track: (NSString *)trackTitle
                             album: (NSString *)albumTitle
                          duration: (NSNumber *)duration
                           success: (void (^)(void))success
                           failure: (TBPObjectManagerFailure)failure;

@end
