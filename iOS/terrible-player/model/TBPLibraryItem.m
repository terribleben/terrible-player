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
    result.artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    result.duration = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    result.releaseDate = [item valueForProperty:@"year"];
    result.count = @(1);

    return result;
}

+ (TBPLibraryItem *)itemWithMediaCollection:(MPMediaItemCollection *)collection grouping:(MPMediaGrouping)grouping
{
    // get basic stuff from the collection's representative item
    TBPLibraryItem *fromItem = [TBPLibraryItem itemWithMediaItem:[collection representativeItem] grouping:grouping];
    
    // compute duration from the sum of the collection contents
    NSTimeInterval totalDuration = 0;
    
    for (MPMediaItem *item in collection.items) {
        NSNumber *itemDurationObj = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
        NSTimeInterval itemDuration = (itemDurationObj) ? itemDurationObj.floatValue : 0;
        totalDuration += itemDuration;
    }
    
    fromItem.duration = [NSNumber numberWithFloat:totalDuration];
    fromItem.count = @(collection.items.count);
    return fromItem;
}

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        TBPLibraryItem *other = (TBPLibraryItem *)object;
        return ((other.persistentId == nil && _persistentId == nil)
                || [other.persistentId isEqualToNumber:_persistentId]);
    }
    return NO;
}

@end
