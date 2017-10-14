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
#import "TBPLastFMSession.h"
#import "TBPDatabase.h"

#import <RKLog.h>

@import AVFoundation;

@interface AppDelegate ()

@property (nonatomic, strong) TBPRootViewController *vcRoot;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (void) setUIAppearance;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // configure restkit logging
    RKLogConfigureByName("RestKit", RKLogLevelOff);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelOff);
    RKLogConfigureByName("RestKit/Network", RKLogLevelOff);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    
    // init coredata
    [TBPDatabase sharedInstance];
    
    // init music library
    [TBPLibraryModel sharedInstance];
    
    // hook up main view controller
    self.vcRoot = [[TBPRootViewController alloc] init];
    [TBPLibraryModel sharedInstance].delegate = _vcRoot;
    self.window.rootViewController = _vcRoot;
    
    // configure global UI appearance
    [self setUIAppearance];
    
    [self.window makeKeyAndVisible];
    [self shittyPlayBackgroundSound];
    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    [[TBPLibraryModel sharedInstance] readMediaLibrary];
    NSLog(@"app entered foreground");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"app entered background");
}

- (void) setUIAppearance
{
    [[UIButton appearance] setTintColor:UIColorFromRGB(TBP_COLOR_ACTION)];
}

- (void)shittyPlayBackgroundSound
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"silence" ofType:@"wav"]];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    _audioPlayer.numberOfLoops = -1;
    [_audioPlayer play];
}

@end
