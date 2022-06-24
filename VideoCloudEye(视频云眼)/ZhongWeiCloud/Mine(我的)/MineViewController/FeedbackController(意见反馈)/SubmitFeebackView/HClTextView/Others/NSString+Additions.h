//
//  NSString+Additions.h
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSString+Valid.h"

@interface NSString (Additions)
//算文字高度
+ (CGSize)sizeFromString:(NSString *)string font:(UIFont *)font floatWidth:(CGFloat)floatWidth;
//+ (NSString)stringWi


//获取设备类型
+ (NSString *)getCurrentDeviceModel;


- (NSString *)bankCardNumberHidePrivacyInfo;

- (BOOL)isContainSpecailText;

+ (NSString *)nothingFormatterToNumber:(NSString *)numberFormatter;
- (NSString *)numberFormatter:(NSString *)num;

+ (NSString *)number:(NSString *)num;
- (NSString *)md5_16;
- (NSString *)md5_32;

- (NSString *)stringByAppendingStringOrNilString:(NSString *)aStringOrNilString;

//+ (NSString *)stringByAppendingFormat:(NSString *)format, ...;


+ (NSString *)URLWithBaseURLString:(NSString *)urlString method:(NSString *)method parameters:(NSDictionary *)parameters;



+ (NSURL *)URLWithBaseURLString:(NSString *)baseString relativeURLString:(NSString *)relativeString;
+ (NSURL *)URLWithURLString:(NSString *)urlStr;
- (NSURL *)URL;

+ (NSString *)meterStringWithCGFloatMeter:(CGFloat)meter;
- (NSString *)stringByReplaceWrapToSpace;
/**
 *  是否  有效的手机号码
 */
+ (BOOL)validateMobileNumber:(NSString *)string;
+ (NSString *)mobileNumberServiceName:(NSString *)string;

//是否有效的身份证号
+ (BOOL)validateIDCardNumber:(NSString *)idNumber;

/**
 *  是否  有效的邮件地址
 */
+ (BOOL)validateEmailAddress:(NSString *)address;
/**
 *  是否  有效的url地址
 */
+ (BOOL)validateURL:(NSString *)address;

+ (BOOL)isAllSpaceString:(NSString *)aString;
- (BOOL)isEmptyOrWhitespace;

+ (BOOL)validatePassword:(NSString *)string;
- (BOOL)isValidatePassword;

+ (NSString *)stringOfChineseWeekdayWithDate:(NSDate *)date;

- (NSString *)formatDateStringFromFormat:(NSString *)fromFormat
                                toFormat:(NSString *)toFormat;

//是否是正确IP
+ (BOOL)isValildIPAddress:(NSString *)ipAddress;
//端口
+ (BOOL)isValidIPPort:(NSString *)ipPort;

//关键字检索
//+ (NSMutableArray *)keywordsOfString:(NSString *)str;


//textField 金额输入限制
+ (BOOL)isValidMoneyWithTextField:(UITextField *)textField
                        maxLength:(NSUInteger)maxLength
                            range:(NSRange)range
                replacementString:(NSString *)string;

#pragma mark - calculate text width and height
- (CGFloat)heightWithFont:(UIFont *)font forWidth:(CGFloat)width NS_AVAILABLE_IOS(6_0);//测试OK
- (CGFloat)widthWithFont:(UIFont *)font NS_AVAILABLE_IOS(6_0);//测试OK
// Single line,
- (CGSize)textSizeWithFont:(UIFont *)font NS_AVAILABLE_IOS(6_0);//未测试
//NSLineBreakByWordWrapping
- (CGSize)textSizeWithFont:(UIFont *)font forWidth:(CGFloat)width NS_AVAILABLE_IOS(6_0);//未测试

//calulate width and height (这个方法 参数 和名字 存在问题...后期会修改掉,  用上面方法)
- (CGSize)sizeWithFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode NS_AVAILABLE_IOS(6_0);

- (NSMutableAttributedString *)attributedStringOfString:(NSString *)attrString attributes:(NSDictionary *)attributes;
- (NSMutableAttributedString *)attributedStringOfString:(NSString *)attrString
                                       stringAttributes:(NSDictionary *)stringAttributes
                                    allStringAttributes:(NSDictionary *)allStringAttributes;


//default Font is systemFont size 14 blackColor && highlightText
- (NSMutableAttributedString *)attributedStringWithHighlightText:(NSString *)highlightText
                                               highlightTextFont:(UIFont *)highlightTextFont
                                              highlightTextColor:(UIColor *)highlightTextColor
                                                        textFont:(UIFont *)textFont
                                                       textColor:(UIColor *)textColor;



- (void)textDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;


@end
