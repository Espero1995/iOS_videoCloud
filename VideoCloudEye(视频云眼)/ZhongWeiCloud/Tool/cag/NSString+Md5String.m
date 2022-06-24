//
//  NSString+Md5String.m
//  app
//
//  Created by 张策 on 16/1/25.
//  Copyright © 2016年 ZC. All rights reserved.
//

#import "NSString+Md5String.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (Md5String)
+ (NSString *)stringWithMd5:(NSString *)input
{
    
    
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%2s",result];
    }
    return ret;
}
+ (NSString *)isNullToString:(id)string
{
    if ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"])
    {
        return @"";
        
        
    }else
    {
        
        return (NSString *)string;
    }
}

//电话号码处理
+ (NSString *)formatPhoneNum:(NSString *)phone
{
    
    // 处理电话号码
    NSMutableCharacterSet *charSet = [[NSMutableCharacterSet alloc] init];
    [charSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    [charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [charSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    NSArray *arrayWithNumbers = [phone componentsSeparatedByCharactersInSet:charSet];
    NSString *numberStr = [arrayWithNumbers componentsJoinedByString:@""];
    if (! numberStr) {
        numberStr = @"";
    }
    
    if ([numberStr hasPrefix:@"86"]) {
        NSString *formatStr = [numberStr substringWithRange:NSMakeRange(2, [numberStr length]-2)];
        return formatStr;
    }
    else if ([numberStr hasPrefix:@"+86"])
    {
        if ([numberStr hasPrefix:@"+86·"]) {
            NSString *formatStr = [numberStr substringWithRange:NSMakeRange(4, [numberStr length]-4)];
            return formatStr;
        }
        else
        {
            NSString *formatStr = [numberStr substringWithRange:NSMakeRange(3, [numberStr length]-3)];
            return formatStr;
        }
    }
    return numberStr;
}
///1.判断字符串是否为空
+(BOOL)isNull:(NSString*) str
{
    if([str isKindOfClass:[NSNull class]]||str==nil||str==NULL||[str isEqualToString:@"(null)"]){
        return YES;
    }else{
        NSString *str1=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([str1 isEqualToString:@""]||str1.length<1) {
            return YES;
        }
        return NO;
    }
}

//检测密码
+(BOOL)checkPassWord:(NSString *)testPsd
{
    //6-20位数字和字母组成
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:testPsd]) {
        return YES ;
    }else
        return NO;
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - 正则判断电话号正确格式
+ (BOOL)validateMobile:(NSString *)mobile
{
    // 130-139  150-153,155-159  180-189  145,147  170,171,173,176,177,178
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(16[0-9])|(14[0-9])||(19[0-9])|(17[0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


#pragma mark - 正则判断邮箱正确格式
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - 正则判断域名正确格式
+ (BOOL)isValidateDomain:(NSString *)domain
{
//    NSString *emailRegex = @"^(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$";
    NSString * emailRegex = @"^[0-9A-Za-z./:]{1,50}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:domain];
}

@end
