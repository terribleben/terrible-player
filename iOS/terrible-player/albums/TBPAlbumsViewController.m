//
//  TBPAlbumsViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPAlbumsViewController.h"
#import "TBPLibraryModel.h"

NSString * const kTBPAlbumsTableViewCellIdentifier = @"TBPAlbumsTableViewCellIdentifier";

@interface TBPAlbumsViewController ()

@property (nonatomic, strong) NSOrderedSet *albums;
@property (nonatomic, strong) UITableView *vAlbums;

- (void) onModelChange: (NSNotification *)notification;

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
    
    // albums view
    // TODO: collection view of album art
    self.vAlbums = [[UITableView alloc] init];
    [_vAlbums registerClass:[UITableViewCell class] forCellReuseIdentifier:kTBPAlbumsTableViewCellIdentifier];
    _vAlbums.delegate = self;
    _vAlbums.dataSource = self;
    [self.view addSubview:_vAlbums];
}

- (UIRectEdge) edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _vAlbums.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}


#pragma mark delegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_albums)
        return _albums.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTBPAlbumsTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTBPAlbumsTableViewCellIdentifier];
    
    if (_albums && indexPath.row < _albums.count)
        cell.textLabel.text = ((TBPLibraryItem *)[_albums objectAtIndex:indexPath.row]).title;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_albums && indexPath.row < _albums.count) {
        TBPLibraryItem *selectedAlbum = [_albums objectAtIndex:indexPath.row];
        if (_delegate)
            [_delegate albumsViewController:self didSelectAlbum:selectedAlbum];
    }
}


#pragma mark internal methods

- (void) onModelChange:(NSNotification *)notification
{
    self.albums = [TBPLibraryModel sharedInstance].albums;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_vAlbums reloadData];
    });
}

@end
