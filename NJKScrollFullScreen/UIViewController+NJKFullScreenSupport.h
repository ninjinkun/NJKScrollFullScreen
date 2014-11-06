//
//  UIViewController+NJKFullScreenSupport.h
//
//  Copyright (c) 2014 Satoshi Asano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NJKFullScreenSupport)

- (void)showNavigationBar:(BOOL)animated;
- (void)hideNavigationBar:(BOOL)animated;
- (void)moveNavigationBar:(CGFloat)deltaY animated:(BOOL)animated;
- (void)setNavigationBarOriginY:(CGFloat)y animated:(BOOL)animated;

- (void)showToolbar:(BOOL)animated;
- (void)hideToolbar:(BOOL)animated;
- (void)moveToolbar:(CGFloat)deltaY animated:(BOOL)animated;
- (void)setToolbarOriginY:(CGFloat)y animated:(BOOL)animated;

- (void)showTabBar:(BOOL)animated;
- (void)hideTabBar:(BOOL)animated;
- (void)moveTabBar:(CGFloat)deltaY animated:(BOOL)animated;
- (void)setTabBarOriginY:(CGFloat)y animated:(BOOL)animated;

@end

// Compatible method for typo fixed (https://github.com/ninjinkun/NJKScrollFullScreen/pull/23)
@interface UIViewController (NJKFullScreenSupportDeprecated)

- (void)moveNavigtionBar:(CGFloat)deltaY animated:(BOOL)animated __deprecated_msg("Use `moveNavigationBar:animated:`");

@end
