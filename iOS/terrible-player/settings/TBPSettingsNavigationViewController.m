//
//  TBPSettingsNavigationViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPSettingsNavigationViewController.h"
#import "TBPSettingsViewController.h"

@interface TBPSettingsNavigationViewController ()

@property (nonatomic, strong) TBPSettingsViewController *vcSettings;

@end

@implementation TBPSettingsNavigationViewController

- (id) init
{
    TBPSettingsViewController *vcSettings = [[TBPSettingsViewController alloc] init];
    
    if (self = [super initWithRootViewController:vcSettings]) {
        self.vcSettings = vcSettings;
        // _vcSettings.delegate = self;
        
        self.title = @"Cartridge";
    }
    return self;
}

@end
