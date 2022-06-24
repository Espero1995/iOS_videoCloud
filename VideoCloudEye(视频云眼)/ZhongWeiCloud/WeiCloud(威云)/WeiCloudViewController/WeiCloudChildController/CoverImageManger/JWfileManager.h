//
//  JWfileManager.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWfileManager : NSObject
HDSingletonH(JWfileManager)

/**
 根据给定的url或名称返回保存在本地的image

 @param imageUrl url
 @param directory directory
 @param nameStr 名称
 @return image
 */
- (UIImage*)getSmallImageWithUrl:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)nameStr;
@end
