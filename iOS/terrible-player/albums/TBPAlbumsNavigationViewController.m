//
//  TBPAlbumsNavigationViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPAlbumsNavigationViewController.h"

@interface TBPAlbumsNavigationViewController ()

@property (nonatomic, strong) TBPAlbumsViewController *vcAlbums;

@end

@implementation TBPAlbumsNavigationViewController

- (id) init
{
    TBPAlbumsViewController *vcAlbums = [[TBPAlbumsViewController alloc] init];
    
    if (self = [super initWithRootViewController:vcAlbums]) {
        self.vcAlbums = vcAlbums;
        _vcAlbums.delegate = self;
        
        self.title = @"Albums";
    }
    return self;
}


#pragma mark delegate methods

- (void) albumsViewController:(TBPAlbumsViewController *)vcAlbums didSelectAlbum:(NSString *)album
{
    // TODO do something
    NSLog(@"selected %@", album);
}

@end
