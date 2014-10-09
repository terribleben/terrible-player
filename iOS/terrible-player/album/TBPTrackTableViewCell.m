//
//  TBPTrackTableViewCell.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPTrackTableViewCell.h"
#import "TBPConstants.h"

NSString * const kTBPTrackTableViewCellIdentifier = @"TBPTrackTableViewCellIdentifier";

@interface TBPTrackTableViewCell ()

@property (nonatomic, strong) UILabel *lblTitle;

@end

@implementation TBPTrackTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
        
        // title label
        self.lblTitle = [[UILabel alloc] init];
        _lblTitle.font = [UIFont fontWithName:TBP_FONT size:16.0f];
        _lblTitle.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
        [self addSubview:_lblTitle];
        
        self.state = kTBPTrackTableViewCellStateDefault;
    }
    return self;
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.track = nil;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = MAX(8.0f, MIN(16.0f, self.frame.size.height * 0.05f));

    _lblTitle.frame = CGRectMake(margin, margin,
                                 self.frame.size.width - (margin * 2.0f), self.frame.size.height - (margin * 2.0f));
}

- (void) setTrack:(TBPLibraryItem *)track
{
    _track = track;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (track) {
            _lblTitle.text = track.title;
        } else {
            _lblTitle.text = nil;
        }
    });
}

- (void) setState:(TBPTrackTableViewCellState)state
{
    _state = state;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case kTBPTrackTableViewCellStateNowPlaying:
                self.backgroundColor = UIColorFromRGB(TBP_COLOR_GREY_DEFAULT);
                break;
            case kTBPTrackTableViewCellStateDefault:
                self.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
                break;
        }
        [self setNeedsDisplay];
    });
}

@end
