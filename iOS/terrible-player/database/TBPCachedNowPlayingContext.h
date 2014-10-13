//
//  TBPCachedNowPlayingContext.h
//  terrible-player
//
//  Created by Ben Roth on 10/13/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPDatabaseObject.h"

@interface TBPCachedNowPlayingContext : TBPDatabaseObject

@property (nonatomic, strong) NSDate *dateCached;
@property (nonatomic, strong) NSNumber *indexOfNowPlaying;
@property (nonatomic, strong) NSNumber *timeInNowPlaying;
@property (nonatomic, strong) NSNumber *didScrobbleNowPlaying;
@property (nonatomic, strong) NSArray *playCounts;

@end
