//
//  JRTEqualizerRefreshingView.h
//  RefreshControl
//
//  Created by Joride on 05-09-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTRefreshControlView.h"

/*!
 @class JRTEqualizerRefreshingView : JRTRefreshControlView
 This class is a concrete subclass of JRTRefreshControlView.
 While the values increases, bars are appearing from left to right. Upon
 isRefreshing, the individual bars will animate a random change in size and
 color. Upon stop, the bars increas their size, rotate and fade out, while being
 the frontmost layer.
 */
@interface JRTEqualizerRefreshingView : JRTRefreshControlView

@end
