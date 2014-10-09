//
//  TBPAuthViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBPAuthViewController;

@protocol TBPAuthDelegate <NSObject>

- (void) authViewControllerDidSignIn: (TBPAuthViewController *)vcAuth;

@end

@interface TBPAuthViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) id <TBPAuthDelegate> delegate;

@end
