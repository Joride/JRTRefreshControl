//
//  RotatingRefreshControl.h
//  RefreshControl
//
//  Created by Joride on 19-08-15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "JRTRefreshControlView.h"

/*!
 @class RotatingRefreshControlView : RefreshControlView
 This class shows an image. As the value changes, part of that image rotates
 with the value. When isRefreshing is YES, the image starts rotating
 indefinitely until -stopRefreshing is called.
 @note Implementing -(CGSize)intrinsicContentSize is required.
 */
@interface JRTRotatingRefreshControlView : JRTRefreshControlView
@end
