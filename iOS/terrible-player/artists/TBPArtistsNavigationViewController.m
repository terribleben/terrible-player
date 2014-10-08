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
    // TODO do something
    NSLog(@"selected %@", artist.title);
}

@end
