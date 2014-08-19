//
//  UIViewController+NJKFullScreenSupport.m
//
//  Copyright (c) 2014 Satoshi Asano. All rights reserved.
//

#if __IPHONE_7_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >=  __IPHONE_7_0
#define NJK_IS_RUNNING_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#else
#define NJK_IS_RUNNING_IOS7 NO
#endif

#import "UIViewController+NJKFullScreenSupport.h"

#define kNearZero 0.000001f

@implementation UIViewController (NJKFullScreenSupport)

- (void)showNavigationBar:(BOOL)animated
{
    CGSize statuBarFrameSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? statuBarFrameSize.height : statuBarFrameSize.width;

    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];

    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;

    [self setNavigationBarOriginY:overwrapStatusBarHeight animated:animated];
}

- (void)hideNavigationBar:(BOOL)animated
{
    CGSize statuBarFrameSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? statuBarFrameSize.height : statuBarFrameSize.width;

    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];

    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;

    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat top = NJK_IS_RUNNING_IOS7 ? -navigationBarHeight + overwrapStatusBarHeight : -navigationBarHeight;

    [self setNavigationBarOriginY:top animated:animated];
}

- (void)moveNavigtionBar:(CGFloat)deltaY animated:(BOOL)animated
{
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setNavigationBarOriginY:nextY animated:animated];
}

- (void)setNavigationBarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGSize statuBarFrameSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? statuBarFrameSize.height : statuBarFrameSize.width;

    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];

    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;

    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat navigationBarHeight = frame.size.height;

    CGFloat topLimit = NJK_IS_RUNNING_IOS7 ? -navigationBarHeight + overwrapStatusBarHeight : -navigationBarHeight;
    CGFloat bottomLimit = overwrapStatusBarHeight;

    frame.origin.y = fmin(fmax(y, topLimit), bottomLimit);
    CGFloat alpha = MAX(1 - (overwrapStatusBarHeight - frame.origin.y) / overwrapStatusBarHeight, kNearZero);
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.navigationController.navigationBar.frame = frame;
        NSUInteger index = 0;
        for (UIView *view in self.navigationController.navigationBar.subviews) {
            index++;
            if (index == 1 || view.hidden || view.alpha <= 0.0f) continue;
            view.alpha = alpha;
        }
        if (NJK_IS_RUNNING_IOS7) {
            // fade bar buttons
            UIColor *tintColor = self.navigationController.navigationBar.tintColor;
            if (tintColor) {
                self.navigationController.navigationBar.tintColor = [tintColor colorWithAlphaComponent:alpha];
            }
        }
    }];
}

#pragma mark -
#pragma mark manage ToolBar

- (void)showToolbar:(BOOL)animated
{
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? viewSize.height : viewSize.width;
    CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
    [self setToolbarOriginY:viewHeight - toolbarHeight animated:animated];
}

- (void)hideToolbar:(BOOL)animated
{
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? viewSize.height : viewSize.width;
    [self setToolbarOriginY:viewHeight animated:animated];
}

- (void)moveToolbar:(CGFloat)deltaY animated:(BOOL)animated
{
    CGRect frame = self.navigationController.toolbar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setToolbarOriginY:nextY animated:animated];
}

- (void)setToolbarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame = self.navigationController.toolbar.frame;
    CGFloat toolBarHeight = frame.size.height;
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? viewSize.height : viewSize.width;

    CGFloat topLimit = viewHeight - toolBarHeight;
    CGFloat bottomLimit = viewHeight;

    frame.origin.y = fmin(fmax(y, topLimit), bottomLimit); // limit over moving

    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.navigationController.toolbar.frame = frame;
    }];
}

#pragma mark -
#pragma mark manage TabBar

- (void)showTabBar:(BOOL)animated
{
    /* NOTE by Tonny
     * 2014/08/18
     * 
     * Weird, even in landscape, self.tabBarController.view.frame=(0 0; 768 1024), 
     * but, self.navigationController.view.frame=(0 0; 1024 768).
     * Is this a bug in UIKit?
     *
     * Also, the `-hideTabBar:` method captured this issue, but show method didn't.....
     * 
     */
    
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? viewSize.height : viewSize.width;
    CGFloat toolbarHeight = self.tabBarController.tabBar.frame.size.height;
    [self setTabBarOriginY:viewHeight - toolbarHeight animated:animated];
}

- (void)hideTabBar:(BOOL)animated
{
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? viewSize.height : viewSize.width;
    [self setTabBarOriginY:viewHeight animated:animated];
}

- (void)moveTabBar:(CGFloat)deltaY animated:(BOOL)animated
{
    CGRect frame =  self.tabBarController.tabBar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setTabBarOriginY:nextY animated:animated];
}

- (void)setTabBarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat toolBarHeight = frame.size.height;
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? viewSize.height : viewSize.width;
    CGFloat topLimit = viewHeight - toolBarHeight;
    CGFloat bottomLimit = viewHeight;
    
    frame.origin.y = fmin(fmax(y, topLimit), bottomLimit); // limit over moving
    
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.tabBarController.tabBar.frame = frame;
    }];
}

@end
