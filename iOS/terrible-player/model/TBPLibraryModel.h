//
//  TBPLibraryModel.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kTBPLibraryModelDidChangeNotification;

@interface TBPLibraryModel : NSObject

+ (TBPLibraryModel *) sharedInstance;

/**
 *  Set of NSString unique artist titles
 *  TODO: what do we actually want here?
 */
@property (nonatomic, readonly) NSOrderedSet *artists;

/**
 *  Set of NSString unique album titles
 *  TODO: what do we actually want here?
 */
@property (nonatomic, readonly) NSOrderedSet *albums;

@end
