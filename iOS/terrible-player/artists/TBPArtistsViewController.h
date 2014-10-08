//
//  TBPArtistsViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBPLibraryItem.h"

@class TBPArtistsViewController;

@protocol TBPArtistsControllerDelegate <NSObject>

- (void) artistsViewController: (TBPArtistsViewController *)vcArtists didSelectArtist: (TBPLibraryItem *)artist;

@end

@interface TBPArtistsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <TBPArtistsControllerDelegate> delegate;

@end
