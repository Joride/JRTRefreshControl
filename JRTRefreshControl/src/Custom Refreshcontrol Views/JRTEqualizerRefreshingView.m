//
//  JRTEqualizerRefreshingView.m
//  RefreshControl
//
//  Created by Joride on 05-09-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTEqualizerRefreshingView.h"
#import "JRTRefreshControl+Subclassing.h"
//#import "JRTRectangleLayer.h"
#import "UIColor+Additions.h"

@interface JRTEqualizerRefreshingView ()
@property (nonatomic, readonly) NSArray * rectangleLayers;
@property (nonatomic, readonly) NSArray * rectangleColors;
@property (nonatomic) CGFloat originalZPosition;
@end

@implementation JRTEqualizerRefreshingView
@synthesize rectangleColors = _rectangleColors;
- (CGFloat) numberOfBars
{
    return 120;
}
- (CGFloat) barWidth
{
    return 2;
}
- (CGFloat) maxBarHeight
{
    return 30;
}
- (CGFloat) animationDuration
{
    return 0.30;
}
- (NSArray *)rectangleColors
{
    if (nil == _rectangleColors)
    {
        NSMutableArray * colors;
        colors = [[NSMutableArray alloc] initWithCapacity: [self numberOfBars]];
        for (NSInteger index = 0; index < [self numberOfBars]; index++)
        {
            [colors addObject: [UIColor randomColor]];
        }
        _rectangleColors = colors;
    }
    return _rectangleColors;
}

-(CGSize)intrinsicContentSize
{
    return CGSizeMake([self numberOfBars] * [self barWidth],
                      [self maxBarHeight]);
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void) setup
{
    NSMutableArray * rectangleLayers;
    rectangleLayers = [[NSMutableArray alloc] initWithCapacity: [self numberOfBars]];
    for (NSInteger index = 0; index < [self numberOfBars]; index++)
    {
        CAShapeLayer * rectangleLayer = [[CAShapeLayer alloc] init];
        UIColor * color = [UIColor lightGrayColor];
        rectangleLayer.fillColor = color.CGColor;

        [self.layer addSublayer: rectangleLayer];
        [rectangleLayers addObject: rectangleLayer];
    }
    _rectangleLayers = rectangleLayers;
}
-(void)layoutSubviews
{
    [super layoutSubviews];

    for (NSInteger index = 0; index < [self numberOfBars]; index++)
    {
        CGRect frameForBarLayer = CGRectZero;
        frameForBarLayer.size = CGSizeMake([self barWidth],
                                           self.intrinsicContentSize.height);
        frameForBarLayer.origin.x = index * [self barWidth];
        frameForBarLayer.origin.y = 0;

        CAShapeLayer * rectangleLayer = self.rectangleLayers[index];
        rectangleLayer.frame = frameForBarLayer;
        CGRect rectForPath = CGRectInset(rectangleLayer.bounds,
                                         rectangleLayer.lineWidth * 0.5f,
                                         rectangleLayer.lineWidth * 0.5f);
        rectForPath.size.height = 0;
        rectangleLayer.path = [UIBezierPath bezierPathWithRect: rectForPath].CGPath;
    }
}

#pragma mark -
-(void)update
{
    [self updateBarHeights];

    // super will flip is refreshing to YES as soon as self.value hits 1.0. To
    // avoid the last bar from not being complete, we call super at the end of
    // our implementation.
    [super update];

    if (self.isRefreshing)
    {
        [self startRefreshingAnimation];
    }
}
- (void) startRefreshingAnimation
{
    NSInteger index = 0;
    for (CAShapeLayer * aLayer in self.rectangleLayers)
    {
        UIColor * aColor = self.rectangleColors[index];
        aLayer.fillColor = aColor.CGColor;


        CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath: @"path"];
        pathAnimation.duration = [self animationDuration] + [self animationDuration] * (arc4random() % 11) / 10.0f;

        CGRect zeroHeightRect = aLayer.bounds;
        zeroHeightRect.size.height = zeroHeightRect.size.height * (arc4random() % 11) / 10.0f;
        pathAnimation.toValue = (__bridge id)[UIBezierPath bezierPathWithRect: zeroHeightRect].CGPath;
        pathAnimation.fromValue = (__bridge id) aLayer.path;
        pathAnimation.repeatCount = HUGE_VALF;
        pathAnimation.autoreverses = YES;

        [aLayer addAnimation: pathAnimation
                      forKey: @"pathAnimation"];

        CABasicAnimation * fillColorAnimation = [CABasicAnimation animationWithKeyPath: @"fillColor"];
        fillColorAnimation.duration = [self animationDuration] + [self animationDuration] * (arc4random() % 11) / 10.0f;

        fillColorAnimation.toValue = (__bridge id)[UIColor randomColor].CGColor;
        fillColorAnimation.fromValue = (__bridge id)[UIColor randomColor].CGColor;
        fillColorAnimation.repeatCount = HUGE_VALF;
        fillColorAnimation.autoreverses = YES;

        [aLayer addAnimation: fillColorAnimation
                      forKey: @"fillColorAnimation"];
        index++;
    }
}
- (void) updateBarHeights
{
    CGFloat valueIntervalPerBar = 1.0 / [self numberOfBars];
    for (NSInteger index = 0; index < [self numberOfBars]; index++)
    {
        CAShapeLayer * rectangleLayer = self.rectangleLayers[index];

        CGFloat minOfValueIntervalForBar = index * valueIntervalPerBar;
        CGFloat maxOfValueIntervalForBar = (index + 1) * valueIntervalPerBar;

        CGRect rectForPath = CGRectNull;
        if (self.value > maxOfValueIntervalForBar)
        {
            rectForPath = CGRectInset(rectangleLayer.bounds,
                                             rectangleLayer.lineWidth * 0.5f,
                                             rectangleLayer.lineWidth * 0.5f);
        }
        if (self.value < minOfValueIntervalForBar)
        {
            rectForPath = CGRectInset(rectangleLayer.bounds,
                                             rectangleLayer.lineWidth * 0.5f,
                                             rectangleLayer.lineWidth * 0.5f);
            rectForPath.size.height = 0;
        }
        if (self.value >= minOfValueIntervalForBar &&
            self.value <= maxOfValueIntervalForBar)
        {
            CGFloat normalizedValue = ((self.value - minOfValueIntervalForBar) /
                                       valueIntervalPerBar);
            rectForPath = CGRectInset(rectangleLayer.bounds,
                                             rectangleLayer.lineWidth * 0.5f,
                                             rectangleLayer.lineWidth * 0.5f);
            rectForPath.size.height *= normalizedValue;
        }
        rectangleLayer.path = [UIBezierPath bezierPathWithRect: rectForPath].CGPath;

    }
}
- (void)stopRefreshing
{
    self.originalZPosition = self.layer.zPosition;
    self.layer.zPosition = FLT_MAX;
    // create a crazy animation, call super when it ends
    for (CALayer * aLayer in self.rectangleLayers)
    {
        NSNumber * toScale = @(3.0f + 5.0f * (arc4random() % 11) / 10.0f);
        CABasicAnimation * scaleX;
        scaleX = [CABasicAnimation animationWithKeyPath: @"transform.scale.x"];
        scaleX.fromValue = @(1.0);
        scaleX.toValue = toScale;

        CABasicAnimation * scaleY;
        scaleY = [CABasicAnimation animationWithKeyPath: @"transform.scale.y"];
        scaleY.fromValue = @(1.0);
        scaleY.toValue = toScale;

        CABasicAnimation * rotation;
        rotation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
        rotation.fromValue = @(0.0f);
        rotation.toValue = @(-1.0f * M_PI + 2.0f * M_PI * (arc4random() % 11) / 10.0f);

        CABasicAnimation * fadeOut;
        fadeOut = [CABasicAnimation animationWithKeyPath: @"opacity"];
        fadeOut.fromValue = @(1.0f);
        fadeOut.toValue = @(0);
        aLayer.opacity = 0.0f;

        CAAnimationGroup * combinedAnimation = [[CAAnimationGroup alloc] init];
        combinedAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
        combinedAnimation.duration = 1.0 + 1.0 * (arc4random() % 11) / 10.0f;
        combinedAnimation.animations = @[scaleY,
                                         scaleX,
                                         rotation,
                                         fadeOut];
        combinedAnimation.delegate = self;
        [aLayer addAnimation: combinedAnimation
                      forKey: @"scaleAndRotateAnimation"];
    }
}
-(void)animationDidStop: (CAAnimation *) animation
               finished: (BOOL) flag
{
    for (CAShapeLayer * aShapeLayer in self.rectangleLayers)
    {
        [aShapeLayer removeAnimationForKey: @"pathAnimation"];
        [aShapeLayer removeAnimationForKey: @"fillColorAnimation"];
        [aShapeLayer removeAnimationForKey: @"scaleAndRotateAnimation"];
    }
    self.layer.zPosition = self.originalZPosition;
    [super stopRefreshing];
}
-(void)reset
{
    self.layer.zPosition = self.originalZPosition;
    for (CAShapeLayer * aShapeLayer in self.rectangleLayers)
    {
        [aShapeLayer removeAnimationForKey: @"pathAnimation"];
        [aShapeLayer removeAnimationForKey: @"fillColorAnimation"];
        [aShapeLayer removeAnimationForKey: @"scaleAndRotateAnimation"];

        aShapeLayer.opacity = 1.0f;
        aShapeLayer.fillColor = [UIColor whiteColor].CGColor;
        CGRect rectForPath = CGRectInset(aShapeLayer.bounds,
                                         aShapeLayer.lineWidth * 0.5f,
                                         aShapeLayer.lineWidth * 0.5f);
        rectForPath.size.height = 0;
    }
}
-(void)resumeRefreshingState
{
    if (self.isRefreshing)
    {
        [self startRefreshingAnimation];
    }
}

@end
