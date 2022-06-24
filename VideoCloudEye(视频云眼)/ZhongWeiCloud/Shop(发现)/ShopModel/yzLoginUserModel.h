//
//  yzLoginUserModel.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/6/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface yzLoginUserModel : NSObject
@property (nonatomic, copy) NSString* access_token;/**< access_token */
@property (nonatomic, copy) NSString* cookie_key;/**< cookie_key */
@property (nonatomic, copy) NSString* cookie_value;/**< cookie_value */
@end
