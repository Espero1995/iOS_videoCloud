//
//  LiveListModel.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/1/24.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "LiveListModel.h"

@implementation LiveListModel
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"liveChans" : @"liveChans"
             };
}

@end
@implementation liveChans

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"ID": @"id"};
}

- (NSMutableDictionary *)play_info
{
    if (!_play_info) {
        _play_info = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _play_info;
}

@end
