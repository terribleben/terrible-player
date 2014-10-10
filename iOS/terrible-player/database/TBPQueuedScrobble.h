//
//  TBPQueuedScrobble.h
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPDatabaseObject.h"

@interface TBPQueuedScrobble : TBPDatabaseObject

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *track;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *timestamp;

@end
