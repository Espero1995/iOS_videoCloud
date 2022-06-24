//
//  GetAccountInfo.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2017/11/8.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "GetAccountInfo.h"

@implementation GetAccountInfo

SINGLETON_GENERATOR(GetAccountInfo,shareInstane);


#pragma mark - 获取账号的model

- (UserModel *)getAccountModel
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData * UserModelData = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel * userModel = [NSKeyedUnarchiver unarchiveObjectWithData:UserModelData];
        return userModel;
    }else{
        return nil;
    }
}
@end
