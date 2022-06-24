//
//  UIColor+Expand.m
//  KQC
//
//  Created by wsw on 15/11/27.
//  Copyright © 2015年 吴神文. All rights reserved.
//

#import "UIColor+Expand.h"

@implementation UIColor (Expand)

#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *) colorWithHexString: (NSString *)color
{
    
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *)colorWithHex:(NSUInteger)colorHex
{
    return [self colorWithHex:colorHex alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSUInteger)colorHex alpha:(CGFloat)alpha;
{
    unsigned int red = (colorHex & 0xFF0000) >> 16;
    unsigned int green = (colorHex & 0x00FF00) >> 8;
    unsigned int blue = (colorHex & 0xFF);
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (UIColor *)normalRedColor
{
    return [self colorWithHex:0xfa7206];
}

+ (UIColor *)hightlightRedColor
{
    return [self colorWithHex:0xDC5900];
}

+ (UIColor *)grayRedColor
{
    return [self colorWithHex:0xf1a28b];
}

+ (UIColor *)blackTextColor
{
    return [self colorWithHex:0x262626];
}

+ (UIColor *)grayTextColor
{
    return [self colorWithHex:0x999999];
}

@end
