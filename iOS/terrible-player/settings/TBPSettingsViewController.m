//
//  TBPSettingsViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPSettingsViewController.h"
#import "TBPConstants.h"
#import "TBPLastFMSession.h"

@interface TBPSettingsViewController ()

@property (nonatomic, strong) UILabel *lblSessionName;

- (void) onSessionChange;

@end

@implementation TBPSettingsViewController

- (id) init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSessionChange) name:kTBPLastFMSessionDidChangeNotification object:nil];
    }
    return self;
}

- (void) dealloc
{
    // [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // last.fm session name
    self.lblSessionName = [[UILabel alloc] init];
    _lblSessionName.font = [UIFont fontWithName:TBP_FONT size:20.0f];
    _lblSessionName.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
    [self.view addSubview:_lblSessionName];
    
    [self onSessionChange];
}

- (UIRectEdge) edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom ^ UIRectEdgeTop;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _lblSessionName.frame = CGRectMake(8.0f, 32.0f, self.view.frame.size.width - 16.0f, 32.0f);
}

- (void) onSessionChange
{
    _lblSessionName.text = [NSString stringWithFormat:@"last.fm: %@", [TBPLastFMSession sharedInstance].name];
}

@end
