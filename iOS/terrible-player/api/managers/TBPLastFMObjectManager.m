//
//  TBPLastFMObjectManager.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMObjectManager.h"
#import "TBPLastFMSession.h"
#import "TBPConstants.h"
#import "NSString+TBP.h"

NSString * const kTBPAPILastFMParamFormat = @"format";
NSString * const kTBPAPILastFMParamKey = @"api_key";
NSString * const kTBPAPILastFMParamSignature = @"api_sig";
NSString * const kTBPAPILastFMParamSessionKey = @"sk";

@interface TBPLastFMObjectManager ()

- (NSString *)signatureForParameters: (NSDictionary *)params;

@property (nonatomic, strong) NSDictionary *config;

@end

@implementation TBPLastFMObjectManager

- (id) init
{
    if (self = [super init]) {
        NSString *configPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
        self.config = [NSDictionary dictionaryWithContentsOfFile:configPath];
        
        [self.HTTPClient setDefaultHeader:@"User-Agent" value:@"Cartridge/terrible-player for iOS"];
    }
    return self;
}

- (BOOL) isSecure
{
    return YES;
}

- (NSURL *)baseEndpoint
{
    return [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:kTBPAPIEndpointLastFM]];
}

- (BOOL)shouldEnqueueRequestWithParameters:(NSMutableDictionary *)parameters
{
    // we want JSON
    [parameters setObject:@"json" forKey:kTBPAPILastFMParamFormat];
    
    // add api key
    [parameters setObject:[self.config objectForKey:kTBPConfigLastFMKey] forKey:kTBPAPILastFMParamKey];
    
    // if it's not an auth request, add session key
    // TODO constant strings
    if (!([parameters objectForKey:@"method"] && [[parameters objectForKey:@"method"] isEqualToString:@"auth.getMobileSession"])) {
        NSString *sessionKey = [TBPLastFMSession sharedInstance].sessionKey;
        if (sessionKey)
            [parameters setObject:sessionKey forKey:kTBPAPILastFMParamSessionKey];
    }
    
    // sign
    [parameters setObject:[self signatureForParameters:parameters] forKey:kTBPAPILastFMParamSignature];
    
    return YES;
}

- (NSString *)signatureForParameters:(NSDictionary *)params
{
    NSString *secret = [self.config objectForKey:kTBPConfigLastFMSecret];
    NSMutableString *joinedParams = [NSMutableString string];
    
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    for (NSString *key in sortedKeys) {
            if ([key isEqualToString:kTBPAPILastFMParamFormat])
                continue;
        id obj = [params objectForKey:key];
        [joinedParams appendFormat:@"%@%@", key, obj];
    }
    [joinedParams appendString:secret];
    
    return [joinedParams md5String];
}

@end
