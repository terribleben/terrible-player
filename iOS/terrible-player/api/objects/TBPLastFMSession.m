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
NSString * const kTBPLastFMSessionDefaultsKeyScrobblingEnabled = @"TBPLastFMSessionDefaultsKeyScrobblingEnabled";

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

- (id) init
{
    if (self = [super init]) {
        if (!self.isLoggedIn)
            self.isScrobblingEnabled = YES;
    }
    return self;
}

- (void) invalidate
{
    self.sessionKey = nil;
    self.name = nil;
    self.isScrobblingEnabled = YES;
}

- (BOOL) isLoggedIn
{
    return (self.sessionKey && self.sessionKey.length);
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

- (void) setIsScrobblingEnabled:(BOOL)isScrobblingEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:isScrobblingEnabled forKey:kTBPLastFMSessionDefaultsKeyScrobblingEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isScrobblingEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTBPLastFMSessionDefaultsKeyScrobblingEnabled];
}

@end
