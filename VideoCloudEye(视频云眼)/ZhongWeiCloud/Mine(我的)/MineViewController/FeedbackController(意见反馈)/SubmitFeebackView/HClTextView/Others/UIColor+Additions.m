//
//  UIColor+Additions.m
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import "UIColor+Additions.h"

//设置颜色RGB
#define RGBA(r,g,b,a)         [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define RGB(r,g,b)            [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@implementation UIColor (Additions)

//设置颜色
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


+ (UIColor *) colorFromHexCode:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }

    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];

    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *) navigationBarColor
{
    //return [UIColor colorFromHexCode:@"2fd2dc"];
    //
    return [UIColor blueFillColor];
}

+ (UIColor *)navigationBarDarkColor
{
    return [UIColor blueFillColor];
}

+ (UIColor *) bgColor
{

    return [UIColor colorFromHexCode:@"f5f5f5"];

}

+ (UIColor *) redTextColor
{
   return [UIColor colorFromHexCode:@"ef0303"];
}

+ (UIColor *) grayTextColor
{
    return [UIColor colorFromHexCode:@"#666666"];
}


+ (UIColor *)leftGrayTextColor
{
    return RGB(153, 153, 153);
}

+ (UIColor *)goldenColor
{
    return RGB(255, 154, 20);
}

+ (UIColor *)orangeNormalColor
{
    return RGB(255,154,20);
}

+ (UIColor *)orangeFillColor
{
    return RGB(255,127,20);
}



+ (UIColor *)darkOrangeFillColor
{
    return [UIColor colorFromHexCode:@"dd3b04"];
}

+ (UIColor *)borderCellColor
{
    return RGB(205, 206, 207);
}

+ (UIColor *)borderCellBgColor
{
    return RGB(244, 244, 244);
}

+ (UIColor *)blueFillColor
{
    return RGB(37, 169, 255);
}

+ (UIColor *)grayCellBgColor
{
    return RGB(237, 237, 237);
}

+ (UIColor *)separatorColor
{
    return RGB(218, 219, 220);
}

- (UIImage *)colorImageWithSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (UIImage *)selectedTitleImageWithSize:(CGSize)size div:(CGFloat)div
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGRect titleRect = CGRectMake(0.0f, size.height*(div-1)/div, size.width, size.height/div);
    CGContextFillRect(context, titleRect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

@end
