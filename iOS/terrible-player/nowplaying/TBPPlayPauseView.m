//
//  TBPPlayPauseView.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPPlayPauseView.h"
#import "TBPConstants.h"

@interface TBPPlayPauseView ()

@property (nonatomic, strong) UIImageView *vPlatter;

- (void) startAnimating;
- (void) stopAnimating;

@end

@implementation TBPPlayPauseView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = NO;
        
        self.vPlatter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"platter_playpause"]];
        [_vPlatter setUserInteractionEnabled:NO];
        [self addSubview:_vPlatter];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    // _vPlatter.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void) setIsPlaying:(BOOL)isPlaying
{
    if (isPlaying != _isPlaying) {
        if (isPlaying)
            [self startAnimating];
        else
            [self stopAnimating];
    }
    _isPlaying = isPlaying;
}

- (void) startAnimating
{
    // animation for 1/3 of a revolution
    // 33 RPM = (60/33) SPR
    _vPlatter.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:(60.0f / (33.0f * 3.0f)) delay:0.0f options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear)
                     animations:^{
                         _vPlatter.transform = CGAffineTransformMakeRotation(M_PI * (2.0f / 3.0f));
                     } completion:nil];
}

- (void) stopAnimating
{
    [UIView animateWithDuration:(60.0f / 33.0f) * (0.99f / 3.0f) delay:0.0f options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         _vPlatter.transform = CGAffineTransformMakeRotation(M_PI * (1.99f / 3.0f));
                     } completion:nil];
}

@end
