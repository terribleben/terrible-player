//
//  TBPArtistTableViewCell.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBPLibraryItem.h"

#define TBP_ARTIST_TABLE_CELL_HEIGHT 70.0f

FOUNDATION_EXPORT NSString * const kTBPArtistsTableViewCellIdentifier;

@interface TBPArtistTableViewCell : UITableViewCell

@property (nonatomic, strong) TBPLibraryItem *artist;

@end
