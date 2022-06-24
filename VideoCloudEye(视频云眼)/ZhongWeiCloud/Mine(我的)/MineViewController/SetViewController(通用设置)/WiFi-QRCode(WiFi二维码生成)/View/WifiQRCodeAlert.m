//
//  confirmView.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/4/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WifiQRCodeAlert.h"
#import "UIView+ScottAlertView.h"
@interface WifiQRCodeAlert ()
{
    //判断密码是明文还是密文
    BOOL isOpenPsd;
}
@end

@implementation WifiQRCodeAlert

+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    isOpenPsd = NO;
    [self setUpUI];
}
#pragma mark 按钮样式
- (void)setUpUI
{
    self.cannelBtn.layer.cornerRadius = 5.f;
    self.joinBtn.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.f;
    self.frame = CGRectMake(0, 0, 0.85*iPhoneWidth, 150);
    self.wifiPsdView.layer.masksToBounds = YES;
    self.wifiPsdView.layer.cornerRadius = 5.f;
    self.wifiPsdView.layer.borderWidth = 1.f;
    self.wifiPsdView.layer.borderColor = RGB(210, 210, 210).CGColor;
}


- (IBAction)cannelBtnClick:(id)sender
{
    [self.psdTextField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelClick)]) {
        [self.delegate cancelClick];
    }
    [self dismiss];
}

- (IBAction)joinBtnClick:(id)sender psdStr:(NSString *)psdStr
{
    [self.psdTextField resignFirstResponder];
    psdStr = self.psdTextField.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(joinBtnClick:psdStr:)]) {
        [self.delegate joinBtnClick:sender psdStr:psdStr];
    }
       [self dismiss];
}

- (IBAction)isOpenPsdClick:(id)sender
{
    //现在是睁眼状态
    if (isOpenPsd) {
        [self.showPasBtn setImage:[UIImage imageNamed:@"closePwdeye"] forState:UIControlStateNormal];
        // 按下去了就是密文
        NSString *tempPwdStr = self.psdTextField.text;
        self.psdTextField.text = @"";
        self.psdTextField.secureTextEntry = YES;
        self.psdTextField.text = tempPwdStr;
        isOpenPsd=NO;
    }else{//现在是闭眼状态
        [self.showPasBtn setImage:[UIImage imageNamed:@"showPwdeye"] forState:UIControlStateNormal];
        // 明文
        NSString *tempPwdStr = self.psdTextField.text;
        self.psdTextField.text = @""; // 可以防止切换的时候光标偏移
        self.psdTextField.secureTextEntry = NO;
        self.psdTextField.text = tempPwdStr;
        isOpenPsd=YES;
    }
}


@end
