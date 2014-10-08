//
//  TBPArtistsNavigationViewController.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPNavigationViewController.h"
#import "TBPArtistsViewController.h"
#import "TBPAlbumsViewController.h"
#import "TBPAlbumViewController.h"

@interface TBPArtistsNavigationViewController : TBPNavigationViewController
    <TBPArtistsControllerDelegate, TBPAlbumsControllerDelegate, TBPAlbumControllerDelegate>

@end
