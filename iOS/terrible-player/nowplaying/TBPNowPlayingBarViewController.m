//
//  TBPNowPlayingBarViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPNowPlayingBarViewController.h"
#import "TBPConstants.h"
#import "TBPLibraryModel.h"

@interface TBPNowPlayingBarViewController ()

@property (nonatomic, strong) TBPLibraryItem *nowPlayingItem;

@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIButton *btnPlay;
@property (nonatomic, strong) UIButton *btnPause;

- (void) onModelChange: (NSNotification *)notification;
- (void) onTapPlayPause;

@end

@implementation TBPNowPlayingBarViewController

- (id) init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModelChange:) name:kTBPLibraryModelDidChangeNotification object:nil];
    }
    return self;
}

- (void) dealloc
{
    // [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(TBP_COLOR_GREY_DEFAULT);
    
    // now playing title label
    self.lblTitle = [[UILabel alloc] init];
    _lblTitle.font = [UIFont fontWithName:TBP_FONT size:16.0f];
    _lblTitle.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
    [self.view addSubview:_lblTitle];
    
    // play button
    self.btnPlay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_btnPlay addTarget:self action:@selector(onTapPlayPause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnPlay];
    
    // pause button
    self.btnPause = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnPause setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [_btnPause addTarget:self action:@selector(onTapPlayPause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnPause];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat sqrSide = MIN(32.0f, MAX(4.0f, self.view.frame.size.height * 0.9f));
    _btnPlay.frame = CGRectMake(0, 0, sqrSide, sqrSide);
    _btnPlay.center = CGPointMake(self.view.frame.size.width - 8.0f - (sqrSide * 0.5f), self.view.frame.size.height * 0.5f);
    _btnPause.frame = _btnPlay.frame;
    _lblTitle.frame = CGRectMake(8.0f, 0, _btnPlay.frame.origin.x - 16.0f, self.view.frame.size.height);
}


#pragma mark internal methods

- (void) reload
{
    self.nowPlayingItem = [TBPLibraryModel sharedInstance].nowPlayingItem;
    BOOL isPlaying = [TBPLibraryModel sharedInstance].isPlaying;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_nowPlayingItem) {
            _lblTitle.text = _nowPlayingItem.title;
            _btnPlay.hidden = isPlaying;
            _btnPause.hidden = !isPlaying;
        } else {
            _lblTitle.text = nil;
            _btnPlay.hidden = YES;
            _btnPause.hidden = YES;
        }
        
        [self.view setNeedsDisplay];
    });
}

- (void) onTapPlayPause
{
    [[TBPLibraryModel sharedInstance] playPause];
}

- (void) onModelChange:(NSNotification *)notification
{
    NSNumber *changeReasonObj = (NSNumber *) notification.object;
    NSUInteger changeReason = (changeReasonObj) ? [changeReasonObj unsignedIntegerValue] : kTBPLibraryModelChangeUnknown;
    if (((changeReason & kTBPLibraryModelChangePlaybackState) != 0)
        || ((changeReason & kTBPLibraryModelChangeNowPlaying) != 0)) {
        [self reload];
    }
}

@end
