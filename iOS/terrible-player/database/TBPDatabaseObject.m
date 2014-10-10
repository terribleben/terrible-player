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

+ (id) selectWithPredicate:(NSPredicate *)predicate
{
    NSArray *results = [[TBPDatabase sharedInstance] fetchEntitiesOfType:[self entityName]
                                                           withPredicate:predicate];
    if (results && results.count)
        return [results objectAtIndex:0];
    return nil;
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
