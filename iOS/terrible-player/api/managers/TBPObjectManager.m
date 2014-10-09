//
//  TBPObjectManager.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPObjectManager.h"

#import <RKMIMETypes.h>
#import <RKResponseDescriptor.h>

NSString * const kTBPAPIErrorDomain = @"TBPAPIErrorDomain";

@implementation TBPObjectManager

- (id) initWithBaseURL:(NSURL *)url
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"The base URL of a TBPObjectManager is determined internally" userInfo:nil];
}

- (id) init
{
    NSString *topLevelURL = [NSString stringWithFormat:@"%@%@",
                             (self.isSecure) ? @"https://" : @"http://",
                             self.baseEndpoint.absoluteString];
    
    AFHTTPClient *internalClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:topLevelURL]];
    
    if (self = [super initWithHTTPClient:internalClient]) {
        [self addRequestDescriptorsFromArray:[self expectedRequestDescriptors]];
        [self addResponseDescriptorsFromArray:[self expectedResponseDescriptors]];
    }
    return self;
}


#pragma mark stuff to override

- (NSURL *)baseEndpoint
{
    // override me
    return nil;
}

- (BOOL) isSecure
{
    return NO;
}

- (BOOL) shouldEnqueueRequestWithParameters:(NSMutableDictionary *)parameters
{
    // base class passes everything
    return YES;
}

- (NSArray *)expectedResponseDescriptors
{
    return @[];
}

- (NSArray *)expectedRequestDescriptors
{
    return @[];
}


#pragma mark inherited methods

- (void) getObjectsAtPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:((parameters) ? parameters : @{})];
    
    if ([self shouldEnqueueRequestWithParameters:mutableParams]) {
        return [super getObjectsAtPath:path parameters:mutableParams success:success failure:failure];
    } else {
        failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeInvalidRequest userInfo:nil]);
    }
}

- (void) postObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:((parameters) ? parameters : @{})];
    
    if ([self shouldEnqueueRequestWithParameters:mutableParams]) {
        // we override the RK postObject behavior in order to clear the target object of the operation
        RKObjectRequestOperation *operation = [self appropriateObjectRequestOperationWithObject:object
                                                                                         method:RKRequestMethodPOST
                                                                                           path:path
                                                                                     parameters:mutableParams];
        [operation setCompletionBlockWithSuccess:success failure:failure];
        operation.targetObject = nil;
        [self enqueueObjectRequestOperation:operation];
    } else {
        failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeInvalidRequest userInfo:nil]);
    }
}

- (void) putObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:((parameters) ? parameters : @{})];
    
    if ([self shouldEnqueueRequestWithParameters:mutableParams]) {
        // we override the RK postObject behavior in order to clear the target object of the operation
        RKObjectRequestOperation *operation = [self appropriateObjectRequestOperationWithObject:object
                                                                                         method:RKRequestMethodPUT
                                                                                           path:path
                                                                                     parameters:mutableParams];
        [operation setCompletionBlockWithSuccess:success failure:failure];
        operation.targetObject = nil;
        [self enqueueObjectRequestOperation:operation];
    } else {
        failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeInvalidRequest userInfo:nil]);
    }
}

- (void) deleteObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:((parameters) ? parameters : @{})];
    
    if ([self shouldEnqueueRequestWithParameters:mutableParams]) {
        return [super deleteObject:object path:path parameters:mutableParams success:success failure:failure];
    } else {
        failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeInvalidRequest userInfo:nil]);
    }
}

@end
