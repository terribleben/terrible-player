//
//  NSString+TBP.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TBP)

- (NSString *)stringByCanonizingForMusicLibrary;
+ (NSString *)stringFromTimeInterval: (NSTimeInterval)interval;

@end
