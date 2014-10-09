//
//  TBPLastFMTrackManager.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMTrackManager.h"

#import <RKRequestDescriptor.h>
#import <RKResponseDescriptor.h>

@implementation TBPLastFMTrackManager

+ (id) sharedInstance
{
    static TBPLastFMTrackManager *theManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theManager) {
            theManager = [[TBPLastFMTrackManager alloc] init];
        }
    });
    return theManager;
}

- (NSArray *)expectedResponseDescriptors
{
    // update now playing
    RKObjectMapping *nowPlayingResponseMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [nowPlayingResponseMapping addAttributeMappingsFromArray:@[ @"track", @"artist", @"album", @"ignoredMessage" ]];
    RKResponseDescriptor *updateNowPlaying = [RKResponseDescriptor responseDescriptorWithMapping:nowPlayingResponseMapping
                                                                                          method:RKRequestMethodPOST
                                                                                     pathPattern:@""
                                                                                         keyPath:@"nowplaying"
                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // scrobble
    RKObjectMapping *scrobbleResponseMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    RKResponseDescriptor *scrobble = [RKResponseDescriptor responseDescriptorWithMapping:scrobbleResponseMapping
                                                                                          method:RKRequestMethodPOST
                                                                                     pathPattern:@""
                                                                                         keyPath:@"scrobbles"
                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    return @[ updateNowPlaying, scrobble ];
}

- (void)updateNowPlayingWithArtist:(NSString *)artistName track:(NSString *)trackTitle album:(NSString *)albumTitle duration:(NSNumber *)duration success:(void (^)(void))success failure:(TBPObjectManagerFailure)failure
{
    if (artistName && artistName.length && trackTitle && trackTitle.length) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"method": @"track.updateNowPlaying",
                                                                                      @"artist": artistName,
                                                                                      @"track": trackTitle
                                                                                      }];
        if (albumTitle)
            [params setObject:albumTitle forKey:@"album"];
        if (duration)
            [params setObject:[NSString stringWithFormat:@"%.0f", duration.floatValue] forKey:@"duration"];
    
        [self postObject:nil path:@"" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (mappingResult && mappingResult.dictionary) {
                NSDictionary *nowPlayingInfo = [mappingResult.dictionary objectForKey:@"nowplaying"];
                NSDictionary *ignoredMessage = [nowPlayingInfo objectForKey:@"ignoredMessage"];
                if (ignoredMessage) {
                    NSString *ignoredMessageContents = [ignoredMessage objectForKey:@"#text"];
                    if (ignoredMessageContents && ignoredMessageContents.length)
                        NSLog(@"Warning: TBPLastFmTrackManager: track.updateNowPlaying ignored: %@", ignoredMessage);
                }
                
                if (success)
                    success();
            }
        } failure:failure];
    } else
        failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeInvalidRequest userInfo:nil]);
}

- (void)scrobbleWithArtist:(NSString *)artistName track:(NSString *)trackTitle album:(NSString *)albumTitle duration:(NSNumber *)duration timestamp:(NSTimeInterval)unixTimestampSinceTrackStarted success:(void (^)(void))success failure:(TBPObjectManagerFailure)failure
{
    if (artistName && artistName.length && trackTitle && trackTitle.length && unixTimestampSinceTrackStarted && unixTimestampSinceTrackStarted > 0) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"method": @"track.scrobble",
                                                                                      @"artist": artistName,
                                                                                      @"track": trackTitle,
                                                                                      @"timestamp": [NSString stringWithFormat:@"%.0f", unixTimestampSinceTrackStarted]
                                                                                      }];
        if (albumTitle)
            [params setObject:albumTitle forKey:@"album"];
        if (duration)
            [params setObject:[NSString stringWithFormat:@"%.0f", duration.floatValue] forKey:@"duration"];
        
        [self postObject:nil path:@"" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (mappingResult && mappingResult.dictionary) {
                NSDictionary *scrobbles = [mappingResult.dictionary objectForKey:@"scrobbles"];
                
                if (success)
                    success();
            }
        } failure:failure];
    } else
        failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeInvalidRequest userInfo:nil]);
}

@end
