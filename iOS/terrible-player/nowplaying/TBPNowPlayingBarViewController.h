//
//  TBPNowPlayingBarViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TBP_NOW_PLAYING_BAR_HEIGHT 48.0f

@class TBPNowPlayingBarViewController;

typedef enum TBPNowPlayingBarViewMode {
    kTBPNowPlayingBarViewModeLibrary,
    kTBPNowPlayingBarViewModeSettings
} TBPNowPlayingBarViewMode;

@protocol TBPNowPlayingBarDelegate <NSObject>

- (void) nowPlayingBarDidSelectPlayPause: (TBPNowPlayingBarViewController *)vcNowPlaying;
- (void) nowPlayingBar: (TBPNowPlayingBarViewController *)vcNowPlaying didSelectMode: (TBPNowPlayingBarViewMode)mode;

@end

@interface TBPNowPlayingBarViewController : UIViewController

@property (nonatomic, assign) id <TBPNowPlayingBarDelegate> delegate;
@property (nonatomic, assign) TBPNowPlayingBarViewMode mode;

@end
