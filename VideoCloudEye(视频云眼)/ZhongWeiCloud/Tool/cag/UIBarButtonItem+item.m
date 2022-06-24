//
//  UIBarButtonItem+item.m
//  ZCTabBarController
//
//  Created by 张策 on 14/12/4.
//  Copyright © 2014年 ZC. All rights reserved.
//

#import "UIBarButtonItem+item.h"
#import "UIView+frame.h"
@implementation UIBarButtonItem (item)
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    // btn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [btn sizeToFit];
    
    [btn addTarget:target action:action forControlEvents:controlEvents];
    
    return  [[UIBarButtonItem alloc] initWithCustomView:btn];
}
@end
