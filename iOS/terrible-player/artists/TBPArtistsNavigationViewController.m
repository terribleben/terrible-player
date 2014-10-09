//
//  TBPArtistsNavigationViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPArtistsNavigationViewController.h"
#import "TBPLibraryModel.h"

@interface TBPArtistsNavigationViewController ()

@property (nonatomic, strong) TBPArtistsViewController *vcArtists;
@property (nonatomic, strong) TBPAlbumsViewController *vcAlbums;
@property (nonatomic, strong) TBPAlbumViewController *vcAlbum;
@property (nonatomic, strong) TBPAlbumViewController *vcNowPlaying; // can be pushed any time

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


#pragma mark external methods

- (BOOL) pushNowPlaying
{
    TBPLibraryItem *nowPlayingAlbum = [TBPLibraryModel sharedInstance].nowPlayingAlbumCache;
    if (nowPlayingAlbum) {
        if ((_vcNowPlaying && self.visibleViewController == _vcNowPlaying) ||
            (_vcAlbum && self.visibleViewController == _vcAlbum && [_vcAlbum.album isEqual:nowPlayingAlbum])) {
            // we're already on the correct album.
        } else {
            if (!_vcNowPlaying) {
                self.vcNowPlaying = [[TBPAlbumViewController alloc] init];
                _vcNowPlaying.delegate = self;
            }
            _vcNowPlaying.album = nowPlayingAlbum;
            [self pushViewController:_vcNowPlaying animated:YES];
            return YES;
        }
    }
    return NO;
}


#pragma mark internal methods

- (void) didPopViewControllers:(NSArray *)controllers
{
    [super didPopViewControllers:controllers];
    
    // free up whatever we can
    for (UIViewController *controller in controllers) {
        if (controller == _vcNowPlaying)
            _vcNowPlaying.album = nil;
        else if (controller == _vcAlbum)
            _vcAlbum.album = nil;
        else if (controller == _vcAlbums)
            _vcAlbums.artist = nil;
    }
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
    if (!_vcAlbum) {
        _vcAlbum = [[TBPAlbumViewController alloc] init];
        _vcAlbum.delegate = self;
    }
    
    if (self.visibleViewController == _vcAlbums) {
        _vcAlbum.album = album;
        [self pushViewController:_vcAlbum animated:YES];
    }
}

- (void) albumViewController:(TBPAlbumViewController *)vcAlbum didSelectTrack:(TBPLibraryItem *)track
{
    // play the current album at the selected track
    [[TBPLibraryModel sharedInstance] playTrackWithId:track.persistentId inAlbum:vcAlbum.album];
}

@end
