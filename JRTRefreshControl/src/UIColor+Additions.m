//
//  UIColor+Additions.m
//  RefreshControl
//
//  Created by Joride on 04/09/15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)
+(UIColor *)randomColor
{
    CGFloat red = (arc4random() % 101) / 100.0f;
    CGFloat green = (arc4random() % 101) / 100.0f;
    CGFloat blue = (arc4random() % 101) / 100.0f;
    UIColor * randomColor = [UIColor colorWithRed: red
                                            green: green
                                             blue: blue
                                            alpha: 1.0];
    return randomColor;
}
@end
