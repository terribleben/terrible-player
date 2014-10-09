//
//  TBPLibraryItemHeadingView.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPLibraryItemHeadingView.h"
#import "TBPConstants.h"
#import "NSString+TBP.h"

@interface TBPLibraryItemHeadingView ()

@property (nonatomic, strong) UILabel *lblDate;
@property (nonatomic, strong) UILabel *lblDuration;
@property (nonatomic, strong) UILabel *lblCount;
@property (nonatomic, strong) UIImageView *vArtwork;

@end

@implementation TBPLibraryItemHeadingView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
        
        // labels
        self.lblDuration = [[UILabel alloc] init];
        self.lblDate = [[UILabel alloc] init];
        self.lblCount = [[UILabel alloc] init];
        
        for (UILabel *lbl in @[ _lblDuration, _lblDate, _lblCount ]) {
            lbl.font = [UIFont fontWithName:TBP_FONT_BOLD size:20.0f];
            lbl.textColor = UIColorFromRGB(TBP_COLOR_GREY_SELECTED);
            [self addSubview:lbl];
        }
        
        // artwork view
        self.vArtwork = [[UIImageView alloc] init];
        [self addSubview:_vArtwork];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat sqrSide = MIN(128.0f, self.frame.size.height * 0.9f);
    CGFloat margin = MAX(8.0f, MIN(24.0f, self.frame.size.height * 0.05f));
    _vArtwork.frame = CGRectMake(margin, margin, sqrSide, sqrSide);
    
    CGFloat titleX = _vArtwork.frame.origin.x + _vArtwork.frame.size.width + margin;
    _lblCount.frame = CGRectMake(titleX, margin,
                                 self.frame.size.width - titleX - margin, 32.0f);
    _lblDuration.frame = CGRectMake(titleX, _lblCount.frame.origin.y + _lblCount.frame.size.height,
                                    _lblCount.frame.size.width, 32.0f);
    _lblDate.frame = CGRectMake(titleX, _lblDuration.frame.origin.y + _lblDuration.frame.size.height,
                                    _lblDuration.frame.size.width, 32.0f);
}

- (void) setItem:(TBPLibraryItem *)item
{
    _item = item;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_item) {
            if (_item.releaseDate && item.releaseDate.integerValue != 0) {
                _lblDate.text = [NSString stringWithFormat:@"%d", item.releaseDate.integerValue];
            } else
                _lblDate.text = nil;
            
            _lblCount.text = [NSString stringWithFormat:@"%u tracks", _item.count.unsignedIntegerValue];
            _lblDuration.text = (_item.duration) ? [NSString stringFromTimeInterval:_item.duration.floatValue] : nil;
            _vArtwork.image = (item.artwork) ? [item.artwork imageWithSize:_vArtwork.frame.size] : nil;
        } else {
            _lblDate.text = nil;
            _lblDuration.text = nil;
            _lblCount.text = nil;
            _vArtwork.image = nil;
        }
        
        [self setNeedsLayout];
    });
}

@end
