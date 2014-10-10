//
//  TBPDatabaseObject.h
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <CoreData/CoreData.h>

FOUNDATION_EXPORT NSString * const kTBPDatabaseObjectPersistentId;

@interface TBPDatabaseObject : NSManagedObject

/**
 *  We'll refer to all database objects by persisten id for now. Maybe change this later.
 */
@property (nonatomic, strong) NSNumber *persistentId;

+ (NSString *)entityName;

+ (NSPredicate *)identityPredicateForId: (NSNumber *)persistentId;

+ (id) insert;
+ (id) insertInContext:(NSManagedObjectContext *)context;

+ (id) upsertWithId: (NSNumber *)persistentId;
+ (id) upsertWithId: (NSNumber *)persistentId inContext:(NSManagedObjectContext*)context;

+ (BOOL) existsWithId: (NSNumber *)persistentId;

@end
