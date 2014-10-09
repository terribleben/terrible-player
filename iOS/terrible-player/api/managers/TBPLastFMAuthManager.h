//
//  TBPLastFMAuthManager.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLastFMObjectManager.h"

@interface TBPLastFMAuthManager : TBPLastFMObjectManager

+ (id) sharedInstance;

- (void) authenticateWithUsername: (NSString *)username
                         password: (NSString *)password
                          success: (void (^)(void))success
                          failure: (TBPObjectManagerFailure)failure;

@end
