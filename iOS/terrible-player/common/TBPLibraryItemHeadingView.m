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
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOpacity = 0.9f;
        
        // labels
        self.lblDuration = [[UILabel alloc] init];
        self.lblDate = [[UILabel alloc] init];
        self.lblCount = [[UILabel alloc] init];
        
        for (UILabel *lbl in @[ _lblDuration, _lblDate, _lblCount ]) {
            lbl.font = [UIFont fontWithName:TBP_FONT size:20.0f];
            lbl.textColor = UIColorFromRGB(TBP_COLOR_TEXT_DIM);
            [self addSubview:lbl];
        }
        
        // artwork view
        self.vArtwork = [[UIImageView alloc] init];
        _vArtwork.backgroundColor = UIColorFromRGB(TBP_COLOR_GREY_DEFAULT);
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
    
    CGFloat titleX = _vArtwork.frame.origin.x + _vArtwork.frame.size.width + margin * 2.0f;
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
        if (self->_item) {
            if (self->_item.releaseDate && item.releaseDate.integerValue != 0) {
                self->_lblDate.text = [NSString stringWithFormat:@"%ld", (long)item.releaseDate.integerValue];
            } else
                self->_lblDate.text = nil;
            
            NSUInteger tracks = self->_item.count.unsignedIntegerValue;
            self->_lblCount.text = (tracks == 1)
                ? [NSString stringWithFormat:@"%lu track", (unsigned long)tracks]
                : [NSString stringWithFormat:@"%lu tracks", (unsigned long)tracks];
            self->_lblDuration.text = (self->_item.duration) ? [NSString stringFromTimeInterval:self->_item.duration.floatValue] : nil;
            self->_vArtwork.image = (item.artwork) ? [item.artwork imageWithSize:self->_vArtwork.frame.size] : [UIImage imageNamed:@"platter"];
        } else {
            self->_lblDate.text = nil;
            self->_lblDuration.text = nil;
            self->_lblCount.text = nil;
            self->_vArtwork.image = nil;
        }
        
        [self setNeedsLayout];
    });
}

@end
