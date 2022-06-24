//
//  UIColor+Expand.h
//  KQC
//
//  Created by wsw on 15/11/27.
//  Copyright © 2015年 吴神文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Expand)

+ (UIColor *) colorWithHexString: (NSString *)color;

+ (UIColor *)colorWithHex:(NSUInteger)colorHex;
+ (UIColor *)colorWithHex:(NSUInteger)colorHex alpha:(CGFloat)alpha;

+ (UIColor *)normalRedColor;
+ (UIColor *)hightlightRedColor;
+ (UIColor *)grayRedColor;
+ (UIColor *)blackTextColor;
+ (UIColor *)grayTextColor;

@end
