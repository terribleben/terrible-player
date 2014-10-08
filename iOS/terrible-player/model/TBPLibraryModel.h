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
 */
@property (nonatomic, readonly) NSOrderedSet *artists;

@end
