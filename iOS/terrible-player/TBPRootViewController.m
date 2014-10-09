//
//  TBPRootViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPRootViewController.h"
#import "TBPArtistsNavigationViewController.h"
#import "TBPConstants.h"

@interface TBPRootViewController ()

@property (nonatomic, strong) TBPArtistsNavigationViewController *vcArtists;
@property (nonatomic, strong) UIView *vKillMe;

@property (nonatomic, assign) UIViewController *selectedViewController;

@end

@implementation TBPRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    
    // artists vc
    self.vcArtists = [[TBPArtistsNavigationViewController alloc] init];
    
    // placeholder now playing bar
    self.vKillMe = [[UIView alloc] init];
    _vKillMe.backgroundColor = UIColorFromRGB(TBP_COLOR_GREY_DEFAULT);
    [self.view addSubview:_vKillMe];
    
    self.selectedViewController = _vcArtists;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat nowPlayingBarHeight = 64.0f;
    _vKillMe.frame = CGRectMake(0, self.view.frame.size.height - nowPlayingBarHeight,
                                self.view.frame.size.width, nowPlayingBarHeight);
    self.selectedViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                                        self.view.frame.size.height - nowPlayingBarHeight);
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
