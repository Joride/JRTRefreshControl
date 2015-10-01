//
//  RefreshControl+Subclassing.h
//  RefreshControl
//
//  Created by Joride on 19-08-15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "JRTRefreshControlView.h"

/*!
 @category RefreshControlView (Subclassing)
 This category should be imported by subclasses of RefreshControlView.
 This allows subclasses to override the neccessary methods.
 */
@interface JRTRefreshControlView (Subclassing)
/*!
 @method -(void)update
 This method is called when the receiver should update it's appearance in response
 to a change in value. When self isRefreshing is YES, you should change the
 appearence of the receiver to a state that indicates loading. If self
 isRefreshing is NO, you should change the appearance of the receiver based on
 the value.
 @note this method requires that you call super first in your implementation.
 */
- (void) update NS_REQUIRES_SUPER;

/*!
 @method -(void)reset
 This method is called when the receiver should move back to a default, starting
 state. Most notably, this is called when clients of this class called
 -stopRefreshing.
 */
- (void) reset;

/*!
 @property (nonatomic, getter=isActive) BOOL active;
 This property can be overridden by sublcasses to set the refreshControlView to
 an inactive state. The default implementation sets the hidden property of the
 receiver to the value of inactive.
 The receiver is considered active when it is either refreshing, and the 
 scrollView's contentOffset.y is < 0.
 */
@property (nonatomic, getter=isActive) BOOL active;

/*!
 @method -(void)saveRefreshinState
 The default implementation does nothing. When this method is called, the
 receiver is still in the isRefreshing = YES state. Animation might become
 interrupted as the receiver is moved out of the window. Use this method to store
 any state you need to resume animations in -resumeRefreshingState.
 */
- (void) saveRefreshingState;

/*!
 @method -(void)resumeRefreshingState
 The default implementation does nothing. When this method is called, the
 receiver is still in the isRefreshing = YES state. Animations might have been
 interrupted beause the receiver was moved out of a window.
 */
- (void) resumeRefreshingState;

/*!
 @method -(void) willMoveToWindow:(UIWindow *)newWindow
 Although UIView's implementation of this method does nothing,
 BPURefreshControlView has some logic in this method, and subclasses are
 required to call super's implmenentation.
 @see UIView.h
 */
-(void) willMoveToWindow:(UIWindow *)newWindow NS_REQUIRES_SUPER;
@end
