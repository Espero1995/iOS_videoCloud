//
//  ZWUserInfo.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
//用户信息
@interface JWUserInfo : NSObject
//用户id
@property (nonatomic,copy)NSString *user_id;
//用户名
@property (nonatomic,copy)NSString *user_name;
//电话号码
@property (nonatomic,copy)NSString *mobile;
//头像
@property (nonatomic,copy)NSString *img;
//令牌
@property (nonatomic,copy)NSString *access_token;
//刷新令牌
@property (nonatomic,copy)NSString *refresh_token;
//令牌有效期
@property (nonatomic,assign)int expires_in;
@end
