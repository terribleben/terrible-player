//
//  TBPAlbumsViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPAlbumsViewController.h"
#import "TBPLibraryModel.h"
#import "TBPAlbumCollectionViewCell.h"
#import "TBPLibraryItemHeadingView.h"
#import "TBPConstants.h"

@interface TBPAlbumsViewController ()

@property (nonatomic, strong) NSOrderedSet *albums;
@property (nonatomic, strong) UICollectionView *vAlbums;

- (void) onModelChange: (NSNotification *)notification;
- (void) reload;

@end

@implementation TBPAlbumsViewController


#pragma mark vc lifecycle

- (id) init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModelChange:) name:kTBPLibraryModelDidChangeNotification object:nil];
    }
    return self;
}

- (void) dealloc
{
    // [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    
    // albums view
    UICollectionViewFlowLayout *loAlbums = [[UICollectionViewFlowLayout alloc] init];
    loAlbums.scrollDirection = UICollectionViewScrollDirectionVertical;
    loAlbums.minimumInteritemSpacing = 0.0f;
    loAlbums.minimumLineSpacing = 6.0f;
    
    self.vAlbums = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                      collectionViewLayout:loAlbums];
    [_vAlbums registerClass:[TBPAlbumCollectionViewCell class] forCellWithReuseIdentifier:kTBPAlbumsCollectionViewCellIdentifier];
    _vAlbums.delegate = self;
    _vAlbums.dataSource = self;
    _vAlbums.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    [self.view addSubview:_vAlbums];
    
    [self reload];
}

- (UIRectEdge) edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom ^ UIRectEdgeTop;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    CGFloat albumsY = 16.0f;
    _vAlbums.frame = CGRectMake(0, albumsY, self.view.frame.size.width, self.view.frame.size.height - albumsY);
}


#pragma mark external properties

- (void) setArtist:(TBPLibraryItem *)artist
{
    _artist = artist;
    
    if (_artist)
        self.title = _artist.title;
    else
        self.title = @"Albums";
    
    [self reload];
}


#pragma mark delegate methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_albums)
        return _albums.count;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TBPAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTBPAlbumsCollectionViewCellIdentifier forIndexPath:indexPath];
    if (!cell)
        cell = [[TBPAlbumCollectionViewCell alloc] init];
    
    if (_albums && indexPath.item < _albums.count)
        cell.album = (TBPLibraryItem *)[_albums objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if (_albums && indexPath.row < _albums.count) {
        TBPLibraryItem *selectedAlbum = [_albums objectAtIndex:indexPath.item];
        if (_delegate)
            [_delegate albumsViewController:self didSelectAlbum:selectedAlbum];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sqrSide = MIN(self.view.frame.size.width * 0.48f, self.view.frame.size.height * 0.48f);
    return CGSizeMake(sqrSide, sqrSide + 12.0f);
}


#pragma mark internal methods

- (void) reload
{
    if (_artist)
        self.albums = [[TBPLibraryModel sharedInstance] albumsForArtistWithId:_artist.persistentId];
    else {
        // this would be the "all albums" case, not currently used
        // self.albums = [TBPLibraryModel sharedInstance].albums;
        self.albums = nil;
    }
    
    if (self.isViewLoaded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view setNeedsLayout];
            [self->_vAlbums reloadData];
        });
    }
}

- (void) onModelChange:(NSNotification *)notification
{
    NSNumber *changeReasonObj = (NSNumber *) notification.object;
    NSUInteger changeReason = (changeReasonObj) ? [changeReasonObj unsignedIntegerValue] : kTBPLibraryModelChangeUnknown;
    if ((changeReason & kTBPLibraryModelChangeLibraryContents) != 0) {
        [self reload];
    }
}

@end
