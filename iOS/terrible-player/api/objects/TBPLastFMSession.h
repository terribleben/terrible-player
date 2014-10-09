//
//  TBPLastFMSession.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBPLastFMSession : NSObject

+ (TBPLastFMSession *)sharedInstance;

@property (nonatomic, strong) NSString *sessionKey;
@property (nonatomic, strong) NSString *name;

@end
