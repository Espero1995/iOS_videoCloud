//
//  NSString+Md5String.h
//  app
//
//  Created by 张策 on 16/1/25.
//  Copyright © 2016年 ZC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Md5String)
//MD5处理
+ (NSString *)stringWithMd5:(NSString *)input;
//空字符串处理
+ (NSString *)isNullToString:(id)string;
//电话号码处理
+ (NSString *)formatPhoneNum:(NSString *)phone;
//判断字符串是否为空
+ (BOOL)isNull:(NSString*) str;
//检测密码6-18数字+字母
+ (BOOL)checkPassWord:(NSString *)testPsd;
+ (NSString *)md5:(NSString *)str;
//判断是否是正确的手机号码
+ (BOOL)validateMobile:(NSString *)mobile;
//判断是否是正确的邮箱
+ (BOOL)isValidateEmail:(NSString *)email;
//判断是否是正确的域名
+ (BOOL)isValidateDomain:(NSString *)domain;
@end
