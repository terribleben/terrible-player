//
//  TBPCachedNowPlayingContext.m
//  terrible-player
//
//  Created by Ben Roth on 10/13/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPCachedNowPlayingContext.h"

@implementation TBPCachedNowPlayingContext

@dynamic dateCached, indexOfNowPlaying, timeInNowPlaying, didScrobbleNowPlaying, playCounts;

+ (NSString *)entityName
{
    return @"CachedNowPlayingContext";
}

@end
