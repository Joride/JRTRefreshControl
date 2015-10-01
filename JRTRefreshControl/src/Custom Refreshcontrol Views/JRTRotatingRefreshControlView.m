//
//  RotatingRefreshControl.m
//  RefreshControl
//
//  Created by Joride on 19-08-15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "JRTRotatingRefreshControlView.h"
#import "JRTRefreshControl+Subclassing.h"

NSString * const kJRTFadeAndScaleAnimationName = @"JRTFadeAndScaleAnimation";
NSString * const kJRTRotationAnimationName = @"JRTRotationAnimation";

static const CGFloat kOneLapseDuration = 2.0f;

@interface JRTRotatingRefreshControlView ()
@property (nonatomic) CGFloat previousValue;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) CABasicAnimation * rotationAnimation;
@end

@implementation JRTRotatingRefreshControlView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        _previousValue = -1;
        UIImage * image = [UIImage imageNamed: @"spinner"];
        self.imageView = [[UIImageView alloc] initWithImage: image];
        [self addSubview: self.imageView];
    }
    return self;
}
-(void)update
{
    [super update];
    if (!self.isRefreshing)
    {
        CGFloat angle = 2.0f * M_PI * self.value;
        CGFloat scale = 1.0 + (self.value / 4.0f);
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale,
                                                                      scale);
        CGFloat yOffset = (scale - 1.0) * CGRectGetHeight(self.bounds);
        CGAffineTransform translateTransform;
        translateTransform = CGAffineTransformMakeTranslation(0.00f,
                                                              yOffset);
        CGAffineTransform transform = CGAffineTransformConcat(scaleTransform,
                                                              translateTransform);

        void (^viewChanges)(void) = ^{
            // the transform is set to identity in when we reach a value of 1.0
            // in the else clause
            self.transform = transform;
            self.imageView.layer.transform = CATransform3DMakeRotation(angle,
                                                                       0.0f,
                                                                       0.0f,
                                                                       1.0f);
        };

        CGFloat valueDelta = ABS(self.previousValue - self.value);
        BOOL shouldAnimate = NO;
        if (self.previousValue > -1)
        {
            if (valueDelta > 0.1)
            {
                shouldAnimate = YES;
            }
        }
        if (shouldAnimate)
        {
            CGFloat maxAnimationDuration = kOneLapseDuration;
            CGFloat animationDuration = maxAnimationDuration * self.value;

            [UIView animateWithDuration: animationDuration
                             animations: viewChanges];
        }
        else
        {
            viewChanges();
        }
        self.previousValue = self.value;
    }
    else
    {
        self.rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        self.rotationAnimation.duration = kOneLapseDuration;
        self.rotationAnimation.repeatCount = HUGE_VALF;
        self.rotationAnimation.fromValue = @(0.0f);
        self.rotationAnimation.toValue = @(2.0f * M_PI);
        self.rotationAnimation.delegate = self;
        [self.imageView.layer addAnimation: self.rotationAnimation
                                    forKey: kJRTRotationAnimationName];

        [UIView animateWithDuration: 0.8f
                              delay: 0.0f
             usingSpringWithDamping: 0.3f
              initialSpringVelocity: 1.0f
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.transform = CGAffineTransformIdentity;
                         }
                         completion: NULL];
    }
}
-(void)animationDidStop:(CAAnimation *)animation
               finished:(BOOL)flag
{
    if (animation == self.rotationAnimation)
    {
        // this one should never stop, it means that the scrollView is no
        // longer in the window
    }
    else
    {
        [self.layer removeAnimationForKey: kJRTFadeAndScaleAnimationName];
        [self.imageView.layer removeAnimationForKey: kJRTRotationAnimationName];
    }
}
- (void) stopRefreshing
{
    CABasicAnimation * opacityAnimation;
    opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat: 1.0f];
    opacityAnimation.toValue = [NSNumber numberWithFloat: 0.0f];
    opacityAnimation.fillMode = kCAFillModeForwards;

    CABasicAnimation * scaleAnimationX;
    scaleAnimationX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleAnimationX.fromValue = [NSNumber numberWithFloat: 1.0f];
    scaleAnimationX.toValue = [NSNumber numberWithFloat: 0.0f];

    CABasicAnimation * scaleAnimationY;
    scaleAnimationY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleAnimationY.fromValue = [NSNumber numberWithFloat: 1.0f];
    scaleAnimationY.toValue = [NSNumber numberWithFloat: 0.0f];

    CAAnimationGroup * scaleGroup = [[CAAnimationGroup alloc] init];
    scaleGroup.duration = 0.35f;
    scaleGroup.animations = @[scaleAnimationX,
                              scaleAnimationY,
                              opacityAnimation];
    scaleGroup.delegate = self;
    [self.layer addAnimation: scaleGroup
                      forKey: kJRTFadeAndScaleAnimationName];

    // make sure the layer stays invisible after the animation
    self.layer.opacity = 0.0f;

    // we call super to signal we've just stopped refreshing. Super handles some
    // logic.
    [super stopRefreshing];
}
- (void) reset
{
    _previousValue = -1;
    self.imageView.layer.transform = CATransform3DMakeRotation(0.0f,
                                                               0.0f,
                                                               0.0f,
                                                               1.0f);
    self.layer.opacity = 1.0f;
}
-(CGSize)intrinsicContentSize
{
    return self.imageView.image.size;
}
-(CGSize)sizeThatFits:(CGSize)size
{
    return [self intrinsicContentSize];
}
- (void) resumeRefreshingState
{
    if (nil != self.rotationAnimation &&
        ![self.imageView.layer.animationKeys containsObject: kJRTRotationAnimationName])
    {
        [self.imageView.layer addAnimation: self.rotationAnimation
                                    forKey: kJRTRotationAnimationName];
    }
}
@end
