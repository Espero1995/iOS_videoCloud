//
//  ClearCacheManager.m
//  IntelligentLife
//
//  Created by Espero on 2017/9/24.
//  Copyright © 2017年 Espero. All rights reserved.
//

#import "ClearCacheManager.h"

@implementation ClearCacheManager

///缓存搜索的数组
+(void)SearchText:(NSString *)seaTxt{
    //存入本地中
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    //读取数组NSArray类型的数据
    NSArray *myArray=[userDefaults arrayForKey:@"searchLiveHistory"];
    if (myArray.count>0) {//先取出数组，判断是否有值，有值继续添加，无值创建数组
        
    }else{
        myArray=[NSArray array];
    }
    // NSArray --> NSMutableArray
    NSMutableArray *searTXT = [myArray mutableCopy];
    [searTXT addObject:seaTxt];
    if (searTXT.count>8) {
        [searTXT removeObjectAtIndex:0];
    }
    //将上述数据全部存储到NSUserDefaults中
    //        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searTXT forKey:@"searchLiveHistory"];
    [userDefaults synchronize];
}

///清除缓存数组
+(void)removeAllArray{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"searchLiveHistory"];
    [userDefaults synchronize];
}


@end
