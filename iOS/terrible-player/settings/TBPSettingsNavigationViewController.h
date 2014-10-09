//
//  TBPSettingsNavigationViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPNavigationViewController.h"
#import "TBPSettingsViewController.h"
#import "TBPAuthViewController.h"

@interface TBPSettingsNavigationViewController : TBPNavigationViewController <TBPSettingsDelegate, TBPAuthDelegate>

@end
