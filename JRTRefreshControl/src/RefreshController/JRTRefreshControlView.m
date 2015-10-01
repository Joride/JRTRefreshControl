//
//  RefreshControl.m
//  RefreshControl
//
//  Created by Joride on 15-08-15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "JRTRefreshControlView.h"
#import "JRTRefreshControl+Subclassing.h"


@interface JRTRefreshControlView ()
@property (nonatomic, readwrite) BOOL isRefreshing;
@property (nonatomic, getter=shouldCallResetOnNewValue) BOOL callResetOnNewValue;
@end

@implementation JRTRefreshControlView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
        [center addObserver: self
                   selector: @selector(applicationWillEnterForeground:)
                       name: UIApplicationWillEnterForegroundNotification
                     object: nil];
        [center addObserver: self
                   selector: @selector(applicationDidEnterBackground:)
                       name: UIApplicationDidEnterBackgroundNotification
                     object: nil];
    }
    return self;
}
- (void) applicationWillEnterForeground: (NSNotification *) notification
{
    if (self.isRefreshing)
    {
        [self resumeRefreshingState];
    }
}
- (void) applicationDidEnterBackground: (NSNotification *) notification
{
    if (self.isRefreshing)
    {
        [self saveRefreshingState];
    }
}
-(void)dealloc
{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver: self
                      name: UIApplicationWillEnterForegroundNotification
                    object: nil];
    [center removeObserver: self
                      name: UIApplicationDidEnterBackgroundNotification
                    object: nil];
}
-(void)setValue:(CGFloat)value
{
    // we update our state only when we are not refreshing
    if (!self.isRefreshing)
    {
        if (self.shouldCallResetOnNewValue)
        {
            [self reset];
            self.callResetOnNewValue = NO;
        }
        // if the value is the same, we do nothing
        if (value != _value)
        {
            // cap the value to not exceed 1.00f
            if (value > 1.00f)
            {
                _value = 1.00f;
            }
            // cap the value to not exceed 0.00f
            else if (value < 0.00f)
            {
                _value = 0.00f;
            }
            else
            {
                _value = value;
            }
            [self update];
        }
    }
}
- (void) update
{
    if (_value >= 1.00)
    {
        // larger then max, we need to flip isRefreshing to YES
        // if that is not already the case
        if (!self.isRefreshing)
        {
            self.isRefreshing = YES;
        }
    }
}
- (void)stopRefreshing
{
    // only change state if we are actually refreshing
    if (self.isRefreshing)
    {
        self.isRefreshing = NO;
        self.callResetOnNewValue = YES;
    }
}
-(CGSize)sizeThatFits:(CGSize)size
{
    return [self intrinsicContentSize];
}
- (void) reset
{
    // intended for subclasses to restore to the default state
    ;
}
-(void)setActive:(BOOL)active
{
    self.hidden = !active;
}
-(BOOL)isActive
{
    return !self.isHidden;
}
- (void) resumeRefreshingState
{
    // intended for subclasses to restore to the default state
    ;
}
- (void) saveRefreshingState
{
    // intended for subclasses to restore to the default state
    ;
}
-(void)willMoveToWindow:(UIWindow *)newWindow
{
    if (self.isRefreshing)
    {
        if (nil != newWindow )
        {
            // self was taken out of the window, which means that animations
            // might have stopped.
            [self resumeRefreshingState];
        }
        else
        {
            // self was inserted back into the window while we are still
            // refreshing. Give subclasses a change to resume animations.
            [self saveRefreshingState];
        }
    }
}
@end

