//
//  TBPAlbumCollectionViewCell.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPAlbumCollectionViewCell.h"
#import "TBPConstants.h"

NSString * const kTBPAlbumsCollectionViewCellIdentifier = @"TBPAlbumsCollectionViewCellIdentifier";

@interface TBPAlbumCollectionViewCell ()

@property (nonatomic, strong) UIImageView *vAlbumArt;
@property (nonatomic, strong) UILabel *lblTitle;

@end

@implementation TBPAlbumCollectionViewCell

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.vAlbumArt = [[UIImageView alloc] init];
        _vAlbumArt.backgroundColor = UIColorFromRGB(TBP_COLOR_GREY_DEFAULT);
        [self addSubview:_vAlbumArt];
        
        self.lblTitle = [[UILabel alloc] init];
        _lblTitle.font = [UIFont fontWithName:TBP_FONT size:11.0f];
        _lblTitle.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
        _lblTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lblTitle];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    _lblTitle.frame = CGRectMake(0, self.frame.size.height - 24.0f,
                                 self.frame.size.width * 0.9f, 16.0f);
    _lblTitle.center = CGPointMake(self.frame.size.width * 0.5f, _lblTitle.center.y);
    
    CGFloat sqrDimension = MIN(self.frame.size.width * 0.9f, self.frame.size.height - _lblTitle.frame.size.height - 8.0f);
    _vAlbumArt.frame = CGRectMake(0, 0, sqrDimension, sqrDimension);
    _vAlbumArt.center = CGPointMake(_lblTitle.center.x, sqrDimension * 0.5f);
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.album = nil;
}

- (void) setAlbum:(TBPLibraryItem *)album
{
    _album = album;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (album) {
            self->_lblTitle.text = album.title;
            if (album.artwork) {
                self->_vAlbumArt.image = [album.artwork imageWithSize:self->_vAlbumArt.frame.size];
            } else
                self->_vAlbumArt.image = [UIImage imageNamed:@"platter"];
        } else {
            self->_lblTitle.text = nil;
            self->_vAlbumArt.image = nil;
        }
    });
}

@end
