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

@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) TBPLibraryItem *nowPlayingItem;

- (void) onModelChange: (NSNotification *)notification;

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
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _lblTitle.frame = CGRectMake(8.0f, 0, self.view.frame.size.width - 16.0f, self.view.frame.size.height);
}


#pragma mark internal methods

- (void) reload
{
    self.nowPlayingItem = [TBPLibraryModel sharedInstance].nowPlayingItem;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_nowPlayingItem) {
            _lblTitle.text = _nowPlayingItem.title;
        } else {
            _lblTitle.text = nil;
        }
        
        [self.view setNeedsDisplay];
    });
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
