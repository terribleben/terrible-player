//
//  TBPDatabase.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPDatabase.h"

@interface TBPDatabase ()
{
    BOOL isReady;
}

@property (nonatomic, strong) RKManagedObjectStore *managedObjectStore;

- (void)initManagedObjectStore;
- (NSManagedObjectContext *) scratchContext;
- (void) discardScratchContext:(NSManagedObjectContext *)scratchContext;

@end

@implementation TBPDatabase


+ (TBPDatabase *) sharedInstance
{
    static TBPDatabase *theDatabase = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theDatabase) {
            theDatabase = [[TBPDatabase alloc] init];
        }
    });
    return theDatabase;
}

- (id) init
{
    if (self = [super init]) {
        isReady = NO;
        [self initManagedObjectStore];
    }
    return self;
}

- (void)initManagedObjectStore
{
    NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"TBPModel" withExtension:@"momd"]];
    self.managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:objectModel];
    
    if (_managedObjectStore) {
        NSError *err;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportDirectoryPath = [paths objectAtIndex:0];
        
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectoryPath isDirectory:&isDirectory]) {
            NSError *err;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportDirectoryPath
                                           withIntermediateDirectories:NO attributes:nil error:&err]) {
                NSLog(@"TBPDatabase: Error: %@", err);
            }
        }
        
        if (!err) {
            NSString *persistentStorePath = [applicationSupportDirectoryPath stringByAppendingPathComponent:@"terrible-player.sqlite"];
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                     [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            
            NSPersistentStore *persistentStore = [_managedObjectStore addSQLitePersistentStoreAtPath:persistentStorePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:options error:&err];
            if (persistentStore) {
                [_managedObjectStore createManagedObjectContexts];
                isReady = YES;
            }
        }
    }
}


#pragma mark entities

- (id) insertEntityOfType:(NSString *)entityType
{
    return [self insertEntityOfType:entityType inContext:_managedObjectStore.mainQueueManagedObjectContext];
}

- (id) insertEntityOfType:(NSString *)entityType inContext:(NSManagedObjectContext *)context
{
    if (isReady) {
        return [NSEntityDescription insertNewObjectForEntityForName:entityType inManagedObjectContext:context];
    } else
        return nil;
}

- (NSArray *)fetchEntitiesOfType:(NSString *)entityType withPredicate:(NSPredicate *)predicate
{
    return [self fetchEntitiesOfType:entityType withPredicate:predicate inContext:_managedObjectStore.mainQueueManagedObjectContext];
}

- (NSArray *) fetchEntitiesOfType:(NSString *)entityType withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSArray *results = nil;
    NSError *err;
    
    if (isReady) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:entityType inManagedObjectContext:context]];
        [fetchRequest setResultType:NSManagedObjectResultType];
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        
        results = [context executeFetchRequest:fetchRequest error:&err];
    }
    
    return results;
}


#pragma mark contexts and persistence

- (void) save
{
    __block NSError *err;
    
    if (isReady) {
        // save the main context
        if ([_managedObjectStore.mainQueueManagedObjectContext hasChanges]) {
            [_managedObjectStore.mainQueueManagedObjectContext save:&err];
            if (err)
                NSLog(@"TBPDatabase: Error saving main queue context: %@", err);
        }
        // save the persistent context
        [_managedObjectStore.persistentStoreManagedObjectContext performBlockAndWait:^{
            if ([_managedObjectStore.persistentStoreManagedObjectContext hasChanges]) {
                [_managedObjectStore.persistentStoreManagedObjectContext save:&err];
                if (err)
                    NSLog(@"TBPDatabase: Error saving persistent context: %@", err);
            }
        }];
    }
}

- (NSManagedObjectContext *)scratchContext
{
    NSManagedObjectContext *scratchContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    scratchContext.parentContext = _managedObjectStore.persistentStoreManagedObjectContext;
    scratchContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    
    return scratchContext;
}

- (void)discardScratchContext:(NSManagedObjectContext *)scratchContext
{
    [scratchContext reset];
}

@end
