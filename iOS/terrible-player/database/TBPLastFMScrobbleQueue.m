//
//  TBPLastFMScrobbleQueue.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMScrobbleQueue.h"
#import "TBPLastFMTrackManager.h"
#import "TBPQueuedScrobble.h"
#import "TBPDatabase.h"

@interface TBPLastFMScrobbleQueue ()

@property (atomic, strong) NSNumber *isReadyToScrobble;
@property (atomic, strong) NSNumber *isScrobbling;

- (void) onAppForeground;
- (void) onAppBackground;

@end

@implementation TBPLastFMScrobbleQueue

+ (instancetype) sharedInstance
{
    static TBPLastFMScrobbleQueue *theQueue = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theQueue) {
            theQueue = [[TBPLastFMScrobbleQueue alloc] init];
        }
    });
    return theQueue;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.isScrobbling = @(NO);
        self.isReadyToScrobble = @(NO);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        // attempt to clear the queue
        [self submitQueuedScrobbles];
    }
    return self;
}

- (void) dealloc
{
    // [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark external methods

- (void) scrobbleMediaItem:(MPMediaItem *)item withTimestamp:(NSTimeInterval)timestamp
{
    if (item) {
        __block TBPQueuedScrobble *existing = [TBPQueuedScrobble selectWithPredicate:[TBPQueuedScrobble identityPredicateForId:@(item.persistentID) timestamp:@(timestamp)]];
        
        [[TBPLastFMTrackManager sharedInstance] scrobbleMediaItem:item timestamp:timestamp success: ^(NSDictionary *response) {
            // delete existing from queue
            if (existing) {
                [[TBPDatabase sharedInstance].managedObjectStore.mainQueueManagedObjectContext deleteObject:existing];
                [[TBPDatabase sharedInstance] save];
            }
                
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            // update existing or create new
            if (!existing) {
                existing = [TBPQueuedScrobble insertWithMediaItem:item timestamp:timestamp];
            } else
                existing.timestamp = @(floorf(timestamp));
            
            NSLog(@"TBPLastFMScrobbleQueue: enqueue failed scrobble: %@ - %@", existing.artist, existing.track);
            [[TBPDatabase sharedInstance] save];
        }];
    }
}

- (void) submitQueuedScrobbles
{
    // TODO call this on reachability change
    // TODO call this when we're done processing missed scrobbles (possibly a bit after app foreground)
    self.isReadyToScrobble = @(YES);
    
    if (!self.isScrobbling) {
        self.isScrobbling = @(YES);
        
        NSError *err;
        NSFetchRequest *fetchQueue = [NSFetchRequest fetchRequestWithEntityName:[TBPQueuedScrobble entityName]];
        fetchQueue.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES] ];
        
        NSArray *queued = [[TBPDatabase sharedInstance].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchQueue error:&err];
        
        if (self.isReadyToScrobble && queued.count) {
            __block NSUInteger batchIndex = 0;
            __block NSUInteger batchSize = MIN(queued.count, TBP_LAST_FM_SCROBBLE_BATCH_SIZE);

            __block NSArray *batch = [queued subarrayWithRange:NSMakeRange(batchIndex, batchSize)];
            __block NSMutableSet *submitted = [NSMutableSet set];
            
            // block to execute when we're done scrobbling for any reason
            void (^onFinishedScrobbling)(void) = ^{
                // clear submitted scrobbles from queue
                for (TBPQueuedScrobble *toDelete in submitted) {
                    [[TBPDatabase sharedInstance].managedObjectStore.mainQueueManagedObjectContext deleteObject:toDelete];
                }
                [[TBPDatabase sharedInstance] save];
                self.isScrobbling = @(NO);
            };
            
            void (^batchFailed)(RKObjectRequestOperation *, NSError *) = ^(RKObjectRequestOperation *operation, NSError *error) {
                // abort this whole endeavor
                NSLog(@"TBPLastFMScrobbleQueue failed to submit batch, aborting: %@", error);
                onFinishedScrobbling();
            };
            
            void (^batchSucceeded)(NSDictionary *) = ^(NSDictionary *response) {
                // add submitted scrobbles to submitted set
                for (TBPQueuedScrobble *submittedScrobble in batch) {
                    [submitted addObject:submittedScrobble];
                }
                
                // compute next batch
                batchIndex += batchSize;
                batchSize = MIN(queued.count - batchIndex, TBP_LAST_FM_SCROBBLE_BATCH_SIZE);
                if (batchSize == 0) {
                    // none left, we're finished
                    NSLog(@"TBPLastFMScrobbleQueue fully cleared");
                    onFinishedScrobbling();
                } else {
                    // submit next batch
                    if (self.isReadyToScrobble) {
                        batch = [queued subarrayWithRange:NSMakeRange(batchIndex, batchSize)];
                        [[TBPLastFMTrackManager sharedInstance] scrobbleEnqueuedScrobbles:batch success:batchSucceeded failure:batchFailed];
                    } else {
                        // or get interrupted
                        NSLog(@"TBPLastFMScrobbleQueue interrupted clearing queue");
                        onFinishedScrobbling();
                    }
                }
            };
            
            // send initial batch
            NSLog(@"TBPLastFMScrobbleQueue attempting to clear queue (%lu)...", (unsigned long)queued.count);
            [[TBPLastFMTrackManager sharedInstance] scrobbleEnqueuedScrobbles:batch success:batchSucceeded failure:batchFailed];
        } else
            self.isScrobbling = @(NO);
    }
}


#pragma mark internal methods

- (void)onAppForeground
{
    // begin clearing queue if we're able to
    [self submitQueuedScrobbles];
}

- (void)onAppBackground
{
    // interrupt scrobbling if it's in progress
    self.isReadyToScrobble = @(NO);
}

@end
