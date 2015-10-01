//
//  RefresingScrollViewController.h
//  RefreshControl
//
//  Created by Joride on 04-09-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import UIKit;

#import "JRTRefreshController.h"

@interface RefreshingScrollViewController : UIViewController
<UIScrollViewDelegate,
JRTRefreshControllerDelegate>

/*!
 @property UIScrollView * scrollView
 For convenience, so all refresh logic can stay in this superclass.
 Subclass should overwrite this and return a scrollView instance.
 */
@property (weak, readonly) UIScrollView * scrollView;

/*!
 @method - (Class) refreshControlViewClass
 This method should be overridden by sublasses.
 @return a subclass of RefreshControlView.
 */
- (Class) refreshControlViewClass;

/*!
 @method -(CGFloat )relativeChangeOffset
 Can be overridden by subclasses. The value returned indicates the distance
 the scrollView scrolls before any changes will oocur to the refreshControl.
 Set to zero to change the refreshControl from scrollOffset zero. Set to
 2 to start change the refreshControl only after twice the heigth has been 
 scrolled down.
 @return A CGFloat.
 */
- (CGFloat ) relativeChangeOffset;

/*!
 @method -(CGFloat )relativeChangeRate
 Can be overridden by subclasses. The value returned indicates the distance
 the scrollView scrolls to reach 100% change. Return 1 to indicate scrolling the
 height of the refresControl subclass will cause 100% change. Set to 3 to require
 3 times the heigth of the refreshControl before 100% is reached.
 @return A CGFloat.
 */
- (CGFloat ) relativeChangeRate;
@end
