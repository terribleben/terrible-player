//
//  TBPRootViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPRootViewController.h"
#import "TBPArtistsNavigationViewController.h"
#import "TBPSettingsViewController.h"
#import "TBPConstants.h"

@interface TBPRootViewController ()

@property (nonatomic, strong) TBPArtistsNavigationViewController *vcArtists;
@property (nonatomic, strong) TBPSettingsViewController *vcSettings;
@property (nonatomic, strong) TBPNowPlayingBarViewController *vcNowPlaying;

@property (nonatomic, assign) UIViewController *selectedViewController;

@end

@implementation TBPRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    
    // artists vc
    self.vcArtists = [[TBPArtistsNavigationViewController alloc] init];
    
    // settings vc
    self.vcSettings = [[TBPSettingsViewController alloc] init];
    
    // placeholder now playing bar
    self.vcNowPlaying = [[TBPNowPlayingBarViewController alloc] init];
    _vcNowPlaying.delegate = self;
    [self.view addSubview:_vcNowPlaying.view];
    
    self.selectedViewController = _vcArtists;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _vcNowPlaying.view.frame = CGRectMake(0, self.view.frame.size.height - TBP_NOW_PLAYING_BAR_HEIGHT,
                                          self.view.frame.size.width, TBP_NOW_PLAYING_BAR_HEIGHT);

    self.selectedViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                                        self.view.frame.size.height - TBP_NOW_PLAYING_BAR_HEIGHT);
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark delegate methods

- (void) nowPlayingBarDidSelectPlayPause:(TBPNowPlayingBarViewController *)vcNowPlaying
{
    // do nothing
}

- (void) nowPlayingBarDidSelectNowPlaying:(TBPNowPlayingBarViewController *)vcNowPlaying
{
    if (_selectedViewController != _vcArtists)
        self.selectedViewController = _vcArtists;
    
    [_vcArtists pushNowPlaying];
}

- (void) nowPlayingBarDidSelectSettings:(TBPNowPlayingBarViewController *)vcNowPlaying
{
    self.selectedViewController = _vcSettings;
}


#pragma mark internal methods

- (void) setSelectedViewController:(UIViewController *)selectedViewController
{
    if (_selectedViewController) {
        [_selectedViewController viewWillDisappear:NO];
        [_selectedViewController.view removeFromSuperview];
        [_selectedViewController viewDidDisappear:NO];
    }
    
    _selectedViewController = selectedViewController;
    
    if (_selectedViewController) {
        [_selectedViewController viewWillAppear:NO];
        [self.view addSubview:_selectedViewController.view];
        [_selectedViewController viewDidAppear:NO];
    }
    
    [self.view setNeedsLayout];
}

@end
