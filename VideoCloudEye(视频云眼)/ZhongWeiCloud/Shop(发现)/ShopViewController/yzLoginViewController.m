//
//  LoginViewController.m
//  YouzaniOSDemo
//
//  Created by 可乐 on 16/10/13.
//  Copyright © 2016年 Youzan. All rights reserved.
//

#import "yzLoginViewController.h"
#import <YZBaseSDK/YZBaseSDK.h>
#import "YZDUICService.h"
#import "yzLoginUserModel.h"
@interface yzLoginViewController ()
@property (nonatomic, strong) UIButton* loginBtn;/**< 登录按钮 */

@end

@implementation yzLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self yzlogin];
    
}

#pragma mark - Private Method
- (void)callBlockWithResult:(BOOL)success {
    if (self.loginBlock) {
        self.loginBlock(success);
    }
}

#pragma mark - Action

- (IBAction)close:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"不登录不能打开商品详情" delegate:self cancelButtonTitle:@"不登录" otherButtonTitles:@"登录",nil];
    [alertView show];
}

- (void)yzlogin {
    
    NSString * userID = [unitl get_User_id];
    NSString * yzlonginKey = [unitl getKeyWithSuffix:userID Key:youzanLoginModel];
    yzLoginUserModel * yzModel = [unitl getNeedArchiverDataWithKey:yzlonginKey];
    /**
     登录方法(在你使用时，应该换成自己服务器给的接口来获取access_token，cookie)
     */
    if (yzModel.access_token && yzModel.cookie_key && yzModel.cookie_value) {
        [YZDUICService loginWithOpenUid:[yzUserModel sharedManage].userId completionBlock:^(NSDictionary *resultInfo) {
            NSLog(@"resultinfo:%@",resultInfo);
            if (resultInfo) {
                [YZSDK.shared synchronizeAccessToken:yzModel.access_token
                                           cookieKey:yzModel.cookie_key
                                         cookieValue:yzModel.cookie_value];
                [self dismissViewControllerAnimated:YES completion:^{
                    [self callBlockWithResult:YES];
                }];
            }else{
                //需要自己修改界面
            }
        }];
    }else{
//        [self loginYouZan];todo
        [YZDUICService loginWithOpenUid:[yzUserModel sharedManage].userId completionBlock:^(NSDictionary *resultInfo) {
            if (resultInfo) {
                [YZSDK.shared synchronizeAccessToken:yzModel.access_token
                                           cookieKey:yzModel.cookie_key
                                         cookieValue:yzModel.cookie_value];
                [self dismissViewControllerAnimated:YES completion:^{
                    [self callBlockWithResult:YES];
                }];
            }
        }];
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (buttonIndex == 0) {
            [self callBlockWithResult:NO];
            return;
        }
        //
        [self yzlogin];
    }];
}
#pragma mark ==== 有赞登录
- (void)loginYouZan
{
    //有赞商城接入
    NSMutableDictionary * youzanDic = [NSMutableDictionary dictionary];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [youzanDic setValue:userModel.access_token forKey:@"access_token"];
        [youzanDic setValue:userModel.user_id forKey:@"user_id"];
    }
    [[HDNetworking sharedHDNetworking]POST:@"v1/youzan/open/login" parameters:youzanDic IsToken:NO success:^(id  _Nonnull responseObject) {
        NSLog(@"第一次失败 ，有赞商城接入【成功】：%@==%@",responseObject,responseObject[@"body"]);
        NSString *JSONString = responseObject[@"body"];
        yzLoginUserModel * yzModel = [[yzLoginUserModel alloc]init];
        // 将流转换为字典
        NSDictionary *dataDict = [unitl JSONStringToDictionary:JSONString];
        if(dataDict)
        {
            yzModel.access_token = dataDict[@"data"][@"access_token"];
            yzModel.cookie_key = dataDict[@"data"][@"cookie_key"];
            yzModel.cookie_value = dataDict[@"data"][@"cookie_value"];
            NSString * userID = [unitl get_User_id];
            NSString * yzlonginKey = [unitl getKeyWithSuffix:userID Key:youzanLoginModel];
            [unitl saveNeedArchiverDataWithKey:yzlonginKey Data:yzModel];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"第一次失败，有赞商城接入【失败】：");
    }];
}



@end

