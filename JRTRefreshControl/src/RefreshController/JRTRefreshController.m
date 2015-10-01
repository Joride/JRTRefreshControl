//
//  RefreshController.m
//  RefreshControl
//
//  Created by Joride on 21-08-15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "JRTRefreshController.h"
#import "JRTRotatingRefreshControlView.h"
#import "JRTRefreshControl+Subclassing.h"

NSString * const kIsRefreshingKeyPath = @"isRefreshing";

@interface JRTRefreshController ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) JRTRefreshControlView * refreshControlView;
@property (nonatomic, getter=isContentInsetAdjustedForRefreshControl) BOOL contentInsetAdjustedForRefreshControl;
@property (nonatomic) BOOL needsUpdateScollViewInsets;
@property (nonatomic) BOOL shouldReportValueToRefreshControl;
@property (nonatomic) BOOL shouldCallDelegate;
@end

@implementation JRTRefreshController
-(instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}
-(instancetype)initWithScrollView: (UIScrollView *) scrollView
          refreshControlViewClass: (Class) refreshControlViewClass
{
    NSParameterAssert(scrollView);
    NSAssert(nil != scrollView.superview,
             @"The scrollView must have a superview when initializing a JRTRefreshController");

    self = [super init];
    if (self)
    {
        _hidesRefreshControlViewWhenInactive = YES;
        _shouldCallDelegate = YES;
        _shouldReportValueToRefreshControl = YES;
        _relativeChangeOffset = 0.0f;
        _relativeChangeRate = 1.0f;
        _scrollView = scrollView;
        [self setupWithScrollView: self.scrollView
          refreshControlViewClass: refreshControlViewClass];
    }
    return self;
}
-(void)dealloc
{
    [self.refreshControlView removeObserver: self
                                 forKeyPath: kIsRefreshingKeyPath];
    [self.refreshControlView removeFromSuperview];
}
- (void) setupWithScrollView: (UIScrollView *) scrollView
     refreshControlViewClass: (Class) refreshControlViewClass
{
    NSAssert([refreshControlViewClass isSubclassOfClass: [JRTRefreshControlView class]],
             @"Class returned from +refreshControlViewClass is not a subclass of RefreshControlView");

    // autoloayout + scrollView + animations = not working well.
    self.refreshControlView = [[refreshControlViewClass alloc]
                               initWithFrame: CGRectZero];
    [self.refreshControlView sizeToFit];
    [self.refreshControlView addObserver: self
                              forKeyPath: kIsRefreshingKeyPath
                                 options: NSKeyValueObservingOptionNew
                                 context: NULL];

    UIViewAutoresizing autoresizingMask;
    autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                        UIViewAutoresizingFlexibleRightMargin);
    self.refreshControlView.autoresizingMask = autoresizingMask;
    
    [self.scrollView addSubview: self.refreshControlView];

    // keep the refreshcontrol behind any other view
    self.refreshControlView.layer.zPosition = -1.0f;
    [self updateRefreshControlViewFrame];
}
-(void)setHidesRefreshControlViewWhenInactive:(BOOL)hidesRefreshControlViewWhenInactive
{
    if (_hidesRefreshControlViewWhenInactive != hidesRefreshControlViewWhenInactive)
    {
        _hidesRefreshControlViewWhenInactive = hidesRefreshControlViewWhenInactive;
        if (!_hidesRefreshControlViewWhenInactive)
        {
            // if we never hide the refreshControlView, we will not change the
            // the active state of the refreshControlView any more, and so
            // we make sure it is in the active state
            self.refreshControlView.active = YES;
        }
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll
{
    // this will keep the refreshControl positioned at the top of scrollView
    // and report a value change if neccessary
    [self updateRefreshControl];
}

-(void)scrollViewDidEndDragging
{
    // we only update the scrollView when the user is not touching the scrollView
    [self updateScrollViewContentInsetsIfNeeded];
}
- (void) scrollViewDidEndDecelerating
{
    CGFloat YOffset = self.scrollView.contentOffset.y;
    if (YOffset >= 0)
    {
        // the scrollview is at a point not dragged down, we can
        // start reporting values to the refreshControl again
        self.shouldReportValueToRefreshControl = YES;
    }
}
#pragma mark -
- (void) stopRefreshing
{
    if (self.refreshControlView.isRefreshing)
    {
        // the refreshControl will start responding to changes as soon as the content
        // offset passes zero. We might animate the scrollView to 0, this will lead to
        // scrollViewDidScroll call for offset 0, immediately followed by the actual
        // value. This would mean that our refreshCOntrol would respond to changes
        // while the scrollView is moving back to contentOffset 0. To avoid this,
        // we keep this flag. It is changed to YES at the end of our animation,
        // or in -scrollViewDidEndDecelerating.
        self.shouldReportValueToRefreshControl = NO;
        [self.refreshControlView stopRefreshing];
    }
}
- (void) startRefreshing
{
    if (!self.refreshControlView.isRefreshing)
    {
        self.shouldCallDelegate = NO;
        self.refreshControlView.value = 1.00f;
    }
}

#pragma mark -
- (void) updateRefreshControlActiveStatus
{
    // only do something when we are configured to set the
    // refreshControlview to hidden or not
    if (self.hidesRefreshControlViewWhenInactive)
    {
        CGFloat YOffset = self.scrollView.contentOffset.y;
        
        // whwen the scrollView not pulled down,
        // and we are not refreshing, we consider the view
        // to be inactive. We will set the value on the view it is not already
        // the value it should be.
        if (YOffset > 0 &&
            !self.refreshControlView.isRefreshing)
        {
            if (self.refreshControlView.isActive)
            {
                self.refreshControlView.active = NO;
            }
        }
        else
        {
            if (!self.refreshControlView.isActive)
            {
                self.refreshControlView.active = YES;
            }
        }
    }
}
- (void) updateRefreshControl
{
    [self updateRefreshControlActiveStatus];
    
    CGFloat YOffset = self.scrollView.contentOffset.y;
    
    [self updateRefreshControlViewFrame];
    
    if (!self.shouldReportValueToRefreshControl)
    {
        return;
    }
    
    if (0 != YOffset)
    {
        // only update the value of the refreshcontrol when we are pulling down
        if (YOffset < -self.scrollView.contentInset.top)
        {
            CGFloat refreshControlHeight = self.refreshControlView.intrinsicContentSize.height;
            CGFloat actualDistance = ABS(YOffset) - self.scrollView.contentInset.top;
            CGFloat activationDistance = refreshControlHeight * self.relativeChangeOffset;
            CGFloat activeRange = refreshControlHeight * self.relativeChangeRate;
            CGFloat fullDistance = activationDistance + activeRange;

            // 1. distance smaller then activationDistance: set value to 0
            // 2. distance larger then acttivationDistance && smaller then
            // activationDistance + relatevieChangeOffset * refreshControlHeight:
            // set value to somewhere between 1.0f and 0.0f
            // 3. distance larger then (2.): set value to 1.0f

            // 3.
            if (actualDistance >= fullDistance)
            {
                self.refreshControlView.value = 1.0f;
            }
            // 2.
            else if (actualDistance >= activationDistance &&
                     activationDistance < fullDistance)
            {
                CGFloat value = (actualDistance - activationDistance) / activeRange;
                self.refreshControlView.value = value;
            }
            // 1.
            else //if (actualDistance < activationDistance)
            {
                self.refreshControlView.value = 0.0;
            }
        }
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (object == self.refreshControlView)
    {

        BOOL updateScrollViewInsets = NO;
        if (self.refreshControlView.isRefreshing)
        {
            // if the content is not yet adjusted for the refreshcontrol,
            // we need to update
            updateScrollViewInsets = !self.isContentInsetAdjustedForRefreshControl;
            
            // if clients called 'startRefreshing', we will not call our delegate.
            // this can only happen once, so we always set the flag back to YES
            if (self.shouldCallDelegate)
            {
                [self.delegate refreshControllerDidStartRefreshing: self];
            }
            self.shouldCallDelegate = YES;
        }
        else
        {
            //  if the content is adjuested for the refreshcontrol, we need to
            // update
            updateScrollViewInsets = self.isContentInsetAdjustedForRefreshControl;
        }
        [self setNeedsUpdateScollViewInsets: updateScrollViewInsets];
        [self updateScrollViewContentInsetsIfNeeded];
    }
    else
    {
        [super observeValueForKeyPath: keyPath
                             ofObject: object
                               change: change
                              context: context];
    }
}

#pragma mark - layout related
- (void) updateRefreshControlViewFrame
{
    // keep the refresControlView frame always at the top of the scrollView
    CGRect frameForControlView = self.refreshControlView.frame;
    frameForControlView.origin.x = (self.scrollView.frame.size.width / 2.0 -
                                    (CGRectGetWidth(frameForControlView) / 2.0f));
    if (self.isContentInsetAdjustedForRefreshControl)
    {
        frameForControlView.origin.y = (self.scrollView.contentOffset.y +
                                        self.scrollView.contentInset.top -
                                        self.refreshControlView.intrinsicContentSize.height);
    }
    else
    {
        frameForControlView.origin.y = (self.scrollView.contentOffset.y +
                                        self.scrollView.contentInset.top);
    }

    self.refreshControlView.frame = frameForControlView;
}
- (void) updateScrollViewContentInsetsIfNeeded
{
    // if still dragging, we do nothing, it would look weird having
    // views jump under the users' finger
    // in didEndDragging this method will be called again, so then we update
    if (!self.scrollView.isDragging &&
        self.needsUpdateScollViewInsets) // only do something if we need to uppate
    {
        [self setNeedsUpdateScollViewInsets: NO]; // we update now, so a next call won't unless the state changed
        
        // determine how to adjust
        if (self.isContentInsetAdjustedForRefreshControl)
        {
            
            CGFloat updatedTopInset = (self.scrollView.contentInset.top -
                                       self.refreshControlView.intrinsicContentSize.height);
            
            // the offset changes when the contentInset gets set, so we capture
            // the value before we change the contentInset
            CGPoint offset = self.scrollView.contentOffset;
            self.scrollView.contentInset = UIEdgeInsetsMake(updatedTopInset,
                                                            self.scrollView.contentInset.left,
                                                            self.scrollView.contentInset.bottom,
                                                            self.scrollView.contentInset.right);
            // set the offset back to what it was (changing contentOffset has
            // no visible changes, other then changing the offset)
            self.scrollView.contentOffset = offset;
            
            // update our state
            self.contentInsetAdjustedForRefreshControl = NO;
            
            // update the frame of the frame, timing is important, so we cannot
            // take this out of this conditional
            [self updateRefreshControlViewFrame];
            
            // of the offset is below zero (dragged down) we animate the scrollview
            // back to zero manually. But we only do this if the top of the content
            // is overlapping or touching the edge of the refreshcontrol.
            // If the offset is smaller then the height of the refreshControlView
            // the scollView will bounce itself to offset 0
            if (offset.y < 0.0f &&
                offset.y >= -self.refreshControlView.intrinsicContentSize.height)
            {
                [UIView animateWithDuration: 0.35
                                      delay: 0.0f
                                    options: UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x,
                                                                                 -self.scrollView.contentInset.top);
                                 }
                                 completion:^(BOOL finished) {
                                     // the content is now positioned at the top,
                                     // we can start reporting values to the refreshControl again
                                     self.shouldReportValueToRefreshControl = YES;
                                 }];
            }
            else if (offset.y > 0)
            {
                self.shouldReportValueToRefreshControl = YES;
            }
        }
        else
        {
            // restore the scollview back to before we made changes to it
            
            // capture the offset before changing the insets, as setting the insets
            // wil change the offset too
            CGPoint contentOffset = self.scrollView.contentOffset;
            CGFloat updatedTopInset = (self.scrollView.contentInset.top +
                                       self.refreshControlView.intrinsicContentSize.height);
            self.scrollView.contentInset = UIEdgeInsetsMake(updatedTopInset,
                                                            self.scrollView.contentInset.left,
                                                            self.scrollView.contentInset.bottom,
                                                            self.scrollView.contentInset.right);
            
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x,
                                                        contentOffset.y);
            self.contentInsetAdjustedForRefreshControl = YES;
            [self updateRefreshControlViewFrame];
            
            
            if (contentOffset.y >= 0 &&
                contentOffset.y <= self.refreshControlView.intrinsicContentSize.height)
            {
                [UIView animateWithDuration: 0.35
                                 animations:^{
                                     self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x,
                                                                                 -self.refreshControlView.intrinsicContentSize.height);
                                 }];
            }
        }
    }
}
@end
