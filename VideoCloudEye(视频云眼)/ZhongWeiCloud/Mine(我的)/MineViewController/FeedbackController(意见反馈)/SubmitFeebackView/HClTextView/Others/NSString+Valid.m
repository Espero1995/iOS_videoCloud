//
//  NSString+Valid.m
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import "NSString+Valid.h"

@implementation NSString (Valid)

///合法身份证
- (BOOL)isValidPersonIDCardNumber
{
    NSString *number = self;
    
    if(number.length != 18 && number.length != 15){
        return NO;
    }
    
    if(number.length == 15){
        
        NSArray *area = @[@"11",@"12",@"13",@"14",@"15",@"21",@"22",@"23",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"41",@"42",@"43",@"44",@"45",@"46",@"50",@"51",@"52",@"53",@"54",@"61",@"62",@"63",@"64",@"65",@"71",@"81",@"82",@"91"];
        
        
        if(![self isNumber]){
            //不是纯数字
            return NO;
        }
        
        if(![area containsObject:[self substringWithRange:NSMakeRange(0, 2)]]) {
            //前两位位置不对
            return NO;
        }
        
        NSInteger year = [@"19" stringByAppendingString:[self substringWithRange:NSMakeRange(6, 2)]].integerValue;
        
        NSInteger month = [self substringWithRange:NSMakeRange(8, 2)].integerValue;
        NSInteger day = [self substringWithRange:NSMakeRange(10, 2)].integerValue;
        
        switch (month) {
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
                if(day > 31){
                    return NO;
                }
                break;
            case 4:
            case 6:
            case 9:
            case 11:
                if(day > 30){
                    return NO;
                }
                break;
            case 02:
                if((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
                    if(day>29) {
                        return NO;
                    }
                } else {
                    if(day>28) {
                        
                        return NO;
                    }
                }
                
                break;
                
            default:
                return NO;
                break;
        }
    }
    
    
    if(number.length == 18){
        
        //验证因子
        
        NSString *sChecker = @"1,0,X,9,8,7,6,5,4,3,2";
        NSArray *chekerArray = [sChecker componentsSeparatedByString:@","];
        
        //相乘因子
        NSString *r = @"7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2";
        NSArray *rArray = [r componentsSeparatedByString:@","];
        
        NSInteger sum = 0;
        
        for(int i = 0; i < 17; i++){
            NSString *character = [number substringWithRange:NSMakeRange(i, 1)];
            sum += character.integerValue * [[rArray objectAtIndex:i] integerValue];
        }
        
        NSInteger last = sum%11;
        
        if([[number substringWithRange:NSMakeRange(17, 1)] isEqualToString:[chekerArray objectAtIndex:last]])
        {
            return YES;
        }else{
            return NO;
        }
        
        
    }
    
    
    return NO;
}


//银行卡校验规则(Luhn算法)   
- (BOOL)isValidBankCardNumber
{
    NSInteger len = [self length];
    
    NSInteger sumNumOdd = 0;
    NSInteger sumNumEven = 0;
    BOOL isOdd = YES;
    
    for (NSInteger i = len - 1; i >= 0; i--) {
        
        NSInteger num = [self substringWithRange:NSMakeRange(i, 1)].integerValue;
        if (isOdd) {//奇数位
            sumNumOdd += num;
        }else{//偶数位
            num = num * 2;
            if (num > 9) {
                num = num - 9;
            }
            sumNumEven += num;
        }
        isOdd = !isOdd;
    }
    
    return ((sumNumOdd + sumNumEven) % 10 == 0);

}

- (BOOL)isFlightOrTrainNumber
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[a-zA-Z0-9]+$"];
    return ([pred evaluateWithObject:self] && self.length <= 10);
}


- (BOOL)isNumber
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[0-9]+$"];
    BOOL isnNum = [pred evaluateWithObject:self];
    return isnNum;
}


- (BOOL)isAlphanumeric
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[a-zA-Z0-9]+$"];
    return [pred evaluateWithObject:self];
}
- (BOOL)isChineseAlphabet
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^([A-Za-z]|[\u4E00-\u9FA5])+$"];
    return [pred evaluateWithObject:self];
}

- (BOOL)isValidMobileNumber
{
    NSString * regex = @"^1(3[0-9]|4[0-9]|5[0-9]|7[0-9]|8[0-9])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [regextestmobile evaluateWithObject:self];
}

- (BOOL)isValidEmailAddress
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,8}";
    NSPredicate *emailMatch = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    if (![emailMatch evaluateWithObject:self]) {
        return NO;
    }
    return YES;
}


- (BOOL)isValidHtmlURL
{
    NSString *emailRegex = @"(([a-zA-Z0-9._-]+.[a-zA-Z]{2,6})|([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9&%_./-~-]*)?";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isValidPassword
{
    if (self.length < 6 || self.length > 20) {
        return NO;
    }
    
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:self];
//    NSString *pwsRegex = @"^[@A-Za-z0-9!#$%^&*.~]{6,20}$";
//    NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwsRegex];
//    return [pwdTest evaluateWithObject:self];
}


- (BOOL)isValildIPAddress
{
    BOOL ret = NO;
    
    NSArray *ipList = [self componentsSeparatedByString:@"."];
    
    if (ipList.count == 4) {
        
        NSString *ip1 = [ipList objectAtIndex:0];
        NSString *ip2 = [ipList objectAtIndex:1];
        NSString *ip3 = [ipList objectAtIndex:2];
        NSString *ip4 = [ipList objectAtIndex:3];
        
        if ([ip1 isNumber] && [ip2 isNumber] && [ip3 isNumber] && [ip4 isNumber]) {
            if (ip1.integerValue >= 0 && ip1.integerValue <= 255 &&
                ip2.integerValue >= 0 && ip2.integerValue <= 255 &&
                ip3.integerValue >= 0 && ip3.integerValue <= 255 &&
                ip4.integerValue >= 0 && ip4.integerValue <= 255) {
                ret = YES;
            }
        }
        
        
    }
    
    return ret;
}

- (BOOL)isValidIPPort
{
    BOOL ret = NO;
    
    if ([self isNumber] && self.integerValue >= 0 && self.integerValue <= 65535) {
        ret = YES;
    }
    
    return ret;
    
}

- (BOOL)isValidMoneyWithRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [self stringByReplacingCharactersInRange:range withString:string];
    
    BOOL isMatch= YES;
    if (text.length > 0) {
        NSString * regex = @"(((^[0-9])|(^[1-9][0-9]{0,12}))(\\.[0-9]{0,2})?$)";
        
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        isMatch = [pred evaluateWithObject:text];
    }
    
    return isMatch;
}

- (BOOL)isValidMaxLength:(NSUInteger)maxLength WithRange:(NSRange)range replacementString:(NSString *)string
{
    if (maxLength > 0) {
        //这里默认是最多输入xx位
        NSString *aText = self;
        
        aText = [aText stringByReplacingCharactersInRange:range withString:string];
        if (aText.length > maxLength)
            
            return NO; // return NO to not change text
    }
    
    return YES;
}


@end
