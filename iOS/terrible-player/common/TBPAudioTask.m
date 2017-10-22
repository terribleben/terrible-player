//
//  TBPAudioTask.m
//  terrible-player
//
//  Created by Ben Roth on 10/22/17.
//  Copyright © 2017 Ben Roth. All rights reserved.
//

#import "TBPAudioTask.h"
#import "TBPLibraryModel.h"

@import AVFoundation;

@interface TBPAudioTask ()

@property (nonatomic, assign) BOOL isTaskStarted;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation TBPAudioTask

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)beginMonitoring
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onAppChangeState) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onAppChangeState) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onModelChange:) name:kTBPLibraryModelDidChangeNotification object:nil];
    [self _updateAudioTask];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - internal

- (void)_onModelChange:(NSNotification *)notification
{
    NSNumber *changeReasonObj = (NSNumber *) notification.object;
    NSUInteger changeReason = (changeReasonObj) ? [changeReasonObj unsignedIntegerValue] : kTBPLibraryModelChangeUnknown;
    if ((changeReason & kTBPLibraryModelChangePlaybackState) != 0) {
        [self _updateAudioTask];
    }
}

- (void)_onAppChangeState
{
    [self _updateAudioTask];
}

- (void)_updateAudioTask
{
    [self _performSynchronouslyOnMainThread:^{
        // if music player stops, and app is currently in the background, stop the task
        // (allowing the OS to optionally terminate the app and save battery).
        // otherwise start the task.
        BOOL isInBackground = ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
        BOOL isMusicPlayerStopped = !([TBPLibraryModel sharedInstance].isPlaying);
        if (isInBackground && isMusicPlayerStopped) {
            [self _stopTask];
        } else {
            [self _startTask];
        }
    }];
}

- (void)_startTask
{
    if (!_isTaskStarted) {
        _isTaskStarted = YES;
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"silence" ofType:@"wav"]];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        _audioPlayer.numberOfLoops = -1;
        [_audioPlayer play];
    }
}

- (void)_stopTask
{
    if (_isTaskStarted) {
        _isTaskStarted = NO;
        [_audioPlayer stop];
        _audioPlayer = nil;
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}

- (void)_performSynchronouslyOnMainThread:(void (^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
