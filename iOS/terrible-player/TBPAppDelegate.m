//
//  AppDelegate.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPAppDelegate.h"
#import "TBPRootViewController.h"
#import "TBPLibraryModel.h"
#import "TBPConstants.h"

@interface AppDelegate ()

@property (nonatomic, strong) TBPRootViewController *vcRoot;

- (void) setUIAppearance;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    
    // init music library
    [TBPLibraryModel sharedInstance];
    
    // hook up main view controller
    self.vcRoot = [[TBPRootViewController alloc] init];
    self.window.rootViewController = _vcRoot;
    
    // configure global UI appearance
    [self setUIAppearance];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) setUIAppearance
{

}

@end
