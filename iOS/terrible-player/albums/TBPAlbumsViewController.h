//
//  TBPAlbumsViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBPLibraryItem.h"

@class TBPAlbumsViewController;

@protocol TBPAlbumsControllerDelegate <NSObject>

- (void) albumsViewController: (TBPAlbumsViewController *)vcAlbums didSelectAlbum: (TBPLibraryItem *)album;

@end

@interface TBPAlbumsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <TBPAlbumsControllerDelegate> delegate;

@end