//
//  TBPLastFMSession.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMSession.h"

NSString * const kTBPLastFMSessionDidChangeNotification = @"TBPLastFMSessionDidChangeNotification";

NSString * const kTBPLastFMSessionDefaultsKeyName = @"TBPLastFMSessionDefaultsKeyName";
NSString * const kTBPLastFMSessionDefaultsKeyKey = @"TBPLastFMSessionDefaultsKeyKey";

@implementation TBPLastFMSession

+ (id) sharedInstance
{
    static TBPLastFMSession *theSession = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theSession) {
            theSession = [[TBPLastFMSession alloc] init];
        }
    });
    return theSession;
}

- (void) setName:(NSString *)name
{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:kTBPLastFMSessionDefaultsKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)name
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTBPLastFMSessionDefaultsKeyName];
}

- (void) setSessionKey:(NSString *)sessionKey
{
    [[NSUserDefaults standardUserDefaults] setObject:sessionKey forKey:kTBPLastFMSessionDefaultsKeyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)sessionKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTBPLastFMSessionDefaultsKeyKey];
}

@end
