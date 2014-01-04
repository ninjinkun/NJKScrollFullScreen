//
//  WebViewController.m
//
//  Copyright (c) 2014 Satoshi Asano. All rights reserved.
//

#import "WebViewController.h"
#import "UIViewController+NJKFullScreenSupport.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) NJKScrollFullScreen *scrollProxy;
@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _scrollProxy = [[NJKScrollFullScreen alloc] init];

    self.webView.scrollView.delegate = _scrollProxy;
    _scrollProxy.delegate = self;
    _scrollProxy.scrollViewDelegate = self.webView;

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.apple.com/macbook-pro/"]]];
}

// same as ViewController
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
