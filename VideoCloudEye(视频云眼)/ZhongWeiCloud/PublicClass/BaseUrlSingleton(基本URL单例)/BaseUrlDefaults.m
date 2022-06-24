//
//  BaseUrlDefaults.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/8.
//  Copyright © 2018 张策. All rights reserved.
//
#define BASEURLMODEL @"baseurlmodel"
#import "BaseUrlDefaults.h"

@implementation BaseUrlDefaults
//获取urlmodel
+(BaseUrlModel *)geturlModel
{
    BaseUrlModel *urlModel=nil;
    NSString *jsonStr=[NSString stringWithFormat:@"%@",[BaseUrlDefaults getFromBaseUrlDefaults:BASEURLMODEL]];
    if (![unitl isNull:jsonStr]) {
        urlModel = [BaseUrlModel mj_objectWithKeyValues:jsonStr];
    }
    return urlModel;
}


//修改urlmodel并保存到本地
+(void)setUrlModel:(BaseUrlModel *)urlModel
{
    if (urlModel) {
        [BaseUrlDefaults setToBaseUrlDefaults:BASEURLMODEL Value:[urlModel mj_JSONString]];
    }else{
        [BaseUrlDefaults setToBaseUrlDefaults:BASEURLMODEL Value:@""];
    }
}

///存储参数
+(void)setToBaseUrlDefaults:(NSString*)key Value:(id)value
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

///获取参数
+(id)getFromBaseUrlDefaults:(NSString*)key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSObject *value=[userDefaults objectForKey:key];
    return value;
}

///清除本地缓存信息
+(void)clearUrlModelInfo:(BaseUrlModel *)urlModel
{
    if (urlModel) {
        //清空NSUserDefaults中的用户信息
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:BASEURLMODEL];
        [userDefaults synchronize];
    }else{
        NSLog(@"没有东西可以清理~");
    }
}

@end
