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
#import "TBPLastFMAuthManager.h"

@interface TBPSettingsViewController ()

@property (nonatomic, strong) UIView *vSessionContainer;
@property (nonatomic, strong) UILabel *lblSessionHeading;
@property (nonatomic, strong) UILabel *lblSessionDetail;
@property (nonatomic, strong) UIButton *btnSignIn;
@property (nonatomic, strong) UIButton *btnSignOut;

@property (nonatomic, strong) UIView *vScrobbleContainer;
@property (nonatomic, strong) UILabel *lblScrobbles;
@property (nonatomic, strong) UISwitch *vScrobblesEnabled;

- (void) onSessionChange;
- (void) onTapSignIn;
- (void) onTapSignOut;
- (void) onTapScrobbleEnabled: (UIControl *)control;

@end

@implementation TBPSettingsViewController

- (id) init
{
    if (self = [super init]) {
        self.title = @"Settings";
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
    self.view.backgroundColor = [UIColor blackColor];
    
    // session container view
    self.vSessionContainer = [[UIView alloc] init];
    _vSessionContainer.backgroundColor = [UIColor clearColor];
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
    _btnSignIn.hidden = YES;
    [_vSessionContainer addSubview:_btnSignIn];
    
    // sign out button
    self.btnSignOut = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnSignOut.frame = _btnSignIn.frame;
    [_btnSignOut setImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
    [_btnSignOut addTarget:self action:@selector(onTapSignOut) forControlEvents:UIControlEventTouchUpInside];
    _btnSignOut.hidden = YES;
    [_vSessionContainer addSubview:_btnSignOut];
    
    // scrobble settings container
    self.vScrobbleContainer = [[UIView alloc] init];
    _vScrobbleContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_vScrobbleContainer];
    
    // scrobble settings label
    self.lblScrobbles = [[UILabel alloc] init];
    _lblScrobbles.text = @"Enable scrobbling";
    _lblScrobbles.font = [UIFont fontWithName:TBP_FONT size:16.0f];
    _lblScrobbles.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
    [_vScrobbleContainer addSubview:_lblScrobbles];
    
    // scrobbling enabled switch
    self.vScrobblesEnabled = [[UISwitch alloc] init];
    [_vScrobblesEnabled addTarget:self action:@selector(onTapScrobbleEnabled:) forControlEvents:UIControlEventValueChanged];
    [_vScrobbleContainer addSubview:_vScrobblesEnabled];
    
    // done button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_onTapDone)];
    
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
    _btnSignOut.center = _btnSignIn.center;
    _lblSessionHeading.frame = CGRectMake(12.0f, 8.0f, _btnSignIn.frame.origin.x - 24.0f, 32.0f);
    _lblSessionDetail.frame = CGRectMake(_lblSessionHeading.frame.origin.x, _lblSessionHeading.frame.origin.y + _lblSessionHeading.frame.size.height,
                                         _lblSessionHeading.frame.size.width, 16.0f);
    
    _vScrobbleContainer.frame = CGRectMake(0, _vSessionContainer.frame.origin.y + _vSessionContainer.frame.size.height,
                                           self.view.frame.size.width, 64.0f);
    _vScrobblesEnabled.center = CGPointMake(_vScrobbleContainer.frame.size.width - (_vScrobblesEnabled.frame.size.width * 0.5f) - 12.0f, _vScrobbleContainer.frame.size.height * 0.5f);
    _lblScrobbles.frame = CGRectMake(_lblSessionHeading.frame.origin.x, 0, _vScrobblesEnabled.frame.origin.x - 8.0f, _vScrobbleContainer.frame.size.height);
}


#pragma mark internal methods

- (void) onSessionChange
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([TBPLastFMSession sharedInstance].isLoggedIn) {
            self->_lblSessionHeading.text = [TBPLastFMSession sharedInstance].name;
            self->_lblSessionDetail.text = @"SIGNED IN WITH LAST.FM";
            self->_btnSignIn.hidden = YES;
            self->_btnSignOut.hidden = NO;
            self->_vScrobbleContainer.hidden = NO;
            if ([TBPLastFMSession sharedInstance].isScrobblingEnabled != self->_vScrobblesEnabled.isOn)
                [self->_vScrobblesEnabled setOn:[TBPLastFMSession sharedInstance].isScrobblingEnabled];
        } else {
            self->_lblSessionHeading.text = @"Welcome to Cartridge";
            self->_lblSessionDetail.text = @"SIGN IN WITH LAST.FM TO SCROBBLE";
            self->_btnSignIn.hidden = NO;
            self->_btnSignOut.hidden = YES;
            self->_vScrobbleContainer.hidden = YES;
        }
        [self->_vSessionContainer setNeedsDisplay];
    });
}

- (void) onTapSignIn
{
    if (![TBPLastFMSession sharedInstance].isLoggedIn) {
        if (_delegate) {
            [_delegate settingsViewControllerDidTapSignIn:self];
        }
    }
}

- (void) onTapSignOut
{
    if ([TBPLastFMSession sharedInstance].isLoggedIn) {
        [[TBPLastFMAuthManager sharedInstance] signOut];
    }
}

- (void) onTapScrobbleEnabled:(UIControl *)control
{
    if (self.isViewLoaded) {
        [TBPLastFMSession sharedInstance].isScrobblingEnabled = _vScrobblesEnabled.isOn;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBPLastFMSessionDidChangeNotification object:nil];
    }
}

- (void)_onTapDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
