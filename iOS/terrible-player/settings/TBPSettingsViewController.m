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

@property (nonatomic, strong) UIView *vSessionContainer;
@property (nonatomic, strong) UILabel *lblSessionHeading;
@property (nonatomic, strong) UILabel *lblSessionDetail;
@property (nonatomic, strong) UIButton *btnSignIn;

- (void) onSessionChange;
- (void) onTapSignIn;

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
    
    // session container view
    self.vSessionContainer = [[UIView alloc] init];
    _vSessionContainer.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    [self.view addSubview:_vSessionContainer];
    
    UITapGestureRecognizer *tapSession = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapSignIn)];
    [_vSessionContainer addGestureRecognizer:tapSession];
    
    // session heading
    self.lblSessionHeading = [[UILabel alloc] init];
    _lblSessionHeading.font = [UIFont fontWithName:TBP_FONT_LIGHT size:24.0f];
    _lblSessionHeading.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
    [_vSessionContainer addSubview:_lblSessionHeading];
    
    // session detail
    self.lblSessionDetail = [[UILabel alloc] init];
    _lblSessionDetail.font = [UIFont fontWithName:TBP_FONT size:10.0f];
    _lblSessionDetail.textColor = UIColorFromRGB(TBP_COLOR_TEXT_DIM);
    [_vSessionContainer addSubview:_lblSessionDetail];
    
    // sign in button
    self.btnSignIn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnSignIn.frame = CGRectMake(0, 0, 32.0f, 32.0f);
    [_btnSignIn setImage:[UIImage imageNamed:@"login"] forState:UIControlStateNormal];
    [_btnSignIn addTarget:self action:@selector(onTapSignIn) forControlEvents:UIControlEventTouchUpInside];
    [_vSessionContainer addSubview:_btnSignIn];
    
    [self onSessionChange];
}

- (UIRectEdge) edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom ^ UIRectEdgeTop;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _vSessionContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, 64.0f);
    _btnSignIn.center = CGPointMake(_vSessionContainer.frame.size.width - 28.0f, _vSessionContainer.frame.size.height * 0.5f);
    _lblSessionHeading.frame = CGRectMake(12.0f, 8.0f, _btnSignIn.frame.origin.x - 24.0f, 32.0f);
    _lblSessionDetail.frame = CGRectMake(_lblSessionHeading.frame.origin.x, _lblSessionHeading.frame.origin.y + _lblSessionHeading.frame.size.height,
                                         _lblSessionHeading.frame.size.width, 16.0f);
}


#pragma mark internal methods

- (void) onSessionChange
{
    if ([TBPLastFMSession sharedInstance].isLoggedIn) {
        _lblSessionHeading.text = [TBPLastFMSession sharedInstance].name;
        _lblSessionDetail.text = @"SIGNED IN WITH LAST.FM";
        _btnSignIn.hidden = YES;
    } else {
        _lblSessionHeading.text = @"Welcome to Cartridge";
        _lblSessionDetail.text = @"SIGN IN WITH LAST.FM TO SCROBBLE";
        _btnSignIn.hidden = NO;
    }
}

- (void) onTapSignIn
{
    if (![TBPLastFMSession sharedInstance].isLoggedIn) {
        if (_delegate) {
            [_delegate settingsViewControllerDidTapSignIn:self];
        }
    }
}

@end
