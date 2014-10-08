//
//  NSString+TBP.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "NSString+TBP.h"

@implementation NSString (TBP)

- (NSString *)stringByCanonizingForMusicLibrary
{
    // trim whitespace
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
