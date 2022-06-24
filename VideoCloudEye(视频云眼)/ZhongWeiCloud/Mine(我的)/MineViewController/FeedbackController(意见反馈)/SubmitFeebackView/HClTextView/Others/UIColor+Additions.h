//
//  UIColor+Additions.h
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define RGBA(r,g,b,a)         [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
//#define RGB(r,g,b)            [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIColor (Additions)
+ (UIColor *) colorWithHexString: (NSString *)color;
+ (UIColor *) colorFromHexCode:(NSString *)hexString;


+ (UIColor *) navigationBarColor;
+ (UIColor *) navigationBarDarkColor;



+ (UIColor *) redTextColor;
+ (UIColor *) grayTextColor;
+ (UIColor *) leftGrayTextColor;

+ (UIColor *)borderCellColor;
//
+ (UIColor *)borderCellBgColor;
//金色
+ (UIColor *)goldenColor;

//黄色
+ (UIColor *)orangeNormalColor;
+ (UIColor *)orangeFillColor;
+ (UIColor *)darkOrangeFillColor;

//蓝色
+ (UIColor *)blueFillColor;

+ (UIColor *)grayCellBgColor;

//tableview
+ (UIColor *)separatorColor;

- (UIImage *)colorImageWithSize:(CGSize)size;
//上面透明 下面颜色
- (UIImage *)selectedTitleImageWithSize:(CGSize)size div:(CGFloat)div;

/* Blend using the NSCalibratedRGB color space. Both colors are converted into the calibrated RGB color space, and they are blended by taking fraction of color and 1 - fraction of the receiver. The result is in the calibrated RGB color space. If the colors cannot be converted into the calibrated RGB color space the blending fails and nil is returned.
 */
//- (UIColor *)blendedColorWithFraction:(CGFloat)fraction ofColor:(UIColor *)color;

@end
