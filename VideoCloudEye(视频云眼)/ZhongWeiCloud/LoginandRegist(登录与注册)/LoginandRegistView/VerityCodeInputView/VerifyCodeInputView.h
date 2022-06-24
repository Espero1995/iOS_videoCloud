//
//  VerifyCodeInputView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol getTextFieldContentDelegate <NSObject>
//返回结果内容
-(void)returnTextFieldContent:(NSString*)content;
@end

@interface VerifyCodeInputView : UIView

@property (assign,nonatomic,readwrite)id <getTextFieldContentDelegate>delegate;

/**背景图片*/
@property (nonatomic,copy)NSString *backgroudImageName;
/**验证码/密码的位数*/
@property (nonatomic,assign)NSInteger numberOfVerifyCode;
/**控制验证码/密码是否密文显示*/
@property (nonatomic,assign)bool secureTextEntry;
/**验证码/密码内容，可以通过该属性拿到验证码/密码输入框中验证码/密码的内容*/
@property (nonatomic,copy)NSString *verifyCode;

-(void)becomeFirstResponder;
-(void)resignFirstResponder;
@end
