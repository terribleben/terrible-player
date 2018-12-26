//
//  TBPArtistsViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPArtistsViewController.h"
#import "TBPLibraryModel.h"
#import "TBPArtistTableViewCell.h"
#import "TBPConstants.h"
#import "TBPSettingsNavigationViewController.h"

@interface TBPArtistsViewController ()

@property (nonatomic, strong) NSOrderedSet *artists;
@property (nonatomic, strong) UITableView *vArtists;

- (void) onModelChange: (NSNotification *)notification;

@end

@implementation TBPArtistsViewController


#pragma mark - lifecycle

- (id) init
{
    if (self = [super init]) {
        self.title = @"Library";
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
    
    // artists view
    self.vArtists = [[UITableView alloc] init];
    _vArtists.backgroundColor = UIColorFromRGB(TBP_COLOR_BACKGROUND);
    _vArtists.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_vArtists registerClass:[TBPArtistTableViewCell class] forCellReuseIdentifier:kTBPArtistsTableViewCellIdentifier];
    _vArtists.delegate = self;
    _vArtists.dataSource = self;
    [self.view addSubview:_vArtists];
    
    // settings left button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(_onTapSettingsButton)];
}

- (UIRectEdge) edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _vArtists.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_vArtists) {
        for (NSIndexPath *selectedPath in [_vArtists indexPathsForSelectedRows]) {
            [_vArtists deselectRowAtIndexPath:selectedPath animated:YES];
        }
    }
}


#pragma mark - delegate methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TBP_ARTIST_TABLE_CELL_HEIGHT;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_artists)
        return _artists.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TBPArtistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTBPArtistsTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell)
        cell = [[TBPArtistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTBPArtistsTableViewCellIdentifier];
    
    UIView *vBackground = [[UIView alloc] init];
    vBackground.backgroundColor = UIColorFromRGB(TBP_COLOR_GREY_DEFAULT);
    vBackground.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    cell.selectedBackgroundView = vBackground;
    
    if (_artists && indexPath.row < _artists.count)
        cell.artist = (TBPLibraryItem *)[_artists objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_artists && indexPath.row < _artists.count) {
        TBPLibraryItem *selectedArtist = [_artists objectAtIndex:indexPath.row];
        if (_delegate)
            [_delegate artistsViewController:self didSelectArtist:selectedArtist];
    }
}


#pragma mark - internal methods

- (void) onModelChange:(NSNotification *)notification
{
    NSNumber *changeReasonObj = (NSNumber *) notification.object;
    NSUInteger changeReason = (changeReasonObj) ? [changeReasonObj unsignedIntegerValue] : kTBPLibraryModelChangeUnknown;
    if ((changeReason & kTBPLibraryModelChangeLibraryContents) != 0) {
        self.artists = [TBPLibraryModel sharedInstance].artists;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_vArtists reloadData];
        });
    }
}

- (void)_onTapSettingsButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPShowSettingsNotification object:nil];
}

@end
