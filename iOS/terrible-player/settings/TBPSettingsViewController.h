//
//  TBPSettingsViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBPSettingsViewController;

@protocol TBPSettingsDelegate <NSObject>

- (void) settingsViewControllerDidTapSignIn: (TBPSettingsViewController *)vcSettings;

@end

@interface TBPSettingsViewController : UIViewController

@property (nonatomic, assign) id <TBPSettingsDelegate> delegate;

@end
