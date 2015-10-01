//
//  RefreshController.h
//  RefreshControl
//
//  Created by Joride on 21-08-15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

@import UIKit;

@class JRTRefreshController;

/*!
 @protocol JRTRefreshControllerDelegate <NSObject>
 An instance of JRTRefreshController will call its delegate to signal certain
 events happened.
 */
@protocol JRTRefreshControllerDelegate <NSObject>
/*!
 @method -(void)refreshControllerDidStartRefreshing:(JRTRefreshController  *)refreshController
 This method will be called when the refreshControlView that is managed by an
 instance JRTRefreshController changes it's state to isRefreshing.
 You can use this method to kick of some loading process. Typically, you call
 -stopRefreshing on the refreshController when that process is done.
 */
- (void) refreshControllerDidStartRefreshing: (JRTRefreshController  *) refreshController;
@end

/*!
 @class RefreshController : NSObject
 An instance of this class can be used to coordindate a refreshController
 between a scrollView and clients (i.e. scrollViewDelegates).
 To make this class work, have your scrollView-delegate call through to this
 object with the three methods -scrollViewDidScroll:, scrollViewDidEndDecelerating:
 and -scrollViewDidEndDragging:willDecelerate:.
 @note When an instance of this class gets deallocated, it will remove the 
 refreshControlView from the scrollView.
 @warning Clients should not manipulate the refreshControl in any way, as this
 will lead to undefined behaviour.
 */
@interface JRTRefreshController : NSObject
-(instancetype)init NS_UNAVAILABLE;

/*!
 @property id <JRTRefreshControllerDelegate> delegate
 The delegate of the receiver.
 */
@property (nonatomic, weak) id <JRTRefreshControllerDelegate> delegate;

/*!
 @property BOOL hidesRefreshControlViewWhenInactive
 When the refreshControlView is not refreshin, and the scrollView is not pulled
 down, the refreshControl is considered inactive, and the receiver will set
 the overidable property active on the refreshControlView. The default
 implementation of the refreshControlView will set itself to hidden when it is
 inactive. This allows scrollviews to have gaps in their content and have the
 refreshControl be hidden when there is no pull-to-refresh ongoing.
 When set to NO, the receiver will set the refreshControlView to active, and
 not update it's active status any more.
 */
@property (nonatomic) BOOL hidesRefreshControlViewWhenInactive; // defaults to YES

/*!
 @method -(instancetype)initWithScrollView: (UIScrollView *) scrollView superViewOfScrollView: (UIView *) view
 This is the designated initializer of this class. The receiver will keep a weak
 reference to the scrollView.
 @param scrollView
 Required. The scrollView to which a refreshControlView will be added.
 @param refreshControlViewClass
 A class that the controller will instantiate and use as the refreshControl.
 Required. This class MUST be a subclass of RefreshControlView;
 @return A fully initialized instance.
 */
-(instancetype)initWithScrollView: (UIScrollView *) scrollView
          refreshControlViewClass: (Class) refreshControlViewClass
NS_DESIGNATED_INITIALIZER;

/*!
 @property CGFloat changeRate
 This property influences the rate of change of the refreshControlView relative
 to the contentOffset of the scrollView. Defaults to 1.0f;
 This value defaults to 1.0f, which means that scrolling one height of the the
 refreshControlView sets the value of the refreshControlView to 1.0f. Setting
 this value to 0.25, will set the value of the refreshControlView to 1.0f after
 scrolling one quarter of the height of the refreshcontrolView.
 */
@property (nonatomic) CGFloat relativeChangeRate;

/*!
 @property CGFloat changeOffset
 This property affects the moment where the refreshControlView is going to
 receive change-updates, relative to it's size. Defaults to 0.0f, meaning
 that the the refreshControlView starts to receive updates from zero.
 Setting this property to 1.0f will start giving the refreshCntrolView updates
 after scrolling the size of the refreshControlView.
 */
@property (nonatomic) CGFloat relativeChangeOffset;

/*!
 @method -(void)stopRefreshing
 Call this method after the delegate has had a callback telling it that the 
 receiver did start refreshing. Calling this method when the refreshControl has
 not started refreshing does nothing.
 */
- (void) stopRefreshing;

/*!
 @method -(void)startRefreshing
 Call this method to manually set the refreshControl to the loading state.
 Calling this method when the refreshControl is already refreshing will do 
 nothing.
 */
- (void) startRefreshing;

/*!
 @method -(void)scrollViewDidScroll
 This method should be called every time scrollViewDidScroll: is called on the
 delegate of the scrollView that the receiver was initialized with.
 */
-(void)scrollViewDidScroll;

/*!
 @method -(void)scrollViewDidEndDragging
 This method should be called every time scrollViewDidEndDragging:willDecelerate
 is called on the delegate of the scrollView that the receiver was initialized
 with.
 */
-(void) scrollViewDidEndDragging;

/*!
 @method -(void)scrollViewDidEndDecelerating
 This method should be called every time scrollViewDidEndDecelerating: is called
 on the delegate of the scrollView that the receiver was initialized with.
 */
- (void) scrollViewDidEndDecelerating;


@end
