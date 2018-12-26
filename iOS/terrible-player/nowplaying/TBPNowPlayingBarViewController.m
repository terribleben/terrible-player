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
#import "TBPPlayPauseView.h"

@interface TBPNowPlayingBarViewController ()

@property (nonatomic, strong) TBPLibraryItem *nowPlayingItem;

@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) TBPPlayPauseView *vPlayPause;
@property (nonatomic, strong) UIView *vCurrentTimeBackground;
@property (nonatomic, strong) UIView *vCurrentTimeProgress;

@property (nonatomic, strong) NSTimer *timerPlayback;

- (void) onModelChange: (NSNotification *)notification;
- (void) onTapPlayPause;
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
    [self.view addSubview:_lblTitle];
    
    // play/pause button
    self.vPlayPause = [[TBPPlayPauseView alloc] init];
    _vPlayPause.hidden = YES;
    
    UITapGestureRecognizer *tapPlayPause = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapPlayPause)];
    [_vPlayPause addGestureRecognizer:tapPlayPause];
    
    [self.view addSubview:_vPlayPause];

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
    
    _vPlayPause.frame = CGRectMake(0, 0, sqrSide, sqrSide);
    _vPlayPause.center = CGPointMake(self.view.frame.size.width - 8.0f - (sqrSide * 0.5f), (self.view.frame.size.height - currentTimeBarHeight) * 0.5f);
    _lblTitle.frame = CGRectMake(8.0f, 0, _vPlayPause.frame.origin.x - 16.0f, self.view.frame.size.height - currentTimeBarHeight);
    
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
    if (_timerPlayback) {
        [_timerPlayback invalidate];
        _timerPlayback = nil;
    }
    if (isPlaying) {
        _timerPlayback = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCurrentPlaybackTime)
                                                        userInfo:nil repeats:YES];
    }
    
    // update UI
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_nowPlayingItem) {
            self->_lblTitle.text = self->_nowPlayingItem.title;
            self->_vCurrentTimeProgress.hidden = NO;
            self->_vPlayPause.hidden = NO;
            self->_vPlayPause.isPlaying = isPlaying;
        } else {
            self->_lblTitle.text = nil;
            self->_vPlayPause.hidden = YES;
            self->_vCurrentTimeProgress.hidden = YES;
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

- (void) updateCurrentPlaybackTime
{
    CGFloat currentPlaybackTime = [TBPLibraryModel sharedInstance].nowPlayingProgress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_vCurrentTimeProgress.frame = CGRectMake(self->_vCurrentTimeProgress.frame.origin.x, self->_vCurrentTimeProgress.frame.origin.y,
                                                       self->_vCurrentTimeBackground.frame.size.width * currentPlaybackTime, self->_vCurrentTimeProgress.frame.size.height);
        [self->_vCurrentTimeBackground setNeedsDisplay];
    });
}

@end
