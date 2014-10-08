//
//  TBPTrackTableViewCell.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPTrackTableViewCell.h"

NSString * const kTBPTrackTableViewCellIdentifier = @"TBPTrackTableViewCellIdentifier";

@interface TBPTrackTableViewCell ()

@property (nonatomic, strong) UILabel *lblTitle;

@end

@implementation TBPTrackTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor blackColor];
        
        // title label
        self.lblTitle = [[UILabel alloc] init];
        _lblTitle.font = [UIFont systemFontOfSize:14.0f];
        _lblTitle.textColor = [UIColor whiteColor];
        [self addSubview:_lblTitle];
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
    
    CGFloat margin = MAX(4.0f, MIN(12.0f, self.frame.size.height * 0.05f));

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

@end
