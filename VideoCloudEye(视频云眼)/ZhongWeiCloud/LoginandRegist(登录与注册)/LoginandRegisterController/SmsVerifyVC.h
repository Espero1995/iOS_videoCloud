//
//  SmsVerityVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmsVerifyVC : UIViewController
@property (nonatomic,copy) NSString *phoneStr;//传过来的电话号码
@property (nonatomic,copy) NSString *pwdStr;//传过来的密码
/**
 description：判断从哪里进入的短信验证（1:注册方式进入；2:忘记密码进入；3:二次验证进入）
 */
@property (nonatomic,assign) NSInteger verifyCodeStatus;
@property (nonatomic,assign) BOOL isEmail;//是否是Email的验证码
@end
