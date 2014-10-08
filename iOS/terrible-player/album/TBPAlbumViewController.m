//
//  TBPAlbumViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPAlbumViewController.h"
#import "TBPLibraryModel.h"
#import "TBPTrackTableViewCell.h"
#import "TBPLibraryItemHeadingView.h"
#import "TBPConstants.h"

@interface TBPAlbumViewController ()

@property (nonatomic, strong) NSOrderedSet *tracks;
@property (nonatomic, strong) UITableView *vTracks;
@property (nonatomic, strong) TBPLibraryItemHeadingView *vAlbum;

- (void) onModelChange: (NSNotification *)notification;
- (void) reload;

@end

@implementation TBPAlbumViewController


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
    
    // album view
    self.vAlbum = [[TBPLibraryItemHeadingView alloc] init];
    [self.view addSubview:_vAlbum];
    
    // tracks view
    self.vTracks = [[UITableView alloc] init];
    _vTracks.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    _vTracks.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_vTracks registerClass:[TBPTrackTableViewCell class] forCellReuseIdentifier:kTBPTrackTableViewCellIdentifier];
    _vTracks.delegate = self;
    _vTracks.dataSource = self;
    [self.view addSubview:_vTracks];
    
    [self reload];
}

- (UIRectEdge) edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom ^ UIRectEdgeTop;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _vAlbum.frame = CGRectMake(0, 0, self.view.frame.size.width, 96.0f);
    _vTracks.frame = CGRectMake(0, _vAlbum.frame.size.height,
                                self.view.frame.size.width, self.view.frame.size.height - _vAlbum.frame.size.height);
}


#pragma mark external methods

- (void) setAlbum:(TBPLibraryItem *)album
{
    _album = album;
    
    if (_album)
        self.title = _album.title;
    else
        self.title = nil;
    
    [self reload];
}


#pragma mark delegate methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TBP_TRACK_TABLE_CELL_HEIGHT;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_tracks)
        return _tracks.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TBPTrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTBPTrackTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell)
        cell = [[TBPTrackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTBPTrackTableViewCellIdentifier];
    
    if (_tracks && indexPath.row < _tracks.count)
        cell.track = (TBPLibraryItem *)[_tracks objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_tracks && indexPath.row < _tracks.count) {
        TBPLibraryItem *selectedTrack = [_tracks objectAtIndex:indexPath.row];
        
        // play the current album at the selected track
        [[TBPLibraryModel sharedInstance] playTrackWithId:selectedTrack.persistentId inAlbum:_album.persistentId];
        
        if (_delegate)
            [_delegate albumViewController:self didSelectTrack:selectedTrack];
    }
}


#pragma mark internal methods

- (void) reload
{
    if (_album)
        self.tracks = [[TBPLibraryModel sharedInstance] tracksForAlbumWithId:_album.persistentId];
    else
        self.tracks = nil;
    
    if (self.isViewLoaded) {
        _vAlbum.item = _album;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_vTracks reloadData];
        });
    }
}

- (void) onModelChange:(NSNotification *)notification
{
    [self reload];
}

@end
