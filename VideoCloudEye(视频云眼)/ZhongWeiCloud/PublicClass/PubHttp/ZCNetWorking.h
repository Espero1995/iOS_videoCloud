//
//  ZCNetWorking.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/3/30.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface ZCNetWorking : AFHTTPSessionManager
+(instancetype) shareInstance;
@property (nonatomic,strong)NSURLSessionDataTask *task;
@end
