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
@property (nonatomic, strong) UIButton *btnSettings;
@property (nonatomic, strong) UIView *vCurrentTimeBackground;
@property (nonatomic, strong) UIView *vCurrentTimeProgress;

@property (nonatomic, strong) NSTimer *timerPlayback;

- (void) onModelChange: (NSNotification *)notification;
- (void) onTapPlayPause;
- (void) onTapNowPlaying;
- (void) onTapSettings;
- (void) updateCurrentPlaybackTime;

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
    _lblTitle.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapNowPlaying = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapNowPlaying)];
    [_lblTitle addGestureRecognizer:tapNowPlaying];
    
    [self.view addSubview:_lblTitle];
    
    // play button
    self.btnPlay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_btnPlay addTarget:self action:@selector(onTapPlayPause) forControlEvents:UIControlEventTouchUpInside];
    _btnPlay.hidden = YES;
    [self.view addSubview:_btnPlay];
    
    // pause button
    self.btnPause = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnPause setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [_btnPause addTarget:self action:@selector(onTapPlayPause) forControlEvents:UIControlEventTouchUpInside];
    _btnPause.hidden = YES;
    [self.view addSubview:_btnPause];
    
    // settings button
    self.btnSettings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnSettings setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [_btnSettings addTarget:self action:@selector(onTapSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSettings];
    
    // current time bar background
    self.vCurrentTimeBackground = [[UIView alloc] init];
    _vCurrentTimeBackground.userInteractionEnabled = NO;
    _vCurrentTimeBackground.backgroundColor = UIColorFromRGB(TBP_COLOR_GREY_SELECTED);
    [self.view addSubview:_vCurrentTimeBackground];
    
    // current time bar progress
    self.vCurrentTimeProgress = [[UIView alloc] init];
    _vCurrentTimeProgress.backgroundColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
    [_vCurrentTimeBackground addSubview:_vCurrentTimeProgress];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat currentTimeBarHeight = 4.0f;
    
    CGFloat sqrSide = MIN(32.0f, MAX(4.0f, (self.view.frame.size.height - currentTimeBarHeight) * 0.95f));
    _btnSettings.frame = CGRectMake(0, 0, sqrSide * 0.9f, sqrSide * 0.9f);
    _btnSettings.center = CGPointMake(self.view.frame.size.width - 8.0f - (sqrSide * 0.5f), (self.view.frame.size.height - currentTimeBarHeight) * 0.5f);
    
    _btnPlay.frame = CGRectMake(0, 0, sqrSide, sqrSide);
    _btnPlay.center = CGPointMake(_btnSettings.center.x - 8.0f - sqrSide, _btnSettings.center.y);
    _btnPause.frame = _btnPlay.frame;
    _lblTitle.frame = CGRectMake(8.0f, 0, _btnPlay.frame.origin.x - 16.0f, self.view.frame.size.height - currentTimeBarHeight);
    
    _vCurrentTimeBackground.frame = CGRectMake(0, self.view.frame.size.height - currentTimeBarHeight,
                                               self.view.frame.size.width, currentTimeBarHeight);
    _vCurrentTimeProgress.frame = CGRectMake(0, 0, _vCurrentTimeProgress.frame.size.width, currentTimeBarHeight);
}


#pragma mark internal methods

- (void) reload
{
    self.nowPlayingItem = [TBPLibraryModel sharedInstance].nowPlayingItem;
    BOOL isPlaying = [TBPLibraryModel sharedInstance].isPlaying;
    
    // if playing, schedule a timer to read the current playback time
    if (isPlaying) {
        if (_timerPlayback) {
            [_timerPlayback invalidate];
            _timerPlayback = nil;
        }
        _timerPlayback = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCurrentPlaybackTime)
                                                        userInfo:nil repeats:YES];
    }
    
    // update UI
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_nowPlayingItem) {
            _lblTitle.text = _nowPlayingItem.title;
            _btnPlay.hidden = isPlaying;
            _btnPause.hidden = !isPlaying;
            _vCurrentTimeBackground.hidden = NO;
        } else {
            _lblTitle.text = nil;
            _btnPlay.hidden = YES;
            _btnPause.hidden = YES;
            _vCurrentTimeBackground.hidden = YES;
        }
        
        [self.view setNeedsDisplay];
    });
}

- (void) onTapPlayPause
{
    [[TBPLibraryModel sharedInstance] playPause];
}

- (void) onTapNowPlaying
{
    if (_delegate) {
        [_delegate nowPlayingBarDidSelectNowPlaying:self];
    }
}

- (void) onTapSettings
{
    if (_delegate) {
        [_delegate nowPlayingBarDidSelectSettings:self];
    }
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

- (void) updateCurrentPlaybackTime
{
    CGFloat currentPlaybackTime = [TBPLibraryModel sharedInstance].nowPlayingProgress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _vCurrentTimeProgress.frame = CGRectMake(_vCurrentTimeProgress.frame.origin.x, _vCurrentTimeProgress.frame.origin.y,
                                                 _vCurrentTimeBackground.frame.size.width * currentPlaybackTime, _vCurrentTimeProgress.frame.size.height);
        [_vCurrentTimeBackground setNeedsDisplay];
    });
}

@end
