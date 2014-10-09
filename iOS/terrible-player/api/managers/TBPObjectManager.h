//
//  TBPObjectManager.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "RKObjectManager.h"

FOUNDATION_EXPORT NSString * const kTBPAPIErrorDomain;

/**
 *  Error codes for failed API requests.
 */
typedef enum TBPAPIErrorCode : NSUInteger {
    kTBPAPIErrorCodeUnknown = 0,
    kTBPAPIErrorCodeInvalidRequest = 1,
    kTBPAPIErrorCodeUnexpectedResponse = 2
} TBPAPIErrorCode;

/**
 *  Failure callback for object requests.
 */
typedef void (^TBPObjectManagerFailure)(RKObjectRequestOperation *operation, NSError *error);

@interface TBPObjectManager : RKObjectManager

@property (nonatomic, readonly) NSURL *baseEndpoint;
@property (nonatomic, readonly) BOOL isSecure; // whether or not the manager uses https.

@property (nonatomic, readonly) NSArray *expectedRequestDescriptors; // the RestKit request descriptors handled by this manager.
@property (nonatomic, readonly) NSArray *expectedResponseDescriptors; // the RestKit response descriptors handled by this manager.

/**
 *  Validate the parameters for a request.
 */
- (BOOL) shouldEnqueueRequestWithParameters: (NSMutableDictionary *)parameters;

@end
