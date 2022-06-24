//
//  UIImage+image.h
//  ZCTabBarController
//
//  Created by 张策 on 14/12/4.
//  Copyright © 2014年 ZC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (image)
+ (instancetype)imageWithOriginalName:(NSString *)imageName;

+ (instancetype)imageWithStretchableName:(NSString *)imageName;

/// 获取屏幕截图
///
/// @return 屏幕截图图像
+ (UIImage *)scott_screenShot;


/**
 *  生成一张高斯模糊的图片
 *
 *  @param image 原图
 *  @param blur  模糊程度 (0~1)
 *
 *  @return 高斯模糊图片
 */
+ (UIImage *)scott_blurImage:(UIImage *)image blur:(CGFloat)blur;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
