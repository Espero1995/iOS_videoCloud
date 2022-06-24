//
//  UIBarButtonItem+item.h
//  ZCTabBarController
//
//  Created by 张策 on 14/12/4.
//  Copyright © 2014年 ZC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (item)
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
