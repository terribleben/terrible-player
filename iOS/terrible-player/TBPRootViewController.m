//
//  TBPRootViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPRootViewController.h"
#import "TBPArtistsNavigationViewController.h"
#import "TBPSettingsNavigationViewController.h"
#import "TBPConstants.h"
#import "TBPActivityIndicatorView.h"

@interface TBPRootViewController ()

@property (nonatomic, strong) TBPArtistsNavigationViewController *vcArtists;
@property (nonatomic, strong) TBPSettingsNavigationViewController *vcSettings;
@property (nonatomic, strong) TBPNowPlayingBarViewController *vcNowPlaying;

@property (nonatomic, assign) UIViewController *selectedViewController;
@property (nonatomic, strong) UIView *vLoadingOverlay;
@property (nonatomic, strong) TBPActivityIndicatorView *vLoadingWheel;

- (void) beginLoading;
- (void) endLoading;

@end

@implementation TBPRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    
    // loading overlay
    self.vLoadingOverlay = [[UIView alloc] init];
    _vLoadingOverlay.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    _vLoadingOverlay.alpha = 0;
    _vLoadingOverlay.userInteractionEnabled = NO;
    [self.view addSubview:_vLoadingOverlay];
    
    // loading wheel
    self.vLoadingWheel = [[TBPActivityIndicatorView alloc] initWithActivityIndicatorViewStyle:kTBPActivityIndicatorViewStyleLarge];
    [_vLoadingOverlay addSubview:_vLoadingWheel];
    
    // artists vc
    self.vcArtists = [[TBPArtistsNavigationViewController alloc] init];
    
    // settings vc
    self.vcSettings = [[TBPSettingsNavigationViewController alloc] init];
    
    // placeholder now playing bar
    self.vcNowPlaying = [[TBPNowPlayingBarViewController alloc] init];
    _vcNowPlaying.delegate = self;
    [self.view addSubview:_vcNowPlaying.view];
    
    self.selectedViewController = _vcArtists;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _vLoadingOverlay.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _vLoadingWheel.center = CGPointMake(_vLoadingOverlay.frame.size.width * 0.5f, _vLoadingOverlay.frame.size.height * 0.5f);
    
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

- (void) libraryDidBeginReload:(TBPLibraryModel *)library
{
    [self beginLoading];
}

- (void) libraryDidEndReload:(TBPLibraryModel *)library
{
    [self endLoading];
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
    
    [self.view bringSubviewToFront:_vLoadingOverlay];
    [self.view setNeedsLayout];
}

- (void) beginLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_vLoadingWheel startAnimating];
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _vLoadingOverlay.alpha = 1.0f;
        } completion:nil];
    });
}

- (void) endLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_vLoadingWheel stopAnimating];
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _vLoadingOverlay.alpha = 0.0f;
        } completion:nil];
    });
}

@end
