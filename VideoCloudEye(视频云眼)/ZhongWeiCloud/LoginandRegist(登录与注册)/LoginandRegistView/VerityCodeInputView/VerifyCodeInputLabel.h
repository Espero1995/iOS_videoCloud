//
//  VerifyCodeInputLabel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyCodeInputLabel : UILabel
/**验证码/密码的位数*/
@property (nonatomic,assign)NSInteger numberOfVerifyCode;
/**控制验证码/密码是否密文显示*/
@property (nonatomic,assign)BOOL secureTextEntry;

@end
