//
//  TBPPlayPauseView.m
//  terrible-player
//
//  Use a CADisplayLink internally because [UIView animate] isn't reliable with repeating animations and app backgrounding
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPPlayPauseView.h"
#import "TBPConstants.h"

#define TBP_TURNTABLE_ACCEL M_PI
#define TBP_TURNTABLE_RPS ((33.0f / 60.0f) * M_PI * 2.0f)

@interface TBPPlayPauseView ()
{
    CGFloat platterVelocity;
}

@property (nonatomic, strong) UIImageView *vPlatter;
@property (nonatomic, strong) CADisplayLink *animator;

- (void) startAnimating;
- (void) stopAnimating;
- (void) animateFrame: (CADisplayLink *)link;

@end

@implementation TBPPlayPauseView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        platterVelocity = 0;
        
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

- (void) setIsPlaying:(BOOL)isPlaying
{
    if (isPlaying != _isPlaying) {
        if (isPlaying)
            [self startAnimating];
        // stopAnimating called once turntable stops
    }
    _isPlaying = isPlaying;
}

- (void) startAnimating
{
    if (!_animator) {
        self.animator = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateFrame:)];
        [_animator addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void) stopAnimating
{
    if (_animator) {
        [_animator invalidate];
        _animator = nil;
    }
}

- (void) animateFrame:(CADisplayLink *)link
{
    CGFloat dt = link.duration * (CGFloat)link.frameInterval;
    
    // if playing, accelerate the turntable up to 33 RPM
    if (_isPlaying && platterVelocity < TBP_TURNTABLE_RPS) {
        platterVelocity += (TBP_TURNTABLE_ACCEL * dt);
        if (platterVelocity > TBP_TURNTABLE_RPS)
            platterVelocity = TBP_TURNTABLE_RPS;
    }
    // if stopped, slow it to zero and then kill the display link
    if (!_isPlaying && platterVelocity > 0) {
        platterVelocity *= 0.95f;
        if (platterVelocity < 0.02f) {
            platterVelocity = 0;
            [self stopAnimating];
        }
    }
    
    CGFloat singleFrameRotation = platterVelocity * dt;
    _vPlatter.transform = CGAffineTransformRotate(_vPlatter.transform, singleFrameRotation);
}

@end
