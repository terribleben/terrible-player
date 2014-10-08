//
//  TBPAlbumCollectionViewCell.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBPLibraryItem.h"

FOUNDATION_EXPORT NSString * const kTBPAlbumsCollectionViewCellIdentifier;

@interface TBPAlbumCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TBPLibraryItem *album;

@end
