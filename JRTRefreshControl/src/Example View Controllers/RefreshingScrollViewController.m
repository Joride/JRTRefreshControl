//
//  RefresingScrollViewController.m
//  RefreshControl
//
//  Created by Joride on 04-09-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "RefreshingScrollViewController.h"

@interface RefreshingScrollViewController ()
@property (nonatomic, strong) JRTRefreshController * refreshController;
@property (nonatomic, getter=shouldShowRefreshControlAutomatically) BOOL showRefreshControlAutomatically;
@end

@implementation RefreshingScrollViewController

#pragma mark - Customization points
- (CGFloat ) relativeChangeOffset
{
    return 1.0;
}
- (CGFloat ) relativeChangeRate
{
    return 1.0f;
}
- (Class) refreshControlViewClass
{
    NSAssert(NO, @"Have subclasses implement this");
    return nil;
}

#pragma mark -
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // set this to YES, to simulate setting therefreshControlView
    // programmatically to refreshing
    self.showRefreshControlAutomatically = NO;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];

    if (nil == self.refreshController)
    {
        // create and set up the refreshController
        self.refreshController = [[JRTRefreshController alloc]
                                  initWithScrollView: self.scrollView
                                  refreshControlViewClass: [self refreshControlViewClass]];
        self.refreshController.delegate = self;

        // start changing the refreshControlView after the scrollView
        // scrolled down to relativeChangeOffset times the height
        // of the refreshControlView
        self.refreshController.relativeChangeOffset = [self relativeChangeOffset];

        // drag relativeChangeRate times the height of the refreshControlView
        // for the refreshControlView to change to the isRefreshing state.
        self.refreshController.relativeChangeRate = [self relativeChangeRate];
    }

    if (self.shouldShowRefreshControlAutomatically)
    {
        self.showRefreshControlAutomatically = NO;
        // illustrate what happens when calling -startRefreshing
        // (this is normally in respons to some loading that was triggered by
        // something other then the user pulling to refresh).
        dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW,
                                                 (int64_t)(0.3 * NSEC_PER_SEC));
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_after(duration,
                       mainQueue,
                       ^{
                           [self.refreshController startRefreshing];
                           
                           dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW,
                                                                    (int64_t)(1 * NSEC_PER_SEC));
                           dispatch_after(duration,
                                          mainQueue,
                                          ^{
                                              [self.refreshController stopRefreshing];
                                          });
                       });
    }
}

#pragma mark - JRTRefreshControllerDelegate
- (void) refreshControllerDidStartRefreshing: (JRTRefreshController  *) refreshController
{
    // fake a network or loading job to start here, with
    // a callback that stops the refreshcontrol after some time
    CGFloat time = 2.0f + (arc4random() % 10) / 10.0f * 3.0f;
    
    dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW,(int64_t)(time * NSEC_PER_SEC));
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_after(duration,
                   mainQueue,
                   ^{
                       [self.refreshController stopRefreshing];
                   });
}

/*
 *
 * These are the methods that are required to be forwarded to the 
 * refreshController in order for it to work.
 *
 */
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshController scrollViewDidScroll];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate
{
    [self.refreshController scrollViewDidEndDragging];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.refreshController scrollViewDidEndDecelerating];
}


@end
