//
//  TBPLastFMAuthManager.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMAuthManager.h"
#import "TBPLastFMSession.h"

#import <RKRequestDescriptor.h>
#import <RKResponseDescriptor.h>

@implementation TBPLastFMAuthManager

+ (id) sharedInstance
{
    static TBPLastFMAuthManager *theManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theManager) {
            theManager = [[TBPLastFMAuthManager alloc] init];
        }
    });
    return theManager;
}

- (NSArray *)expectedResponseDescriptors
{
    // auth
    RKObjectMapping *sessionResponseMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [sessionResponseMapping addAttributeMappingsFromArray:@[ @"name", @"key" ]];
    RKResponseDescriptor *getSession = [RKResponseDescriptor responseDescriptorWithMapping:sessionResponseMapping
                                                                                        method:RKRequestMethodPOST
                                                                                   pathPattern:@""
                                                                                       keyPath:@"session"
                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    return @[ getSession ];
}

- (void) authenticateWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(void))success failure:(TBPObjectManagerFailure)failure
{
    NSDictionary *params = @{
                             @"method": @"auth.getMobileSession",
                             @"password": password,
                             @"username": username
                             };
    [self postObject:nil path:@"" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (mappingResult && mappingResult.dictionary) {
            NSDictionary *sessionInfo = [mappingResult.dictionary objectForKey:@"session"];
            NSString *sessionKey = [sessionInfo objectForKey:@"key"];
            NSString *sessionName = [sessionInfo objectForKey:@"name"];
            
            if (sessionKey) {
                [TBPLastFMSession sharedInstance].sessionKey = sessionKey;
                [TBPLastFMSession sharedInstance].name = sessionName;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLastFMSessionDidChangeNotification object:nil];
                
                if (success)
                    success();
            } else {
                if (failure)
                    failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeUnexpectedResponse userInfo:nil]);
            }
        }
    } failure:failure];
}

- (void) signOut
{
    // last.fm doesn't appear to have a "sign out" API call for some reason, so just kill the session locally.
    [[TBPLastFMSession sharedInstance] invalidate];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLastFMSessionDidChangeNotification object:nil];
}

@end
