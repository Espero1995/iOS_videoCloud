//
//  UsetModel.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject<NSCoding>
//用户id
@property (nonatomic,copy)NSString *user_id;
//用户名
@property (nonatomic,copy)NSString *user_name;
//电话号码
@property (nonatomic,copy)NSString *mobile;
//电子邮箱
@property (nonatomic,copy)NSString *mail;
//头像
@property (nonatomic,copy)NSString *img;
//令牌
@property (nonatomic,copy)NSString *access_token;
//刷新令牌
@property (nonatomic,copy)NSString *refresh_token;
//令牌有效期
@property (nonatomic,assign)int expires_in;
//用户类型
@property (nonatomic,assign)int user_type;
/*
 *用户登录类型:1:手机号登录;2:邮箱登录
 */
@property (nonatomic,assign)int accountType;
@property (nonatomic, copy) NSString* refreshTime;/**< 刷新当前refresh_token的时间 */
@property (nonatomic, assign) BOOL isRefreshTimeSucceed;/**< 上次刷新refresh_token的时间是否成功 */
//微信账号id
@property (nonatomic,copy) NSString *wechat_id;

- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
@end
