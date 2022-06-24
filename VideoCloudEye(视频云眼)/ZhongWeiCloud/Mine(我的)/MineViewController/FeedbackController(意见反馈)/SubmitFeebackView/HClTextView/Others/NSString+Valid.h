//
//  NSString+Valid.h
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Valid)


///合法身份证
- (BOOL)isValidPersonIDCardNumber;

///银行卡校验规则(Luhn算法)
- (BOOL)isValidBankCardNumber;

/// 是否是是航班号  车次号
- (BOOL)isFlightOrTrainNumber;

///是否全部是数字
- (BOOL)isNumber;

/// 是否全部数字和字母组成
- (BOOL)isAlphanumeric;

///中文 字母等
- (BOOL)isChineseAlphabet;
///手机号码
- (BOOL)isValidMobileNumber;
///邮箱地址
- (BOOL)isValidEmailAddress;
///网页html
- (BOOL)isValidHtmlURL;
///合法密码
- (BOOL)isValidPassword;
///合法IP地址
- (BOOL)isValildIPAddress;
///合法IP端口
- (BOOL)isValidIPPort;

#pragma mark -textField
///合法金额输入...用于textField  delegate
- (BOOL)isValidMoneyWithRange:(NSRange)range replacementString:(NSString *)string;
///判断text 最大长度 maxLength = 0 return YES
- (BOOL)isValidMaxLength:(NSUInteger)maxLength WithRange:(NSRange)range replacementString:(NSString *)string;

@end
