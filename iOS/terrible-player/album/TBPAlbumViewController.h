//
//  TBPAlbumViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBPLibraryItem.h"

@class TBPAlbumViewController;

@protocol TBPAlbumControllerDelegate <NSObject>

- (void) albumViewController: (TBPAlbumViewController *)vcAlbum didSelectTrack: (TBPLibraryItem *)track;

@end

@interface TBPAlbumViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <TBPAlbumControllerDelegate> delegate;
@property (nonatomic, strong) TBPLibraryItem *album;

@end
