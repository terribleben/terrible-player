//
//  TBPLibraryItem.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TBPLibraryItem : NSObject

@property (nonatomic, strong) NSNumber *persistentId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *releaseDate;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) MPMediaItemArtwork *artwork;

+ (TBPLibraryItem *)itemWithMediaItem: (MPMediaItem *)item grouping: (MPMediaGrouping)grouping;
+ (TBPLibraryItem *)itemWithMediaCollection: (MPMediaItemCollection *)collection grouping: (MPMediaGrouping)grouping;

@end
