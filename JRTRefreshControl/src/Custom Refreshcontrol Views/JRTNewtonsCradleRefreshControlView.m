//
//  NewtonsCradleRefreshControlView.m
//  RefreshControl
//
//  Created by Joride on 04-09-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTNewtonsCradleRefreshControlView.h"
#import "JRTRefreshControl+Subclassing.h"

NSString * const kJRTFadeAndScaleAnimationNewtonsCradle = @"JRTFadeAndScaleAnimationNewtonsCradle";

@interface JRTNewtonsCradleRefreshControlView ()
@property (nonatomic, strong) NSArray * ballLayers;
@property (nonatomic) CGRect previousBounds;
@property (nonatomic) BOOL needsReset;
@property (nonatomic, readonly) NSUInteger numberOfActiveBalls;
@end

@implementation JRTNewtonsCradleRefreshControlView
- (CGFloat) maxTravelDistance
{
    return 60;
}
- (CGFloat) ballDiameter
{
    return 12;
}
- (CGFloat) animationDuration
{
    return 0.3;
}
- (NSUInteger) numberOfBalls
{
    return 11;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

-(CGSize)intrinsicContentSize
{
    CGFloat width = ([self numberOfBalls] * [self ballDiameter]);
    return CGSizeMake(width,
                      [self ballDiameter]);
}
- (void) setup
{
    [self updateActiveBalls];

    // create a number of shape layers that are the balls
    NSMutableArray * balls = [[NSMutableArray alloc]
                              initWithCapacity: [self numberOfBalls]];

    for (NSInteger index = 0; index < [self numberOfBalls]; index++)
    {
        CAShapeLayer * ballLayer = [[CAShapeLayer alloc] init];
        ballLayer.fillColor = [UIColor whiteColor].CGColor;

        // single pixel on any device
        ballLayer.lineWidth = 1.0f / [UIScreen mainScreen].scale;
        ballLayer.strokeColor = [UIColor blackColor].CGColor;

        [balls addObject: ballLayer];
        [self.layer addSublayer: ballLayer];
    }
    self.ballLayers = balls;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    if (CGRectEqualToRect(self.previousBounds, self.bounds))
    {
        // creating paths is expensive, we do nothing if the bounds has
        // not actually changed
        return;
    }

    // layout out the balls side by side
    self.previousBounds = self.bounds;
    CGFloat ballWidth = [self ballDiameter];
    NSInteger index = 0;
    for (CAShapeLayer * aShapeLayer in self.ballLayers)
    {
        CGRect frameForShapeLayer = CGRectMake(index * [self ballDiameter],
                                               0,
                                               [self ballDiameter],
                                               ballWidth);
        aShapeLayer.frame = frameForShapeLayer;
        CGRect rectForPath = CGRectInset(aShapeLayer.bounds,
                                          aShapeLayer.lineWidth / 2.0f,
                                          aShapeLayer.lineWidth / 2.0f);
        aShapeLayer.path = [UIBezierPath bezierPathWithOvalInRect: rectForPath].CGPath;
        index++;
    }
}
-(void)animationDidStop: (CAAnimation *)animation
               finished: (BOOL)flag
{
    // animations are copied when added to a layer, so keeping a reference to
    // them and comparing references is not going to work. isEqual: will also
    // not work, so we can check the class to distinguish between different
    // types of animations (in this particalar setup).
    if ([animation isKindOfClass: [CABasicAnimation class]])
    {
        for (NSUInteger index = 0; index < [self numberOfActiveBalls]; index++)
        {
            CALayer * ballLayerMovingBack = self.ballLayers[index];
            CALayer * presentationLayer = (CALayer *)ballLayerMovingBack.presentationLayer;
            ballLayerMovingBack.position = presentationLayer.position;
        }

        // we set a flag to stop at the exact moment a swingin animation is
        // at the end, so we fade out from the resting position
        if (self.needsReset)
        {
            [self runFadeAndMoveAnimation];
            [self setNeedsReset: NO];
        }
        else
        {
            [self runAnimationFromRestingPosition];
        }
    }
    else
    {
        // this is the fadeAndMoveAnimation
        [super stopRefreshing];
        [self.layer removeAnimationForKey: kJRTFadeAndScaleAnimationNewtonsCradle];
    }
}
- (CGFloat)deltaTravelDistance
{
    // give the pull more resistance the closer we get to the max
    CGFloat value = sqrtf(self.value * pow([self maxTravelDistance], 2));
    return value;
}
-(void)update
{
    [super update];

    if (self.isRefreshing)
    {
        [self runAnimationFromDraggedPosition];
    }
    else
    {
        [CATransaction setDisableActions: YES];
        // check the value, move a number of balls

        for (NSInteger index = 0; index < [self numberOfActiveBalls]; index++)
        {
            CALayer * ballLayer = self.ballLayers[index];
            CGPoint newPosition = ballLayer.position;
            CGFloat xPositionAtIndex = [self restingPositionForBallAtIndex: index].x;
            newPosition.x = xPositionAtIndex - [self deltaTravelDistance];

            // the position will be implicitly animated, so
            // we set the disableActions to YES. This is only valid for the
            // current transaction group, so we do not need to flip it back.
            [CATransaction setDisableActions: YES];
            ballLayer.position = newPosition;
        }

        for (CAShapeLayer * aShapeLayer in self.ballLayers)
        {
            CGFloat whiteLevel = 1.0f - (0.5 * [self deltaTravelDistance] / [self maxTravelDistance]);
            aShapeLayer.fillColor = [UIColor colorWithWhite: whiteLevel
                                                      alpha: 1.0f].CGColor;
        }
    }
}
- (void) runAnimationFromRestingPosition
{
    // this animation is very similar to the runAnimationFromDraggedPosition,
    // but also with the initial bounce-out (because the ball has NOT been
    // dragged to the bounced-out position)

    CGFloat duration = [self animationDuration];
    for (NSInteger index = 0; index < [self numberOfActiveBalls]; index++)
    {
        CGFloat restingPositionXOfBallMovingBack;
        restingPositionXOfBallMovingBack = [self restingPositionForBallAtIndex: index].x;
        NSInteger indexOfALayerMovingOut = ([self numberOfBalls] -
                                            1 - index);
        CGFloat restingPositionXOfBallBouncingOut;
        restingPositionXOfBallBouncingOut = [self restingPositionForBallAtIndex: indexOfALayerMovingOut].x;

        CALayer * ballLayerBouncingOutFirst = self.ballLayers[index];
        CALayer * ballLayerBouncingOutSecond;
        ballLayerBouncingOutSecond = (self.ballLayers[[self numberOfBalls] -
                                                      1 - index]);

        CABasicAnimation * bounceOutFirst;
        bounceOutFirst = [CABasicAnimation animationWithKeyPath: @"position.x"];
        bounceOutFirst.duration = duration;
        bounceOutFirst.timingFunction = [self bounceOutTimingFunction];
        bounceOutFirst.toValue = @((restingPositionXOfBallMovingBack -
                                    self.value * [self maxTravelDistance]));
        bounceOutFirst.fromValue = @(restingPositionXOfBallMovingBack);
        bounceOutFirst.autoreverses = YES;
        bounceOutFirst.removedOnCompletion = NO;
        bounceOutFirst.fillMode = kCAFillModeForwards;

        // start an animation that move a ball on the other side away
        CABasicAnimation * bounceOutSecond;
        bounceOutSecond = [CABasicAnimation animationWithKeyPath: @"position.x"];
        bounceOutSecond.duration = duration;
        bounceOutSecond.beginTime = (CACurrentMediaTime() +
                                     2 * bounceOutFirst.duration);
        bounceOutSecond.timingFunction = [self bounceOutTimingFunction];
        bounceOutSecond.fillMode = kCAFillModeForwards;
        bounceOutSecond.removedOnCompletion = YES;
        bounceOutSecond.autoreverses = YES;
        // only exactly one instance of this animation has self as a delegate.
        // When these types of animations end, we either run another one, or we
        // start out reset-animation.
        if (0 == index)
        {
            bounceOutSecond.delegate = self;
        }
        bounceOutSecond.fromValue = @(restingPositionXOfBallBouncingOut);
        CGFloat moveBallOutXPosition = (restingPositionXOfBallBouncingOut +
                                        self.value * [self maxTravelDistance]);
        bounceOutSecond.toValue = @(moveBallOutXPosition);

        [ballLayerBouncingOutFirst addAnimation: bounceOutFirst
                                         forKey: @"moveBallBack"];
        [ballLayerBouncingOutSecond addAnimation: bounceOutSecond
                                          forKey: @"moveBallOut"];
    }
}
- (void) runAnimationFromDraggedPosition
{
    // this animation is very similar to the runAnimationFromRestingPosition,
    // but without the initial bounce-out (because the ball has been dragged
    // to the bounced-out position)

    CGFloat duration = [self animationDuration];
    CGFloat ballWidth = [self ballDiameter];

    for (NSInteger index = 0; index < [self numberOfActiveBalls]; index++)
    {
        CALayer * ballLayerMovingBack = self.ballLayers[index];
        NSInteger indexOfALayerMovingOut = ([self numberOfBalls] -
                                            1 - index);
        CGFloat restingPositionXOfBallBouncingOut;
        restingPositionXOfBallBouncingOut = [self restingPositionForBallAtIndex: indexOfALayerMovingOut].x;

        CALayer * ballLayerMovingOut = self.ballLayers[indexOfALayerMovingOut];

        // start an animation to move the ball that moved out back to the group
        // of balls
        CABasicAnimation * moveBallBack;
        moveBallBack = [CABasicAnimation animationWithKeyPath: @"position.x"];
        moveBallBack.duration = duration;
        moveBallBack.timingFunction = [self fallInTimingFunction];

        CGFloat xPositionAtIndex;
        moveBallBack.fromValue = @(ballLayerMovingBack.position.x);
        xPositionAtIndex = (0.5 * ballWidth) + index * ballWidth;
        moveBallBack.toValue = @(xPositionAtIndex);
        moveBallBack.autoreverses = NO;
        moveBallBack.removedOnCompletion = NO;
        moveBallBack.fillMode = kCAFillModeForwards;

        ////
        // bounce balls out on the other side
        CABasicAnimation * moveBallOut;
        moveBallOut = [CABasicAnimation animationWithKeyPath: @"position.x"];
        moveBallOut.timingFunction = [self bounceOutTimingFunction];
        moveBallOut.fillMode = kCAFillModeForwards;
        moveBallOut.removedOnCompletion = YES;
        moveBallOut.autoreverses = YES;
        moveBallOut.duration = duration;
        moveBallOut.beginTime = CACurrentMediaTime() + moveBallBack.duration;

        // only exactly one of these types of animation will have self as
        // a delegate. When it calls didFinish:, we will start the
        // swinging animation
        if (0 == index)
        {
            moveBallOut.delegate = self;
        }
        moveBallOut.fromValue =  @(restingPositionXOfBallBouncingOut);
        CGFloat moveBallOutXPosition = (restingPositionXOfBallBouncingOut +
                                        self.value * [self maxTravelDistance]);
        moveBallOut.toValue = @(moveBallOutXPosition);

        [ballLayerMovingBack addAnimation: moveBallBack
                                   forKey: @"moveBallBack"];
        [ballLayerMovingOut addAnimation: moveBallOut
                                  forKey: @"moveBallOut"];
    }
}
- (CGPoint) restingPositionForBallAtIndex: (NSInteger) index
{
    CGFloat restingPositionX = ((0.5 * [self ballDiameter]) +
                                index * [self ballDiameter]);

    return CGPointMake(restingPositionX,
                       [self ballDiameter] / 2.0f);
}
- (void) runFadeAndMoveAnimation
{
    NSInteger highestIndexMovingToLeft;
    NSInteger lowestIndexMovingToRight;
    if ([self numberOfBalls] % 2 == 0)
    {
        // all other balls move to the right
        highestIndexMovingToLeft = ([self numberOfBalls] -1) / 2;
        lowestIndexMovingToRight = highestIndexMovingToLeft + 1;
    }
    else
    {
        // there is a middle ball that does not move
        highestIndexMovingToLeft = ([self numberOfBalls]- 1) / 2 - 1;
        lowestIndexMovingToRight = highestIndexMovingToLeft + 2;
    }

    NSInteger index = 0;
    for (CALayer * aLayer in self.ballLayers)
    {
        CABasicAnimation * moveBall;
        moveBall = [CABasicAnimation animationWithKeyPath:@"position.x"];
        moveBall.fromValue = @(aLayer.position.x);

        CABasicAnimation * fadeBall;
        fadeBall = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeBall.fromValue = @(aLayer.opacity);
        fadeBall.toValue = @(0);

        CGFloat newPosition = aLayer.position.x;

        if (index <= highestIndexMovingToLeft)
        {
            NSInteger invertedIndex = [self numberOfBalls] - index;
            newPosition = (aLayer.position.x - (pow(invertedIndex / 2.0, 2)) *
                           [self ballDiameter]);
        }
        else if (index >= lowestIndexMovingToRight)
        {
            newPosition = (aLayer.position.x + (pow(index / 2.0, 2)) *
                           [self ballDiameter]);
        }

        moveBall.toValue = @(newPosition);

        // group the two animations
        CAAnimationGroup * moveAndFadeBall = [[CAAnimationGroup alloc] init];
        moveAndFadeBall.delegate = self;
        moveAndFadeBall.duration = 1.0f;
        moveAndFadeBall.animations = @[moveBall,
                                       fadeBall];

        [aLayer addAnimation: moveAndFadeBall
                      forKey: @"movings"];

        // update the layer model value, so after the animation,
        // the layers don't snap back to the old values
        CGPoint position = aLayer.position;
        position.x = newPosition;

        // the position will be implicitly animated, so
        // we set the disableActions to YES. This is only valid for the
        // current transaction group, so we do not need to flip it back.
        [CATransaction setDisableActions: YES];
        aLayer.position = position;
        
        aLayer.opacity = 0.0f;
        index++;
    }
}
- (CAMediaTimingFunction *) fallInTimingFunction
{
    CAMediaTimingFunction *customTimingFunction;
    CGFloat x1 = 0.85;
    CGFloat y1 = 0.00;
    CGFloat x2 = 0.99;
    CGFloat y2 = 0.99;

    customTimingFunction = [CAMediaTimingFunction functionWithControlPoints: x1: y1
                                                                           : x2: y2];
    return customTimingFunction;
}
- (CAMediaTimingFunction *) bounceOutTimingFunction
{
    // thi is x-invers of the fallInTimingFunction
    CAMediaTimingFunction * customTimingFunction;
    CGFloat x1 = 0.15;
    CGFloat y1 = 0.99;
    CGFloat x2 = 0.99;
    CGFloat y2 = 0.99;

    customTimingFunction = [CAMediaTimingFunction functionWithControlPoints: x1: y1
                                                                           : x2: y2];
    return customTimingFunction;
}
-(void)stopRefreshing
{
    // instead iof stopping immediately, we set a flag. When the swinging
    // animation ends, we start our fade-out animation (this makes our live
    // a little easier as we do not have to compute the fade out and move
    // from the current position of the layers)
    [self setNeedsReset: YES];
}
-(void)reset
{
    // reset everything to the way it was after -setup was called
    // make sure to remove any lingering animations from all layers

    // the position will be implicitly animated, so
    // we set the disableActions to YES. This is only valid for the
    // current transaction group, so we do not need to flip it back.
    [CATransaction setDisableActions: YES];
    NSInteger index = 0;
    for (CAShapeLayer *aLayer in self.ballLayers)
    {
        aLayer.fillColor = [UIColor whiteColor].CGColor;
        [aLayer removeAllAnimations];
        aLayer.opacity = 1.0f;
        // position all balls on their initial frame

        CALayer * ballLayer = self.ballLayers[index];
        CGFloat ballWidth = [self ballDiameter];
        CGRect frameForBall = CGRectMake(ballWidth * index,
                                         0,
                                         ballWidth,
                                         ballWidth);
        ballLayer.frame = frameForBall;
        index++;
    }
    [self updateActiveBalls];
}

- (void) updateActiveBalls
{
    // the numer of ative balls is a random number
    // (min: 1, max: numberOfBalls - 1)
    NSInteger divisor = [self numberOfBalls];
    NSInteger numberOfActiveBalls = arc4random() % divisor;
    numberOfActiveBalls = MAX(1, numberOfActiveBalls);
    _numberOfActiveBalls = numberOfActiveBalls;
}
@end
