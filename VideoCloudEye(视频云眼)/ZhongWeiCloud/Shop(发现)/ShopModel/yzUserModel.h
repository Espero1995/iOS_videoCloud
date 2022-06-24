//
//  UserModel.h
//  YouzaniOSDemo
//
//  Created by 可乐 on 16/10/13.
//  Copyright © 2016年 Youzan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface yzUserModel : NSObject

@property (copy, nonatomic) NSString *userId;

+ (instancetype)sharedManage;

/**
 切换userID
 */
+ (void)changeUserId;


@end

