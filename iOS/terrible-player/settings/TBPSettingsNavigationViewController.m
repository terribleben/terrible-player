//
//  TBPSettingsNavigationViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPSettingsNavigationViewController.h"

@interface TBPSettingsNavigationViewController ()

@property (nonatomic, strong) TBPSettingsViewController *vcSettings;
@property (nonatomic, strong) TBPAuthViewController *vcAuth;

@end

@implementation TBPSettingsNavigationViewController

- (id) init
{
    TBPSettingsViewController *vcSettings = [[TBPSettingsViewController alloc] init];
    
    if (self = [super initWithRootViewController:vcSettings]) {
        self.vcSettings = vcSettings;
        _vcSettings.delegate = self;
        
        self.title = @"Cartridge";
    }
    return self;
}


#pragma mark delegate methods

- (void) settingsViewControllerDidTapSignIn:(TBPSettingsViewController *)vcSettings
{
    if (!_vcAuth) {
        self.vcAuth = [[TBPAuthViewController alloc] init];
        _vcAuth.delegate = self;
    }
    
    if (self.visibleViewController == _vcSettings) {
        [self pushViewController:_vcAuth animated:YES];
    }
}

- (void) authViewControllerDidSignIn:(TBPAuthViewController *)vcAuth
{
    [self popToRootViewControllerAnimated:YES];
}

@end
