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

@interface TBPAlbumsViewController ()

@property (nonatomic, strong) NSOrderedSet *albums;
@property (nonatomic, strong) UICollectionView *vAlbums;
@property (nonatomic, strong) TBPLibraryItemHeadingView *vArtist;

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
    
    // artist view
    self.vArtist = [[TBPLibraryItemHeadingView alloc] init];
    [self.view addSubview:_vArtist];
    
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
    
    if (_artist) {
        _vArtist.hidden = NO;
        _vArtist.frame = CGRectMake(0, 0, self.view.frame.size.width, 96.0f);
        _vAlbums.frame = CGRectMake(0, _vArtist.frame.size.height,
                                    self.view.frame.size.width, self.view.frame.size.height - _vArtist.frame.size.height);
    } else {
        _vArtist.hidden = YES;
        _vAlbums.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
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
    return CGSizeMake(sqrSide, sqrSide);
}


#pragma mark internal methods

- (void) reload
{
    if (_artist)
        self.albums = [[TBPLibraryModel sharedInstance] albumsForArtistWithId:_artist.persistentId];
    else
        self.albums = [TBPLibraryModel sharedInstance].albums;
    
    if (self.isViewLoaded) {
        _vArtist.item = _artist;
        [self.view setNeedsLayout];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_vAlbums reloadData];
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
