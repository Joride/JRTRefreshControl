//
//  ViewController.m
//  RefreshControl
//
//  Created by Joride on 15-08-15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "ScrollViewController.h"
#import "JRTRefreshController.h"
#import "JRTRotatingRefreshControlView.h"
#import "UIColor+Additions.h"

@interface ScrollViewController ()
@property (weak, nonatomic, readwrite) IBOutlet UIScrollView * scrollView;
@end

@implementation ScrollViewController
@synthesize scrollView = _scrollView;
#pragma mark -
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self setupScrollViewSubviews];
}
-(void)viewDidLayoutSubviews
{
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame),
                                             1500);
}
- (CGFloat ) relativeChangeOffset
{
    return 1.2;
}
- (CGFloat ) relativeChangeRate
{
    return 2.0f;
}
#pragma mark -
- (void) setupScrollViewSubviews
{
    NSInteger numberOfSubviews = 20;
    CGFloat viewHeight = self.scrollView.contentSize.height / numberOfSubviews;

    for (NSInteger index  = 0; index < numberOfSubviews; index++)
    {
        CGRect frameForView = CGRectMake(0,
                                         viewHeight * index - 4,
                                         self.scrollView.frame.size.width,
                                         viewHeight);
        
        UIView * aView = [[UIView alloc] initWithFrame: CGRectInset(frameForView, 10, 4)];
        aView.backgroundColor = [UIColor randomColor];
        [self.scrollView addSubview: aView];
    }
}
-(Class)refreshControlViewClass
{
    return [JRTRotatingRefreshControlView class];
}
@end
