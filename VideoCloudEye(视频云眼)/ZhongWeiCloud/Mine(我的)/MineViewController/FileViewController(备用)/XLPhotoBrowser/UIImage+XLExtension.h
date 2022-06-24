//
//  UIImage+XLExtension.h
//  XLPhotoBrowserDemo
//
//  Created by ehang on 2016/10/26.
//  Copyright © 2016年 LiuShannoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XLExtension)


/**
 返回一张指定size的指定颜色的纯色图片

 @param color 传入的颜色
 @param size 传入的大小
 @return 返回一张指定颜色的纯色图片
 */
+ (UIImage *)xl_imageWithColor:(UIColor *)color size:(CGSize)size;

@end
