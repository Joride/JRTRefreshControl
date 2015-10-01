//
//  RefreshControl.h
//  RefreshControl
//
//  Created by Joride on 15-08-15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

@import UIKit;


/*!
 @class RefreshControl : UIView
 This view will move trough a number of appearances that depend on the value
 property.
 *  The view starts with a default appearance.
 *  When the value is set to a value larger then 0.0 and smaller then 1.0, it
    will change with that value (e.g. adding dials to a circle, or alpha change)
 *  When the value is set to 1.0f (or larger), the view changes to another state
    (e.g. rotating forever). The isRefreshing property also flips to YES.
 *  When a client then calls -stopRefreshing, it will change its appearance to
    a stopped state (e.g. hidden). This will set the isRefreshing property to NO.
 *  When the client has called -stopRefreshing, the necxt time a value is set,
    an instance of this class will reset itself to the default appearance.
 
 @note This is an abstract subclass in the same sense as a UIGestureRecognizer
 is abstract: it handles some logic internally; a subclass should be created
 to have an actual animation or some visual effect to indicate changes.
 Make sure the implementation file of a subclass imports
 BPURefreshControlView+Subclassing.h and overrides the methods declared there.
 */
@interface JRTRefreshControlView : UIView

/*! 
 @property CGFloat value
 The value that controls the appearance of the view as the user scrolls. It will
 be capped to a value larger then 0.0f and smaller than 1.0f. Defaults to 0.0f.
 @note When isRefreshing is YES, setting this value has no effect on the 
 appearance of the receiver.
 */
@property (nonatomic) CGFloat value;

/*!
 @property BOOL isRefreshing
 This property indicates whether the receiver is currently in the refreshing
 appearence. 
 @note When this property is YES, setting the value property has no effect.
 @note This property is observable on the main thread.
 */
@property (nonatomic, readonly) BOOL isRefreshing; // observable

/*!
 @method -(void) stopRefreshing
 If the isRefreshing property is YES, this method will make the view move to an 
 inactive appearance. It will also flip the isRefreshing flag.
 Subclasses have to call supers implementation of this method at some point
 in their implementation where it makes sense (e.g. inside the implmentation
 of this method, or when an animation finishes).
 @note when isRefreshing is NO, calling this method has no effect.
 */
- (void) stopRefreshing;

/*!
 @method -(void)resumeRefreshingState
 The default implementation does nothing. This method can be called to tell the
 view to resume animations that might have been cancelled because the scrollView
 went out of the viewHierarchy while an animation was in progress. 
 It is up to clients of this class to call this at the appropriate time.
 @note An example is a viewController that lives inside a tabBarController:
 tapping another tab and then back to the original tap might cause the described
 behaviour.
 */
- (void) resumeRefreshingState;
@end

