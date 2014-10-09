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

@property (nonatomic, strong) UILabel *lblSessionHeading;
@property (nonatomic, strong) UILabel *lblSessionDetail;

- (void) onSessionChange;

@end

@implementation TBPSettingsViewController

- (id) init
{
    if (self = [super init]) {
        self.title = @"Cartridge";
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
    
    // session heading
    self.lblSessionHeading = [[UILabel alloc] init];
    _lblSessionHeading.font = [UIFont fontWithName:TBP_FONT_LIGHT size:24.0f];
    _lblSessionHeading.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
    [self.view addSubview:_lblSessionHeading];
    
    // session detail
    self.lblSessionDetail = [[UILabel alloc] init];
    _lblSessionDetail.font = [UIFont fontWithName:TBP_FONT size:10.0f];
    _lblSessionDetail.textColor = UIColorFromRGB(TBP_COLOR_TEXT_DIM);
    [self.view addSubview:_lblSessionDetail];
    
    [self onSessionChange];
}

- (UIRectEdge) edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom ^ UIRectEdgeTop;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _lblSessionHeading.frame = CGRectMake(12.0f, 8.0f, self.view.frame.size.width - 24.0f, 32.0f);
    _lblSessionDetail.frame = CGRectMake(_lblSessionHeading.frame.origin.x, _lblSessionHeading.frame.origin.y + _lblSessionHeading.frame.size.height,
                                         _lblSessionHeading.frame.size.width, 16.0f);
}

- (void) onSessionChange
{
    if ([TBPLastFMSession sharedInstance].isLoggedIn) {
        _lblSessionHeading.text = [TBPLastFMSession sharedInstance].name;
        _lblSessionDetail.text = @"SIGNED IN WITH LAST.FM";
    } else {
        _lblSessionHeading.text = @"Welcome to Cartridge";
        _lblSessionDetail.text = @"SIGN IN WITH LAST.FM TO SCROBBLE";
    }
}

@end
