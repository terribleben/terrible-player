//
//  TBPLibraryModel.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLibraryModel.h"
#import "NSString+TBP.h"
#import "TBPLibraryItem.h"

#import <MediaPlayer/MediaPlayer.h>

NSString * const kTBPLibraryModelDidChangeNotification = @"TBPLibraryModelDidChangeNotification";

@interface TBPLibraryModel ()

- (void) recomputeArtists;
- (void) recomputeAlbums;

@property (nonatomic, strong) NSMutableOrderedSet *artists;
@property (nonatomic, strong) NSMutableOrderedSet *albums;

@end

@implementation TBPLibraryModel

+ (TBPLibraryModel *) sharedInstance
{
    static TBPLibraryModel *theModel = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theModel) {
            theModel = [[TBPLibraryModel alloc] init];
        }
    });
    return theModel;
}

- (id) init
{
    if (self = [super init]) {
        [self recomputeArtists];
        [self recomputeAlbums];
    }
    return self;
}

- (void) recomputeArtists
{
    // TODO caching
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *qArtists = [MPMediaQuery artistsQuery];
        NSArray *artists = [qArtists collections];
        NSMutableOrderedSet *orderedArtistSet = [NSMutableOrderedSet orderedSet];
        
        NSString *titleProperty = [MPMediaItem titlePropertyForGroupingType:MPMediaGroupingArtist];
        NSString *idProperty = [MPMediaItem persistentIDPropertyForGroupingType:MPMediaGroupingArtist];
        
        for (MPMediaItemCollection *artistGrouping in artists) {
            MPMediaItem *groupItem = [artistGrouping representativeItem];
            
            TBPLibraryItem *result = [[TBPLibraryItem alloc] init];
            result.title = [[groupItem valueForProperty:titleProperty] stringByCanonizingForMusicLibrary];
            result.persistentId = [groupItem valueForProperty:idProperty];
            
            [orderedArtistSet addObject:result];
        }
        
        self.artists = orderedArtistSet;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification object:nil];
    });
}

- (void) recomputeAlbums
{
    // TODO caching
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *qAlbums = [MPMediaQuery albumsQuery];
        NSArray *albums = [qAlbums collections];
        NSMutableOrderedSet *orderedAlbumSet = [NSMutableOrderedSet orderedSet];
        
        NSString *titleProperty = [MPMediaItem titlePropertyForGroupingType:MPMediaGroupingAlbum];
        NSString *idProperty = [MPMediaItem persistentIDPropertyForGroupingType:MPMediaGroupingAlbum];
        
        for (MPMediaItemCollection *albumGrouping in albums) {
            MPMediaItem *groupItem = [albumGrouping representativeItem];
            
            TBPLibraryItem *result = [[TBPLibraryItem alloc] init];
            result.title = [[groupItem valueForProperty:titleProperty] stringByCanonizingForMusicLibrary];
            result.persistentId = [groupItem valueForProperty:idProperty];
            
            [orderedAlbumSet addObject:result];
        }
        
        self.albums = orderedAlbumSet;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification object:nil];
    });
}

@end
