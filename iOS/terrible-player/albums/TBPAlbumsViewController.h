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

@interface TBPAlbumsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

/**
 *  If set, filters the album list by a particular artist.
 */
@property (nonatomic, strong) TBPLibraryItem *artist;

@property (nonatomic, assign) id <TBPAlbumsControllerDelegate> delegate;

@end