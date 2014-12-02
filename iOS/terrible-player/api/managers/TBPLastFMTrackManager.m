//
//  TBPLastFMTrackManager.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMTrackManager.h"
#import "TBPLastFMSession.h"
#import "TBPQueuedScrobble.h"

#import <RKRequestDescriptor.h>
#import <RKResponseDescriptor.h>

@interface TBPLastFMTrackManager ()

- (NSString *)scrobbleParamWithName: (NSString *)name index: (NSUInteger)index;

@end

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
    if ([TBPLastFMSession sharedInstance].isLoggedIn && [TBPLastFMSession sharedInstance].isScrobblingEnabled) {
        NSLog(@"LastFM: Update now playing: %@ - %@", artistName, trackTitle);
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
                    
                    if (success) {
                        success();
                    }
                }
            } failure:failure];
        } else
            failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeInvalidRequest userInfo:nil]);
    }
    // if scrobbling not enabled, fail silently
}

- (void)scrobbleMediaItem:(MPMediaItem *)item timestamp:(NSTimeInterval)unixTimestampSinceTrackStarted success:(void (^)(NSDictionary *))success failure:(TBPObjectManagerFailure)failure
{
    NSString *trackTitle = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *artistName = [item valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumTitle = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSNumber *duration = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    
    if ([TBPLastFMSession sharedInstance].isLoggedIn && [TBPLastFMSession sharedInstance].isScrobblingEnabled) {
        NSLog(@"LastFM: Scrobble: %@ - %@", artistName, trackTitle);
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
                    
                    if (success) {
                        success(scrobbles);
                    }
                }
            } failure:failure];
        } else
            failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeInvalidRequest userInfo:nil]);
    }
    // scrobbling not enabled, fail silently
}

- (void)scrobbleEnqueuedScrobbles:(NSArray *)scrobbles success:(void (^)(NSDictionary *))success failure:(TBPObjectManagerFailure)failure
{
    if ([TBPLastFMSession sharedInstance].isLoggedIn && [TBPLastFMSession sharedInstance].isScrobblingEnabled) {
        
        // build big dictionary of scrobble params
        NSUInteger scrobbleIdx = 0;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"method": @"track.scrobble" }];
        
        for (TBPQueuedScrobble *scrobble in scrobbles) {
            if (scrobble.artist && scrobble.track && scrobble.timestamp) {
                NSMutableDictionary *trackParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                   [self scrobbleParamWithName:@"artist" index:scrobbleIdx]: scrobble.artist,
                                                                                                   [self scrobbleParamWithName:@"track" index:scrobbleIdx]: scrobble.track,
                                                                                                   [self scrobbleParamWithName:@"timestamp" index:scrobbleIdx]: [NSString stringWithFormat:@"%.0f", scrobble.timestamp.floatValue]
                                                                                                   }];
                if (scrobble.album)
                    [params setObject:scrobble.album forKey:[self scrobbleParamWithName:@"album" index:scrobbleIdx]];
                if (scrobble.duration)
                    [params setObject:[NSString stringWithFormat:@"%.0f", scrobble.duration.floatValue] forKey:[self scrobbleParamWithName:@"duration" index:scrobbleIdx]];
                
                [params addEntriesFromDictionary:trackParams];
                scrobbleIdx++;
            }
        }
        NSLog(@"Last.FM: Scrobble %lu tracks", (unsigned long)scrobbleIdx);
        
        [self postObject:nil path:@"" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (mappingResult && mappingResult.dictionary) {
                NSDictionary *scrobbles = [mappingResult.dictionary objectForKey:@"scrobbles"];
                
                if (success) {
                    success(scrobbles);
                }
            }
        } failure:failure];
    } else {
        // scrobbling not enabled / not logged in
        failure(nil, [NSError errorWithDomain:kTBPAPIErrorDomain code:kTBPAPIErrorCodeSession userInfo:nil]);
    }
}

- (NSString *)scrobbleParamWithName:(NSString *)name index:(NSUInteger)index
{
    return [NSString stringWithFormat:@"%@[%lu]", name, (unsigned long)index];
}

@end
