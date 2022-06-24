//
//  UIView+frame.m
//  ZCTabBarController
//
//  Created by 张策 on 14/12/4.
//  Copyright © 2014年 ZC. All rights reserved.
//

#import "UIView+frame.h"

@implementation UIView (frame)
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
-(void)setOrigin:(CGPoint)origin{
    self.x          = origin.x;
    self.y          = origin.y;
}

- (void)setMAX_X:(CGFloat)MAX_X
{
//    CGRect frame = self.frame;
//    frame.size.height = self.height;
//    frame.origin.x = self.x;
//    self.frame = frame;
}
- (CGFloat)MAX_X
{
    return self.x+self.width;
}
- (CGFloat)MAX_Y
{
    return self.y+self.height;
}
@end
