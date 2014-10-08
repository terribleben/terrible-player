//
//  TBPTrackTableViewCell.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBPLibraryItem.h"

#define TBP_TRACK_TABLE_CELL_HEIGHT 48.0f

FOUNDATION_EXPORT NSString * const kTBPTrackTableViewCellIdentifier;

@interface TBPTrackTableViewCell : UITableViewCell

@property (nonatomic, strong) TBPLibraryItem *track;

@end
