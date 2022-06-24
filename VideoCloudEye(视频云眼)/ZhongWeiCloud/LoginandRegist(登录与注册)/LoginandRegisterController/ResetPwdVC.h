//
//  ResetPwdVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPwdVC : UIViewController
@property (nonatomic,copy) NSString *verifyCode;
@property (nonatomic,copy) NSString *phoneStr;//传过来的电话号码
@property (nonatomic,assign) BOOL isEmail;//是否是Email的验证码
@end
