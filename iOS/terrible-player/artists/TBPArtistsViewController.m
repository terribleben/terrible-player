//
//  TBPArtistsViewController.m
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import "TBPArtistsViewController.h"
#import "TBPLibraryModel.h"

NSString * const kTBPArtistsTableViewCellIdentifier = @"TBPArtistsTableViewCellIdentifier";

@interface TBPArtistsViewController ()

@property (nonatomic, strong) NSOrderedSet *artists;
@property (nonatomic, strong) UITableView *vArtists;

- (void) onModelChange: (NSNotification *)notification;

@end

@implementation TBPArtistsViewController


#pragma mark vc lifecycle

- (id) init
{
    if (self = [super init]) {
        self.title = @"Artists";
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
    
    // artists view
    self.vArtists = [[UITableView alloc] init];
    [_vArtists registerClass:[UITableViewCell class] forCellReuseIdentifier:kTBPArtistsTableViewCellIdentifier];
    _vArtists.delegate = self;
    _vArtists.dataSource = self;
    [self.view addSubview:_vArtists];
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


#pragma mark delegate methods

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTBPArtistsTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTBPArtistsTableViewCellIdentifier];
    
    if (_artists && indexPath.row < _artists.count)
        cell.textLabel.text = ((TBPLibraryItem *)[_artists objectAtIndex:indexPath.row]).title;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_artists && indexPath.row < _artists.count) {
        TBPLibraryItem *selectedArtist = [_artists objectAtIndex:indexPath.row];
        if (_delegate)
            [_delegate artistsViewController:self didSelectArtist:selectedArtist];
    }
}


#pragma mark internal methods

- (void) onModelChange:(NSNotification *)notification
{
    self.artists = [TBPLibraryModel sharedInstance].artists;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_vArtists reloadData];
    });
}

@end
