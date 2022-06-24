//
//  ZWAccessToken.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
/// 此类为开放平台授权登录以后的凭证信息
@interface JWAccessToken : NSObject
/// accessToken 登录凭证
@property (nonatomic, copy) NSString *accessToken;
/// accessToken距离过期的秒数，用当前时间加上expire的秒数为过期时间
@property (nonatomic, assign) NSInteger expire;

#warning 记得删除
@property (nonatomic,copy)NSString *userid;
@end
