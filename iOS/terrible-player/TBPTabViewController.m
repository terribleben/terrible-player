//
//  ViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPTabViewController.h"
#import "TBPArtistsViewController.h"

@interface TBPTabViewController ()

@property (nonatomic, strong) TBPArtistsViewController *vcArtists;

@end

@implementation TBPTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // inict each tab root
    self.vcArtists = [[TBPArtistsViewController alloc] init];
    
    // build list of tabs
    self.viewControllers = @[ _vcArtists ];
    
    // default to artists tab
    self.selectedViewController = _vcArtists;
}

@end
