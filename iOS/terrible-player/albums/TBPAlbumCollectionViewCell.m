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
        [self addSubview:_vAlbumArt];
        
        self.lblTitle = [[UILabel alloc] init];
        _lblTitle.font = [UIFont fontWithName:TBP_FONT size:10.0f];
        _lblTitle.textColor = UIColorFromRGB(TBP_COLOR_TEXT_LIGHT);
        _lblTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lblTitle];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    _lblTitle.frame = CGRectMake(0, self.frame.size.height - 16.0f,
                                 self.frame.size.width * 0.9f, 16.0f);
    _lblTitle.center = CGPointMake(self.frame.size.width * 0.5f, _lblTitle.center.y);
    
    CGFloat sqrDimension = MIN(self.frame.size.width * 0.9f, self.frame.size.height - _lblTitle.frame.size.height - 4.0f);
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
            _lblTitle.text = album.title;
            if (album.artwork) {
                _vAlbumArt.image = [album.artwork imageWithSize:_vAlbumArt.frame.size];
            } else
                _vAlbumArt.image = nil;
        } else {
            _lblTitle.text = nil;
            _vAlbumArt.image = nil;
        }
    });
}

@end
