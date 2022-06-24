//
//  NSString+Additions.m
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+Additions.h"
#import "sys/utsname.h"
//#import "Hanzi2Pinyin.h"

@implementation NSString (Additions)



+ (NSString *)getCurrentDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";// (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";// (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";// (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";// (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";// (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";// (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";// (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";// (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";// (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";// (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";// (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";// (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";// (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6Plus";// (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";// (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";// (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";// (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";// (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";// (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";// (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";// (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";// (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";// (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";// (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";// (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";// (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";// (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";// (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";// (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";// (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";// (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";// (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";// (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";// (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";// (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";// (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";// (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";// (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";// (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";// (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}



- (NSString *)bankCardNumberHidePrivacyInfo
{
    NSMutableString *str = [NSMutableString string];
    if (self.length <= 8) {
        return self;
    }
    [str setString:self];
    [str deleteCharactersInRange:NSMakeRange(4, self.length-8)];
    [str insertString:@"*****" atIndex:4];
    return str;
}

- (BOOL)isContainSpecailText
{
    BOOL ret = ([self rangeOfString:@"#:="].location != NSNotFound || [self rangeOfString:@"@:="].location != NSNotFound);
    
    return ret;
}

-(NSString *)numberFormatter:(NSString *)num{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    //    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setPositiveFormat:@"###,##0.00;"];
    return [nf stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
}


+ (NSString *)number:(NSString *)num{
    if (num.length==0) {
        return @"";
    }
    num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
    num = [num stringByReplacingOccurrencesOfString:@";" withString:@""];
    return num;
}


+ (NSString *)nothingFormatterToNumber:(NSString *)numberFormatter{
    NSArray *numStrings = [numberFormatter componentsSeparatedByString:@","];
    if ([numStrings count]==1) {
        return numberFormatter;
    }
    NSMutableString *mutableNum = [NSMutableString string];
    for (NSString *subNumString in numStrings) {
        [mutableNum appendString:subNumString];
    }
    
    return [NSNumber numberWithDouble:[mutableNum doubleValue]].stringValue;
}


- (NSString *)md5_16
{
    NSString *string32 = [self md5_32];
    NSString *string16 = [string32 substringWithRange:NSMakeRange(8, 16)];
    return string16;
}

- (NSString *)md5_32
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    
    
    NSString *string32 = [NSString stringWithFormat:
                          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          result[0], result[1], result[2], result[3],
                          result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11],
                          result[12], result[13], result[14], result[15]
                          ];
    
    return string32;
}



+ (NSString *)URLWithBaseURLString:(NSString *)urlString method:(NSString *)method parameters:(NSDictionary *)parameters
{
    
    NSString *url = [[urlString stringByAppendingString:@"?method="] stringByAppendingString:method];
    
    for(NSString *key in [parameters allKeys])
    {
        url = [url stringByAppendingString:[@"&" stringByAppendingString:[parameters objectForKey:key]]];
    }
    
    return url;
}


- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}


- (NSString *)stringByAppendingStringOrNilString:(NSString *)aStringOrNilString
{
    return [self stringByAppendingString:aStringOrNilString == nil ? @"" : aStringOrNilString];
}

+ (NSURL *)URLWithBaseURLString:(NSString *)baseString relativeURLString:(NSString *)relativeString
{
    if (baseString == nil) {
        baseString = @"";
    }
    
    if (relativeString == nil) {
        relativeString = @"";
    }
    
    return [NSURL URLWithString:[baseString stringByAppendingString:relativeString]];
}

+ (NSURL *)URLWithURLString:(NSString *)urlStr
{
    return [urlStr URL];
}

- (NSURL *)URL
{
    return [NSURL URLWithString:self];
}


+ (NSString *)meterStringWithCGFloatMeter:(CGFloat)meter
{
    NSUInteger value = meter;
    
    if (value < 1000) {
        
        if (value > 10) {
            value -= value%10;
        }
        return [NSString stringWithFormat:@"%lu米",(unsigned long)value];
    }
    else {
        value = value/1000;
        
        if (value > 10) {
            value -= value%10;
        }
        
        
        return [NSString stringWithFormat:@"%lu公里",(unsigned long)value];
    }
    
}

- (NSString *)stringByReplaceWrapToSpace
{
    NSString *str = [self stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return str;
}


+ (BOOL)validateIDCardNumber:(NSString *)value {
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length = 0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;
        
        if (length !=15 && length !=18)
            return NO;
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag = NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag = YES;
            break;
        }
    }
    
    if (!areaFlag)
        return NO;
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0))
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            else
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            
            numberofMatch = [regularExpression numberOfMatchesInString:value options:NSMatchingReportProgress range:NSMakeRange(0, value.length)];
            
            if(numberofMatch > 0)
                return YES;
            else
                return NO;
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0))
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            else
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            
            numberofMatch = [regularExpression numberOfMatchesInString:value options:NSMatchingReportProgress range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                
                int Y = S % 11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]])
                    return YES;// 检测ID的校验位
                else
                    return NO;
            }else
                return NO;
        default:
            return NO;
    }
}

+ (BOOL)validateMobileNumber:(NSString *)string
{
    NSString * MOBILE = @"^1(3[0-9]|4[0-9]|5[0-9]|7[0-9]|8[0-9])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:string];
}

+ (NSString *)mobileNumberServiceName:(NSString *)string
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:string] == YES) || ([regextestcm evaluateWithObject:string] == YES) || ([regextestct evaluateWithObject:string] == YES) || ([regextestcu evaluateWithObject:string] == YES)){
        if([regextestcm evaluateWithObject:string] == YES)
            return @"China Mobile";
        else if([regextestct evaluateWithObject:string] == YES)
            return @"China Telecom";
        else if ([regextestcu evaluateWithObject:string] == YES)
            return @"China Unicom";
        else
            return @"Unknow";
        
    }else
        return @"Unknow";
}

+ (BOOL)validateEmailAddress:(NSString *)address
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,8}";
    NSPredicate *emailMatch = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    if (![emailMatch evaluateWithObject:address]) {
        return NO;
    }
    return YES;
}


+ (BOOL)validateURL:(NSString *)address{
    NSString *emailRegex = @"(([a-zA-Z0-9._-]+.[a-zA-Z]{2,6})|([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9&%_./-~-]*)?";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:address];
}

+ (BOOL)validatePassword:(NSString *)string
{
#if DEBUG_xu
    return YES;
#else
    
    if (string.length < 6 || string.length > 20) {
        return NO;
    }
    
    return YES;
    //    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    //    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    //    return [passWordPredicate evaluateWithObject:string];
    //    NSString *pwsRegex = @"^[@A-Za-z0-9!#$%^&*.~]{6,20}$";
    //    NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwsRegex];
    //    return [pwdTest evaluateWithObject:string];
#endif
}


- (BOOL)isValidatePassword
{
    return [NSString validatePassword:self];
}


+ (NSString *)stringOfChineseWeekdayWithDate:(NSDate *)date
{
    NSString *weekstr = @"";
    
    if (date) {
        NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
        switch ([componets weekday]) {
            case 1:
                weekstr = @"周日";
                break;
                
            case 2:
                weekstr = @"周一";
                break;
                
            case 3:
                weekstr = @"周二";
                break;
                
            case 4:
                weekstr = @"周三";
                break;
                
            case 5:
                weekstr = @"周四";
                break;
                
            case 6:
                weekstr = @"周五";
                break;
                
            case 7:
                weekstr = @"周六";
                break;
                
            default:
                break;
        }
    }
    
    return weekstr;
}

- (NSString *)formatDateStringFromFormat:(NSString *)fromFormat
                                toFormat:(NSString *)toFormat
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = fromFormat;
    NSDate *date = [dateFormatter dateFromString:self];
    dateFormatter.dateFormat = toFormat;
    
    return [dateFormatter stringFromDate:date];
    
}

+ (BOOL)isValildIPAddress:(NSString *)ipAddress
{
    BOOL ret = NO;
    
    NSArray *ipList = [ipAddress componentsSeparatedByString:@"."];
    
    if (ipList.count == 4) {
        
        NSString *ip1 = [ipList objectAtIndex:0];
        NSString *ip2 = [ipList objectAtIndex:1];
        NSString *ip3 = [ipList objectAtIndex:2];
        NSString *ip4 = [ipList objectAtIndex:3];
        
        if (ip1.integerValue >= 0 && ip1.integerValue <= 255 &&
            ip2.integerValue >= 0 && ip2.integerValue <= 255 &&
            ip3.integerValue >= 0 && ip3.integerValue <= 255 &&
            ip4.integerValue >= 0 && ip4.integerValue <= 255) {
            ret = YES;
        }
    }
    
    return ret;
}

+ (BOOL)isValidIPPort:(NSString *)ipPort
{
    BOOL ret = NO;
    
    if (ipPort && ipPort.integerValue >= 0 && ipPort.integerValue <= 65535) {
        ret = YES;
    }
    
    return ret;
    
}

//
//+ (NSMutableArray *)keywordsOfString:(NSString *)str
//{
//    //NSMutableArray *array = [NSMutableArray new];
//
//    NSString *pinyin = [[Hanzi2Pinyin convert:str separater:@""] uppercaseString];
//    NSArray *pyArray = [pinyin componentsSeparatedByString:@""];
//    //加拼音
//    NSString *preStr = @"";
//    NSString *preShortStr = @"";
//    for (NSString *tmpStr in pyArray) {
//
//        preStr = [preStr stringByAppendingString:tmpStr];
//        preShortStr = [preShortStr stringByAppendingString:[tmpStr substringToIndex:1]];
//
//        [array addObject:preShortStr];
//        [array addObject:preStr];
//    }
//
//    //加文字
//    preStr = @"";
//    for (NSUInteger index = 0; index < str.length; ++index) {
//
//        preStr = [str substringToIndex:index+1];
//
//        [array addObject:preStr];
//    }
//
//    if (str.length > 0) {
//
//        NSString *pinyin = [[Hanzi2Pinyin convert:str separater:@""] uppercaseString];
//        NSString *shortPY = [[Hanzi2Pinyin convertToAbbreviation:str] uppercaseString];
//
//        if (shortPY.length > 0) {
//            [array addObject:shortPY];
//        }
//
//        if (pinyin.length > 0) {
//            [array addObject:pinyin];
//            [array addObject:str];
//        }
//
//    }
//
//    return array;
//}



+ (BOOL)isValidMoneyWithTextField:(UITextField *)textField
                        maxLength:(NSUInteger)maxLength
                            range:(NSRange)range
                replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if([textField.text isValidMaxLength:maxLength WithRange:range replacementString:string]){
        
        BOOL isHaveDian = YES;
        
        if ([textField.text rangeOfString:@"."].location == NSNotFound) {
            isHaveDian=NO;
        }
        if ([string length] > 0)
        {
            unichar single=[string characterAtIndex:0];//当前输入的字符
            if ((single >='0' && single<='9') || single=='.')//数据格式正确
            {
                //首字母为0和小数点  特殊处理
                if([textField.text length]==0){
                    if(single == '.'){
                        textField.text = @"0.";
                        return NO;
                        
                    }
                    if (single == '0') {
                        textField.text = @"0.";
                        return NO;
                        
                    }
                }
                if (single=='.')
                {
                    if(!isHaveDian)//text中还没有小数点
                    {
                        isHaveDian = YES;
                        return YES;
                    }else
                    {
                        //                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                    }
                }
                else
                {
                    if (isHaveDian)//存在小数点
                    {
                        //判断小数点的位数
                        NSRange ran=[textField.text rangeOfString:@"."];
                        NSInteger tt= range.location - ran.location;
                        if (tt <= 2){
                            return YES;
                        }else{
                            return NO;
                        }
                    }
                    else
                    {
                        return YES;
                    }
                }
            }else{//输入的数据格式不正确
                //                [textField.text stringByReplacingCharactersInRange:range withString:@""];
                return NO;
            }
        }
        else
        {
            // string.length == 0 的时候 是删除
            if([textField.text isEqualToString:@"0."]){
                textField.text = @"";
                return NO;
            }
            return YES;
        }
        
        
    }else{
        
        return NO;
    }
}


#pragma  mark - text

- (CGFloat)heightWithFont:(UIFont *)font forWidth:(CGFloat)width
{
    return [self textSizeWithFont:font forWidth:width].height;
    
}

- (CGFloat)widthWithFont:(UIFont *)font
{
    return [self textSizeWithFont:font forWidth:CGFLOAT_MAX].width;
}


- (CGSize)textSizeWithFont:(UIFont *)font NS_AVAILABLE_IOS(6_0)
{
    return [self textSizeWithFont:font forWidth:CGFLOAT_MAX];
}

//NSLineBreakByWordWrapping
- (CGSize)textSizeWithFont:(UIFont *)font forWidth:(CGFloat)width NS_AVAILABLE_IOS(6_0)
{
    CGSize retSize;
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName, nil];
        CGRect rect = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil];
        retSize = rect.size;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        retSize = [self sizeWithFont:font constrainedToSize:maxSize];
#pragma clang diagnostic pop
    }
    
    return retSize;
}

- (CGSize)sizeWithFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize size = CGSizeZero;
    if (!font) {
        return size;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName, nil];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self attributes:attributes];
    
    size = [attributedString size];
    
    return size;
}

//算高度
+ (CGSize)sizeFromString:(NSString *)string font:(UIFont *)font floatWidth:(CGFloat)floatWidth{
    if (!string) {
        return CGSizeZero;
    }
    CGFloat width = floatWidth*[[UIScreen mainScreen] bounds].size.width;
    if (floatWidth>1) {
        width = floatWidth;
    }
    return [string boundingRectWithSize:CGSizeMake(width, 10000)
                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size;
}

- (NSMutableAttributedString*)attributedStringOfString:(NSString *)attrString attributes:(NSDictionary *)attributes
{
    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    
    if (!font) {
        font = [UIFont systemFontOfSize:14];
        
    }
    
    NSMutableAttributedString *retString = [self attributedStringOfString:attrString
                                                         stringAttributes:attributes
                                                      allStringAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    return retString;
}

- (NSMutableAttributedString *)attributedStringOfString:(NSString *)attrString
                                       stringAttributes:(NSDictionary *)stringAttributes
                                    allStringAttributes:(NSDictionary *)allStringAttributes
{
    NSMutableAttributedString *retString = [[NSMutableAttributedString alloc] initWithString:self];
    if (stringAttributes == nil)
        return retString;
    
    
    if (attrString == nil)
        attrString = @"";
    
    if (allStringAttributes == nil)
        allStringAttributes = stringAttributes;
    
    
    UIFont *font = [stringAttributes objectForKey:NSFontAttributeName];
    if (font) {
        [retString setAttributes:allStringAttributes range:NSMakeRange(0, self.length)];
    }
    
    NSRange range = [self rangeOfString:attrString];
    [retString addAttributes:stringAttributes range:range];
    
    return retString;
}

- (NSMutableAttributedString *)attributedStringWithHighlightText:(NSString *)highlightText
                                               highlightTextFont:(UIFont *)highlightTextFont
                                              highlightTextColor:(UIColor *)highlightTextColor
                                                        textFont:(UIFont *)textFont
                                                       textColor:(UIColor *)textColor
{
    UIFont *defaultFont = [UIFont systemFontOfSize:14];
    UIColor *defaultColor = [UIColor blackColor];
    if (!highlightTextFont)
        highlightTextFont = defaultFont;
    
    if (!textFont)
        textFont = defaultFont;
    
    if (!highlightTextColor)
        highlightTextColor = defaultColor;
    
    if (!textColor)
        textColor = defaultColor;
    
    
    NSDictionary *textDic = @{NSFontAttributeName:textFont,
                              NSForegroundColorAttributeName:textColor};
    NSDictionary *highlightDic = @{NSFontAttributeName:highlightTextFont,
                                   NSForegroundColorAttributeName:highlightTextColor};
    
    NSMutableAttributedString *attr = [self attributedStringOfString:highlightText
                                                    stringAttributes:highlightDic
                                                 allStringAttributes:textDic];
    
    return attr;
}


+ (BOOL)isAllSpaceString:(NSString *)aString
{
    aString = [aString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return aString.length == 0 ? YES : NO;
}

- (BOOL)isEmptyOrWhitespace
{
    return !self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (void)textDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment
{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = alignment;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [self drawInRect:rect withAttributes:attributes];
}

@end
