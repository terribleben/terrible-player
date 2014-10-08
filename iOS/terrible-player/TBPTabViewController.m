//
//  ViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPTabViewController.h"
#import "TBPArtistsNavigationViewController.h"
#import "TBPAlbumsNavigationViewController.h"

@interface TBPTabViewController ()

@property (nonatomic, strong) TBPArtistsNavigationViewController *vcArtists;
@property (nonatomic, strong) TBPAlbumsNavigationViewController *vcAlbums;

@end

@implementation TBPTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init each tab root
    self.vcArtists = [[TBPArtistsNavigationViewController alloc] init];
    self.vcAlbums = [[TBPAlbumsNavigationViewController alloc] init];
    
    // build list of tabs
    self.viewControllers = @[ _vcArtists, _vcAlbums ];
    
    // default to artists tab
    self.selectedViewController = _vcArtists;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
