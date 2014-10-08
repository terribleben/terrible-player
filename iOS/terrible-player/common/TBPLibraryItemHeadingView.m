//
//  TBPLibraryItemHeadingView.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLibraryItemHeadingView.h"

@interface TBPLibraryItemHeadingView ()

@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIImageView *vArtwork;

@end

@implementation TBPLibraryItemHeadingView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        // title label
        self.lblTitle = [[UILabel alloc] init];
        _lblTitle.font = [UIFont boldSystemFontOfSize:22.0f];
        _lblTitle.textColor = [UIColor whiteColor];
        [self addSubview:_lblTitle];
        
        // artwork view
        self.vArtwork = [[UIImageView alloc] init];
        [self addSubview:_vArtwork];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat sqrSide = MIN(64.0f, self.frame.size.height * 0.9f);
    CGFloat margin = MAX(4.0f, MIN(24.0f, self.frame.size.height * 0.05f));
    _vArtwork.frame = CGRectMake(margin, margin, sqrSide, sqrSide);
    
    CGFloat titleX = _vArtwork.frame.origin.x + _vArtwork.frame.size.width + margin;
    _lblTitle.frame = CGRectMake(titleX, margin,
                                 self.frame.size.width - titleX - margin, 32.0f);
}

- (void) setItem:(TBPLibraryItem *)item
{
    _item = item;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_item) {
            _lblTitle.text = item.title;
            if (item.artwork) {
                _vArtwork.image = [item.artwork imageWithSize:_vArtwork.frame.size];
            } else
                _vArtwork.image = nil;
        } else {
            _lblTitle.text = nil;
            _vArtwork.image = nil;
        }
        
        [self setNeedsLayout];
    });
}

@end
