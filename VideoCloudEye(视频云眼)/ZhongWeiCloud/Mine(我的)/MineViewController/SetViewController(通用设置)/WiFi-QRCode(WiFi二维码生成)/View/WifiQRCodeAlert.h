//
//  confirmView.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/4/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WifiQRCodeAlert;
@protocol WifiQRCodeAlertDelegate <NSObject>

- (IBAction)joinBtnClick:(id)sender psdStr:(NSString *)psdStr;

- (void)cancelClick;

@end

@interface WifiQRCodeAlert : UIView
//WiFi名称
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
//取消按钮
@property (weak, nonatomic) IBOutlet UIButton *cannelBtn;
//加入网络按钮
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;
//密码框
@property (weak, nonatomic) IBOutlet UITextField *psdTextField;
//密码框外面的View
@property (strong, nonatomic) IBOutlet UIView *wifiPsdView;
//显示密码按钮
@property (strong, nonatomic) IBOutlet UIButton *showPasBtn;

@property (nonatomic,weak)id<WifiQRCodeAlertDelegate>delegate;
+(instancetype)viewFromXib;
@end
