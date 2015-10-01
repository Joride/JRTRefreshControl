//
//  NewtonsCradleRefreshControlView.h
//  RefreshControl
//
//  Created by Joride on 04-09-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTRefreshControlView.h"

/*!
 @class JRTNewtonsCradleRefreshControlView : JRTRefreshControlView
 Concrete subclass of JRTRefreshControlView.
 This class shows a number of circles. On update, a random number of circles
 will move to the left. Upon isRefreshing, the circles move back causing an
 equal number of circle on the other side to move out.
 Upon stopRefreshing, the circles will move to left and right and fade out.
 This is attempting to simulate Newton's Cradle.
 */
@interface JRTNewtonsCradleRefreshControlView : JRTRefreshControlView

@end
