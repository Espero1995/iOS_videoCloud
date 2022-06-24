//
//  LoginAccountDefaults.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/12/18.
//  Copyright © 2018 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LoginAccountDefaults : NSObject
///获取urlmodel
+(LoginAccountModel *)getAccountModel;
///修改urlmodel并保存到本地
+(void)setAccountModel:(LoginAccountModel *)Model;
///清除本地缓存信息
+(void)clearAccountModelInfo:(LoginAccountModel *)Model;
@end

