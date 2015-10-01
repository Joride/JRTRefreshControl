# JRTRefreshControl
A customizable, generic refreshContorl for any type of UIScrollView

This project contains only Objective-C code.

This is an Xcode 7 project that show how to use a generic refreshControl, and how to create your own animated views for it.
The core of it is in the folder 'RefreshController' (both on disk and in the project).

Example loading views can be found in 'Custom Refreshcontrol views' and example viewController for three kinds of UIScrollView (UIScrollView, UITableView, UICollectionView).
Note1: all logic related to setting up the refreshController is in a common viewController-superclass.
Note2: creating and setting up the refrehsController should be done in whatever object is the delegate of the UIScrollView (in this exampe that's the viewController);
