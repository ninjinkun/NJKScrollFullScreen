//
//  NJKScrollFullscreen.m
//
//  Copyright (c) 2014 Satoshi Asano. All rights reserved.
//

#import "NJKScrollFullScreen.h"

typedef NS_ENUM(NSInteger, NJKScrollDirection) {
    NJKScrollDirectionNone,
    NJKScrollDirectionSame,
    NJKScrollDirectionUp,
    NJKScrollDirectionDown,
};

NJKScrollDirection detectScrollDirection(CGFloat currentOffsetY, CGFloat previousOffsetY)
{
    return currentOffsetY > previousOffsetY ? NJKScrollDirectionUp   :
    currentOffsetY < previousOffsetY ? NJKScrollDirectionDown :
    NJKScrollDirectionSame;
}

@interface NJKScrollFullScreen ()
@property (nonatomic) NJKScrollDirection previousScrollDirection;
@property (nonatomic) CGFloat previousOffsetY;
@property (nonatomic) CGFloat accumulatedY;
@property (nonatomic, weak) id<UIScrollViewDelegate> forwardTarget;
@property (nonatomic) CGFloat adjustedUpThresholdY; // up distance until fire. default 0 px.
@property (nonatomic) CGFloat adjustedDownThresholdY; // down distance until fire. default 200 px.
@end

@implementation NJKScrollFullScreen

- (id)initWithForwardTarget:(id)forwardTarget
{
    self = [super init];
    if (self) {
        [self reset];
        _downThresholdY = 100.0;
        _upThresholdY = 20.0;
        _forwardTarget = forwardTarget;
    }
    return self;
}

- (void)reset
{
    _adjustedUpThresholdY = _upThresholdY;
    _adjustedDownThresholdY = _downThresholdY;
    
    _previousOffsetY = 0.0;
    _accumulatedY = 0.0;
    _previousScrollDirection = NJKScrollDirectionNone;
}

- (void)adjustThresholdYToZero {
    _adjustedUpThresholdY = 0.0;
    _adjustedDownThresholdY = 0.0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_forwardTarget respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_forwardTarget scrollViewDidScroll:scrollView];
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    if (_previousScrollDirection == NJKScrollDirectionNone) {
        _previousOffsetY = currentOffsetY;
        _previousScrollDirection = NJKScrollDirectionSame;
        return;
    }
    
    NJKScrollDirection currentScrollDirection = detectScrollDirection(currentOffsetY, _previousOffsetY);
    CGFloat topBoundary = -scrollView.contentInset.top;
    CGFloat bottomBoundary = scrollView.contentSize.height - (scrollView.bounds.size.height - scrollView.contentInset.bottom);
    
    BOOL isOverTopBoundary = currentOffsetY <= topBoundary;
    BOOL isOverBottomBoundary = currentOffsetY >= bottomBoundary;
    
    BOOL isBouncing = (isOverTopBoundary && currentScrollDirection != NJKScrollDirectionDown) || (isOverBottomBoundary && currentScrollDirection != NJKScrollDirectionUp);
    if (isBouncing) {
        return;
    }
    
    CGFloat deltaY = _previousOffsetY - currentOffsetY;
    _accumulatedY += deltaY;
    
    switch (currentScrollDirection) {
        case NJKScrollDirectionUp:
        {
            BOOL isOverThreshold = _accumulatedY < -_adjustedUpThresholdY;
            
            if (isOverThreshold || isOverBottomBoundary)  {
                [self adjustThresholdYToZero];
                if ([_delegate respondsToSelector:@selector(scrollFullScreen:scrollViewDidScrollUp:)]) {
                    [_delegate scrollFullScreen:self scrollViewDidScrollUp:deltaY];
                }
            }
        }
            break;
        case NJKScrollDirectionDown:
        {
            BOOL isOverThreshold = _accumulatedY > _adjustedDownThresholdY;
            
            if (isOverThreshold || isOverTopBoundary) {
                [self adjustThresholdYToZero];
                if ([_delegate respondsToSelector:@selector(scrollFullScreen:scrollViewDidScrollDown:)]) {
                    [_delegate scrollFullScreen:self scrollViewDidScrollDown:deltaY];
                }
            }
        }
            break;
        default:
            break;
    }
    
    // reset acuumulated y when move opposite direction
    if (!isOverTopBoundary && !isOverBottomBoundary && _previousScrollDirection != currentScrollDirection) {
        _accumulatedY = 0;
    }
    
    _previousScrollDirection = currentScrollDirection;
    _previousOffsetY = currentOffsetY;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_forwardTarget respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_forwardTarget scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    
    CGFloat topBoundary = -scrollView.contentInset.top;
    CGFloat bottomBoundary = scrollView.contentSize.height - (scrollView.bounds.size.height - scrollView.contentInset.bottom);
    
    switch (_previousScrollDirection) {
        case NJKScrollDirectionUp:
        {
            BOOL isOverThreshold = _accumulatedY < -_adjustedUpThresholdY;
            BOOL isOverBottomBoundary = currentOffsetY >= bottomBoundary;
            
            if (isOverThreshold || isOverBottomBoundary) {
                if ([_delegate respondsToSelector:@selector(scrollFullScreenScrollViewDidEndDraggingScrollUp:)]) {
                    [_delegate scrollFullScreenScrollViewDidEndDraggingScrollUp:self];
                }
            }
            break;
        }
        case NJKScrollDirectionDown:
        {
            BOOL isOverThreshold = _accumulatedY > _adjustedDownThresholdY;
            BOOL isOverTopBoundary = currentOffsetY <= topBoundary;
            
            if (isOverThreshold || isOverTopBoundary) {
                if ([_delegate respondsToSelector:@selector(scrollFullScreenScrollViewDidEndDraggingScrollDown:)]) {
                    [_delegate scrollFullScreenScrollViewDidEndDraggingScrollDown:self];
                }
            }
            break;
        }
        default:
            break;
    }
    
    if (!decelerate) {
        [self reset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([_forwardTarget respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_forwardTarget scrollViewDidEndDecelerating:scrollView];
    }
    
    [self reset];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (([_forwardTarget respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])) {
        [_forwardTarget scrollViewDidEndScrollingAnimation:scrollView];
    }
    
    [self reset];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    BOOL ret = YES;
    if ([_forwardTarget respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        ret = [_forwardTarget scrollViewShouldScrollToTop:scrollView];
    }
    if ([_delegate respondsToSelector:@selector(scrollFullScreenScrollViewDidEndDraggingScrollDown:)]) {
        [_delegate scrollFullScreenScrollViewDidEndDraggingScrollDown:self];
    }
    return ret;
}

#pragma mark -
#pragma mark Method Forwarding

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        if([_forwardTarget respondsToSelector:selector]) {
            return [(id)_forwardTarget methodSignatureForSelector:selector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    if ([_forwardTarget respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:_forwardTarget];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL ret = [super respondsToSelector:aSelector];
    if (!ret) {
        ret = [_forwardTarget respondsToSelector:aSelector];
    }
    return ret;
}

@end
