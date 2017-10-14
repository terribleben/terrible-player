//
//  TBPDatabase.h
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKManagedObjectStore.h"

@interface TBPDatabase : NSObject

+ (TBPDatabase *) sharedInstance;

/**
 *  Return the managed object store instance we'll use app-wide.
 */
@property (nonatomic, readonly) RKManagedObjectStore *managedObjectStore;

/**
 *  Insert a record for the given entity type.
 *  If context isn't specified, writes to a persistent context.
 */
- (id) insertEntityOfType:(NSString *)entityType;
- (id) insertEntityOfType:(NSString *)entityType inContext:(NSManagedObjectContext *)context;

/**
 *  Perform a fetch query for the specified type of entity and optional predicate.
 *  If context isn't specified, writes to a persistent context.
 */
- (NSArray *) fetchEntitiesOfType:(NSString *)entityType
                    withPredicate:(NSPredicate *)predicate;

- (NSArray *) fetchEntitiesOfType:(NSString *)entityType
                    withPredicate:(NSPredicate *)predicate
                        inContext:(NSManagedObjectContext *)context;

/**
 *  Write changes in the main context to disk.
 */
- (void) save;

@end
