//
//  GetAccountInfo.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2017/11/8.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
@interface GetAccountInfo : NSObject

+ (GetAccountInfo *)shareInstane;

- (UserModel*)getAccountModel;

@end
