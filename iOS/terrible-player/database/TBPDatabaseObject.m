//
//  TBPDatabaseObject.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPDatabaseObject.h"
#import "TBPDatabase.h"

NSString * const kTBPDatabaseObjectPersistentId = @"persistentId";

@interface TBPDatabaseObject ()

+ (id) insertWithId: (NSNumber *)persistentId inContext: (NSManagedObjectContext *)context;

@end

@implementation TBPDatabaseObject

@dynamic persistentId;

+ (id) insert
{
    return [[TBPDatabase sharedInstance] insertEntityOfType:[self entityName]];
}

+ (id) insertInContext:(NSManagedObjectContext *)context
{
    return [[TBPDatabase sharedInstance] insertEntityOfType:[self entityName] inContext:context];
}

+ (id) insertWithId:(NSNumber *)persistentId inContext:(NSManagedObjectContext *)context
{
    id result;
    if (context)
        result = [self insertInContext:context];
    else
        result = [self insert];
    ((TBPDatabaseObject *)result).persistentId = persistentId;
    return result;
}

+ (id) upsertWithId:(NSNumber *)persistentId
{
    NSArray *results = [[TBPDatabase sharedInstance] fetchEntitiesOfType:[self entityName]
                                                          withPredicate:[self identityPredicateForId:persistentId]];
    if (results && results.count) {
        if (results.count > 1) {
            NSLog(@"Warning: Fetch entity %@ by id %@ returned %lu instances", [self entityName], persistentId, (unsigned long)results.count);
        }
        return [results objectAtIndex:0];
    } else
        return [self insertWithId:persistentId inContext:nil];
}

+ (id) upsertWithId:(NSNumber *)persistentId inContext:(NSManagedObjectContext *)context
{
    NSArray *results = [[TBPDatabase sharedInstance] fetchEntitiesOfType:[self entityName]
                                                          withPredicate:[self identityPredicateForId:persistentId]
                                                              inContext:context];
    if (results && results.count) {
        if (results.count > 1) {
            NSLog(@"Warning: Fetch entity %@ by id %@ returned %lu instances", [self entityName], persistentId, (unsigned long)results.count);
        }
        return [results objectAtIndex:0];
    } else
        return [self insertWithId:persistentId inContext:context];
}

+ (BOOL) existsWithId:(NSNumber *)persistentId
{
    NSArray *results = [[TBPDatabase sharedInstance] fetchEntitiesOfType:[self entityName]
                                                           withPredicate:[self identityPredicateForId:persistentId]];
    return (results && results.count);
}

+ (NSString *)entityName
{
    return @"DatabaseObject";
}

+ (NSPredicate *)identityPredicateForId:(NSNumber *)persistentId
{
    if (persistentId)
        return [NSPredicate predicateWithFormat:@"(%K=%llu)", kTBPDatabaseObjectPersistentId, persistentId.unsignedLongLongValue];
    else
        return nil;
}

@end
