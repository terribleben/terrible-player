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

- (void) recompute;

@property (nonatomic, strong) NSMutableOrderedSet *artists;
@property (nonatomic, strong) NSMutableOrderedSet *albums;

/**
 *  Artist persistent id => albums
 */
@property (nonatomic, strong) NSMutableDictionary *albumsByArtist;

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
        [self recompute];
    }
    return self;
}

- (NSOrderedSet *)albumsForArtistWithId:(NSNumber *)artistPersistentId
{
    if (_albumsByArtist)
        return [_albumsByArtist objectForKey:artistPersistentId];
    return nil;
}

- (NSOrderedSet *)tracksForAlbumWithId:(NSNumber *)albumPersistentId
{
    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:albumPersistentId
                                                                                forProperty:MPMediaItemPropertyAlbumPersistentID];
    MPMediaQuery *albumQuery = [[MPMediaQuery alloc] init];
    [albumQuery addFilterPredicate:albumPredicate];
    // [albumQuery setGroupingType:MPMediaGroupingTitle];
    
    NSMutableOrderedSet *tracks = [NSMutableOrderedSet orderedSet];
    for (MPMediaItem *item in albumQuery.items) {
        TBPLibraryItem *result = [TBPLibraryItem itemWithMediaItem:item grouping:MPMediaGroupingTitle];
        [tracks addObject:result];
    }
    return tracks;
}


#pragma mark internal methods

- (void) recompute
{
    // TODO caching
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableOrderedSet *orderedArtistSet = [NSMutableOrderedSet orderedSet];
        NSMutableOrderedSet *orderedAlbumSet = [NSMutableOrderedSet orderedSet];
        NSMutableDictionary *artistAlbumMap = [NSMutableDictionary dictionary];
        
        // recompute index of artists
        MPMediaQuery *qArtists = [MPMediaQuery artistsQuery];
        NSArray *artists = [qArtists collections];
        
        for (MPMediaItemCollection *artistGrouping in artists) {
            MPMediaItem *groupItem = [artistGrouping representativeItem];
            
            TBPLibraryItem *result = [TBPLibraryItem itemWithMediaItem:groupItem grouping:MPMediaGroupingArtist];
            
            // start with an empty list of albums for this artist
            [artistAlbumMap setObject:[NSMutableOrderedSet orderedSet] forKey:result.persistentId];
            
            // add artist to index
            [orderedArtistSet addObject:result];
        }
        
        // recompute index of albums
        MPMediaQuery *qAlbums = [MPMediaQuery albumsQuery];
        NSArray *albums = [qAlbums collections];
        
        for (MPMediaItemCollection *albumGrouping in albums) {
            MPMediaItem *groupItem = [albumGrouping representativeItem];
            
            TBPLibraryItem *result = [TBPLibraryItem itemWithMediaItem:groupItem grouping:MPMediaGroupingAlbum];
            
            // add album to list of albums by artist
            NSNumber *artistId = [groupItem valueForProperty:MPMediaItemPropertyArtistPersistentID];
            if ([artistAlbumMap objectForKey:artistId]) {
                NSMutableOrderedSet *byArtist = [artistAlbumMap objectForKey:artistId];
                [byArtist addObject:result];
            }
            
            // add to overall album index
            [orderedAlbumSet addObject:result];
        }
        
        self.albums = orderedAlbumSet;
        self.artists = orderedArtistSet;
        self.albumsByArtist = artistAlbumMap;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLibraryModelDidChangeNotification object:nil];
    });
}

@end
