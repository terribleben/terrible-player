//
//  TBPNavigationViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPNavigationViewController.h"

@interface TBPNavigationViewController ()

@end

@implementation TBPNavigationViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController]) {
        
    }
    return self;
}

- (void) didPopViewControllers:(NSArray *)controllers
{
    // override me!
}


#pragma mark inherited methods

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *popped = [super popViewControllerAnimated:animated];
    [self didPopViewControllers:@[ popped ]];
    return popped;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray *popped = [super popToViewController:viewController animated:animated];
    [self didPopViewControllers:popped];
    return popped;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray *popped = [super popToRootViewControllerAnimated:animated];
    [self didPopViewControllers:popped];
    return popped;
}

@end
