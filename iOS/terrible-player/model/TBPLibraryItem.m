//
//  TBPLibraryItem.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLibraryItem.h"
#import "NSString+TBP.h"

@implementation TBPLibraryItem

+ (TBPLibraryItem *)itemWithMediaItem:(MPMediaItem *)item grouping:(MPMediaGrouping)grouping
{
    NSString *titleProperty = [MPMediaItem titlePropertyForGroupingType:grouping];
    NSString *idProperty = [MPMediaItem persistentIDPropertyForGroupingType:grouping];
    
    TBPLibraryItem *result = [[TBPLibraryItem alloc] init];
    result.title = [[item valueForProperty:titleProperty] stringByCanonizingForMusicLibrary];
    result.persistentId = [item valueForProperty:idProperty];
    result.artwork = [item valueForKey:MPMediaItemPropertyArtwork];

    return result;
}

@end
