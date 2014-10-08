//
//  TBPArtistTableViewCell.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPArtistTableViewCell.h"
#import "TBPConstants.h"

NSString * const kTBPArtistsTableViewCellIdentifier = @"TBPArtistsTableViewCellIdentifier";

@interface TBPArtistTableViewCell ()

@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIImageView *vArtwork;

@end

@implementation TBPArtistTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
        
        // title label
        self.lblTitle = [[UILabel alloc] init];
        _lblTitle.font = [UIFont fontWithName:TBP_FONT size:14.0f];
        _lblTitle.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
        [self addSubview:_lblTitle];
        
        // artwork view
        self.vArtwork = [[UIImageView alloc] init];
        [self addSubview:_vArtwork];
    }
    return self;
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.artist = nil;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat sqrSide = MIN(64.0f, self.frame.size.height * 0.9f);
    CGFloat margin = MAX(4.0f, MIN(12.0f, self.frame.size.height * 0.05f));
    _vArtwork.frame = CGRectMake(margin, margin, sqrSide, sqrSide);
    
    CGFloat titleX = _vArtwork.frame.origin.x + _vArtwork.frame.size.width + margin;
    _lblTitle.frame = CGRectMake(titleX, margin,
                                 self.frame.size.width - titleX - margin, self.frame.size.height - margin - margin);
}

- (void) setArtist:(TBPLibraryItem *)artist
{
    _artist = artist;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (artist) {
            _lblTitle.text = artist.title;
            if (artist.artwork) {
                _vArtwork.image = [artist.artwork imageWithSize:_vArtwork.frame.size];
            } else
                _vArtwork.image = nil;
        } else {
            _lblTitle.text = nil;
            _vArtwork.image = nil;
        }
    });
}

@end
