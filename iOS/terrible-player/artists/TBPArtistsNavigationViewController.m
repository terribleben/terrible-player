//
//  TBPArtistsNavigationViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPArtistsNavigationViewController.h"

@interface TBPArtistsNavigationViewController ()

@property (nonatomic, strong) TBPArtistsViewController *vcArtists;
@property (nonatomic, strong) TBPAlbumsViewController *vcAlbums;

@end

@implementation TBPArtistsNavigationViewController

- (id) init
{
    TBPArtistsViewController *vcArtists = [[TBPArtistsViewController alloc] init];
    
    if (self = [super initWithRootViewController:vcArtists]) {
        self.vcArtists = vcArtists;
        _vcArtists.delegate = self;
        
        self.title = @"Artists";
    }
    return self;
}


#pragma mark delegate methods

- (void) artistsViewController:(TBPArtistsViewController *)vcArtists didSelectArtist:(TBPLibraryItem *)artist
{
    if (!_vcAlbums) {
        _vcAlbums = [[TBPAlbumsViewController alloc] init];
        _vcAlbums.delegate = self;
    }
    
    if (self.visibleViewController == _vcArtists) {
        _vcAlbums.artist = artist;
        [self pushViewController:_vcAlbums animated:YES];
    }
}

- (void) albumsViewController:(TBPAlbumsViewController *)vcAlbums didSelectAlbum:(TBPLibraryItem *)album
{
    // TODO do something
    NSLog(@"selected %@", album.title);
}

@end
