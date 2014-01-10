//
//  ViewController.m
//
//  Copyright (c) 2014 Satoshi Asano. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+NJKFullScreenSupport.h"

@interface ViewController ()
@property (nonatomic) NSArray *data;
@property (nonatomic) NJKScrollFullScreen *scrollProxy;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupData];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];

    _scrollProxy = [[NJKScrollFullScreen alloc] initWithForwardTarget:self]; // UIScrollViewDelegate and UITableViewDelegate methods proxy to ViewController

    self.tableView.delegate = (id)_scrollProxy; // cast for surpress incompatible warnings

    _scrollProxy.delegate = self;

    if (!IS_RUNNING_IOS7) {
        // support full screen on iOS 6
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    }
}

-(void)viewDidLayoutSubviews
{
    // remove bottom toolbar height from inset
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = 0;
    self.tableView.contentInset = inset;
    inset = self.tableView.scrollIndicatorInsets;
    inset.bottom = 0;
    self.tableView.scrollIndicatorInsets = inset;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_scrollProxy reset];
    [self showNavigationBar:animated];
    [self showToolbar:animated];
}

- (void)setupData
{
    NSMutableArray *data = [@[] mutableCopy];
    for (NSUInteger i = 0; i < 100; i++) {
        [data addObject:@(i)];
    }
    _data = [data copy];
}

- (void)refreshControlValueChanged:(id)sender
{
    [self.refreshControl beginRefreshing];
    // simulate loading time
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.refreshControl endRefreshing];
    });
}

#pragma mark -
#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier forIndexPath:indexPath];
    cell.textLabel.text = [_data[indexPath.row] stringValue];
    return cell;
}

#pragma mark -
#pragma mark NJKScrollFullScreenDelegate

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollUp:(CGFloat)deltaY
{
    [self moveNavigtionBar:deltaY animated:YES];
    [self moveToolbar:-deltaY animated:YES]; // move to revese direction
}

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollDown:(CGFloat)deltaY
{
    [self moveNavigtionBar:deltaY animated:YES];
    [self moveToolbar:-deltaY animated:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp:(NJKScrollFullScreen *)proxy
{
    [self hideNavigationBar:YES];
    [self hideToolbar:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown:(NJKScrollFullScreen *)proxy
{
    [self showNavigationBar:YES];
    [self showToolbar:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_scrollProxy reset];
    [self showNavigationBar:YES];
    [self showToolbar:YES];
}

@end
