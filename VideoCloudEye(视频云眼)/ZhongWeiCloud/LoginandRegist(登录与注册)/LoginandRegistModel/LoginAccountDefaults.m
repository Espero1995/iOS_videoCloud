//
//  LoginAccountDefaults.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/12/18.
//  Copyright © 2018 张策. All rights reserved.
//
#define LOGINACCOUNTMODEL @"LOGINACCOUNMODEL"
#import "LoginAccountDefaults.h"

@implementation LoginAccountDefaults
//获取urlmodel
+(LoginAccountModel *)getAccountModel
{
    LoginAccountModel *Model=nil;
    NSString *jsonStr=[NSString stringWithFormat:@"%@",[LoginAccountDefaults getFromAccountDefaults:LOGINACCOUNTMODEL]];
    if (![unitl isNull:jsonStr]) {
        Model = [LoginAccountModel mj_objectWithKeyValues:jsonStr];
    }
    return Model;
}


//修改urlmodel并保存到本地
+(void)setAccountModel:(LoginAccountModel *)Model
{
    if (Model) {
        [LoginAccountDefaults setToAccountDefaults:LOGINACCOUNTMODEL Value:[Model mj_JSONString]];
    }else{
        [LoginAccountDefaults setToAccountDefaults:LOGINACCOUNTMODEL Value:@""];
    }
}

///存储参数
+(void)setToAccountDefaults:(NSString*)key Value:(id)value
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

///获取参数
+(id)getFromAccountDefaults:(NSString*)key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSObject *value=[userDefaults objectForKey:key];
    return value;
}

///清除本地缓存信息
+(void)clearAccountModelInfo:(LoginAccountModel *)Model
{
    if (Model) {
        //清空NSUserDefaults中的用户信息
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:LOGINACCOUNTMODEL];
        [userDefaults synchronize];
    }else{
        NSLog(@"没有东西可以清理~");
    }
}
@end
