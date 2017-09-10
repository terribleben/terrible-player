//
//  TBPAuthViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPAuthViewController.h"
#import "TBPLastFMAuthManager.h"
#import "TBPConstants.h"

#import <TPKeyboardAvoidingScrollView.h>

@interface TBPTextField : UITextField

@end

@implementation TBPTextField

- (void)drawPlaceholderInRect:(CGRect)rect
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 };
    [[self placeholder] drawInRect:CGRectInset(rect, 0, (rect.size.height - self.font.lineHeight) / 2.0) withAttributes:attributes];
}

@end

@interface TBPAuthViewController ()

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *vContainer;
@property (nonatomic, strong) UILabel *lblHeading;
@property (nonatomic, strong) TBPTextField *vUsername;
@property (nonatomic, strong) TBPTextField *vPassword;
@property (nonatomic, strong) UIButton *btnSubmit;
@property (nonatomic, strong) UIActivityIndicatorView *vLoading;

- (void) onTapSubmit;
- (void) beginLoading;
- (void) endLoading;

@end

@implementation TBPAuthViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    
    // container view
    self.vContainer = [[TPKeyboardAvoidingScrollView alloc] init];
    [self.view addSubview:_vContainer];
    
    // heading label
    self.lblHeading = [[UILabel alloc] init];
    _lblHeading.text = @"Sign In With Last.fm";
    _lblHeading.font = [UIFont fontWithName:TBP_FONT_LIGHT size:24.0f];
    _lblHeading.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
    [_vContainer addSubview:_lblHeading];
    
    // username text field
    self.vUsername = [[TBPTextField alloc] init];
    _vUsername.placeholder = @"Last.fm Username";
    _vUsername.returnKeyType = UIReturnKeyNext;
    [_vContainer addSubview:_vUsername];
    
    // password text field
    self.vPassword = [[TBPTextField alloc] init];
    _vPassword.placeholder = @"Last.fm Password";
    _vPassword.returnKeyType = UIReturnKeyGo;
    _vPassword.secureTextEntry = YES;
    [_vContainer addSubview:_vPassword];
    
    for (UITextField *textField in @[ _vUsername, _vPassword ]) {
        textField.delegate = self;
        textField.borderStyle = UITextBorderStyleLine;
        textField.layer.borderColor = UIColorFromRGB(TBP_COLOR_GREY_SELECTED).CGColor;
        textField.layer.borderWidth = 2.0f;
        textField.backgroundColor = UIColorFromRGB(TBP_COLOR_GREY_DEFAULT);
        textField.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
    }
    
    // submit button
    self.btnSubmit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnSubmit setTitle:@"Sign In" forState:UIControlStateNormal];
    [_btnSubmit addTarget:self action:@selector(onTapSubmit) forControlEvents:UIControlEventTouchUpInside];
    [_vContainer addSubview:_btnSubmit];
    
    // loading indicator
    self.vLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _vLoading.hidden = YES;
    [_vContainer addSubview:_vLoading];
}

- (UIRectEdge) edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom ^ UIRectEdgeTop;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // reset UI
    _vUsername.text = nil;
    _vPassword.text = nil;
    [self endLoading];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _vContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _lblHeading.frame = CGRectMake(12.0f, 16.0f, _vContainer.frame.size.width - 24.0f, 32.0f);
    _vUsername.frame = CGRectMake(_lblHeading.frame.origin.x, _lblHeading.frame.origin.y + _lblHeading.frame.size.height + 16.0f,
                                  _lblHeading.frame.size.width, 48.0f);
    _vPassword.frame = CGRectMake(_lblHeading.frame.origin.x, _vUsername.frame.origin.y + _vUsername.frame.size.height + 16.0f,
                                  _lblHeading.frame.size.width, 48.0f);
    _btnSubmit.frame = CGRectMake(_lblHeading.frame.origin.x, _vPassword.frame.origin.y + _vPassword.frame.size.height + 16.0f,
                                  _lblHeading.frame.size.width, 32.0f);
    _vLoading.center = _btnSubmit.center;
    
    _vContainer.contentSize = CGSizeMake(_vContainer.frame.size.width, _btnSubmit.frame.origin.y + _btnSubmit.frame.size.height + 16.0f);
}


#pragma mark delegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _vUsername) {
        [_vUsername resignFirstResponder];
        [_vPassword becomeFirstResponder];
    } else if (textField == _vPassword) {
        [_vPassword resignFirstResponder];
        [self onTapSubmit];
    }
    return NO;
}


#pragma mark internal methods

- (void) onTapSubmit
{
    if (self.isViewLoaded) {
        if (_vUsername.text && _vUsername.text.length && _vPassword && _vPassword.text.length) {
            [self beginLoading];
            [[TBPLastFMAuthManager sharedInstance] authenticateWithUsername:_vUsername.text password:_vPassword.text success:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self endLoading];
                    if (_delegate) {
                        [_delegate authViewControllerDidSignIn:self];
                    }
                });
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self endLoading];
                    NSLog(@"TBPAuthViewController failed to sign in: %@", error);
                });
            }];
        }
    }
}

- (void) beginLoading
{
    _btnSubmit.hidden = YES;
    _vLoading.hidden = NO;
    [_vLoading startAnimating];
}

- (void) endLoading
{
    _btnSubmit.hidden = NO;
    _vLoading.hidden = YES;
    [_vLoading stopAnimating];
}

@end
