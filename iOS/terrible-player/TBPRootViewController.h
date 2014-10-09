//
//  TBPRootViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBPNowPlayingBarViewController.h"
#import "TBPLibraryModel.h"

@interface TBPRootViewController : UIViewController <TBPNowPlayingBarDelegate, TBPLibraryDelegate>

@end
