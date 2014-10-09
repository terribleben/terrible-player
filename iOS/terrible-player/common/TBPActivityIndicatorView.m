//
//  TBPActivityIndicatorView.m
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPActivityIndicatorView.h"
#import "TBPConstants.h"

@interface TBPActivityIndicatorView ()

@property (nonatomic, strong) UIImageView *vPlatter;

@end

@implementation TBPActivityIndicatorView

- (id) initWithActivityIndicatorViewStyle:(TBPActivityIndicatorViewStyle)style
{
    if (self = [super init]) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.vPlatter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"platter_loading"]];
        _vPlatter.tintColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
        [self addSubview:_vPlatter];
        
        switch (style) {
            case kTBPActivityIndicatorViewStyleSmall:
                _vPlatter.frame = CGRectMake(0, 0, 32.0f, 32.0f);
                self.frame = CGRectMake(0, 0, 32.0f, 32.0f);
                break;
            case kTBPActivityIndicatorViewStyleLarge:
                self.frame = CGRectMake(0, 0, 64.0f, 64.0f);
                break;
        }
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    _vPlatter.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.5f);
}

- (void) startAnimating
{
    // animation for 1/3 of a revolution
    // 33 RPM = (60/33) SPR
    [UIView animateWithDuration:(60.0f / (33.0f * 3.0f)) delay:0.0f options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear)
                     animations:^{
                         _vPlatter.transform = CGAffineTransformMakeRotation(M_PI * (2.0f / 3.0f));
                     } completion:nil];
}

- (void) stopAnimating
{
    [UIView animateWithDuration:(60.0f / (33.0f * 3.0f)) delay:0.0f options:(UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         _vPlatter.transform = CGAffineTransformMakeRotation(M_PI * (2.0f / 3.0f));
                     } completion:nil];
}

@end
