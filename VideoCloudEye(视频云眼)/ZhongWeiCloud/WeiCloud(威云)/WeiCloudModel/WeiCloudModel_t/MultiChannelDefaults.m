//
//  MultiChannelDefaults.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/11/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//
#define MULTICHANNELMODEL @"MULTICHANNELMODEL"

#import "MultiChannelDefaults.h"
#import "MultiChannelModel.h"
@implementation MultiChannelDefaults

#pragma mark - 获取通道model
+ (MultiChannelModel *)getChannelModel
{
    MultiChannelModel *model = nil;
    NSString *jsonStr = [NSString stringWithFormat:@"%@",[MultiChannelDefaults getFromUserDefaults:MULTICHANNELMODEL]];
    if (![NSString isNull:jsonStr]) {
        model = [MultiChannelModel mj_objectWithKeyValues:jsonStr];
    }
    return model;
}

#pragma mark - 修改通道model
+ (void)setChannelModel:(MultiChannelModel *)model
{
    if (model) {
        [MultiChannelDefaults setToUserDefaults:MULTICHANNELMODEL Value:[model mj_JSONString]];
    }else{
        [MultiChannelDefaults setToUserDefaults:MULTICHANNELMODEL Value:@""];
    }
}

#pragma mark - 清空通道model
+ (void)clearChannelModel
{
    //清空NSUserDefaults中的用户信息
    NSUserDefaults *channelDefault = [NSUserDefaults standardUserDefaults];
    [channelDefault removeObjectForKey:MULTICHANNELMODEL];
    [channelDefault synchronize];
}


#pragma mark - 获取参数
+ (id)getFromUserDefaults:(NSString*)key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSObject *value=[userDefaults objectForKey:key];
    return value;
}

#pragma mark - 存储参数
+ (void)setToUserDefaults:(NSString*)key Value:(id)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

@end
