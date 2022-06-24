//
//  MySingleton.h
//  app
//
//  Created by 张策 on 16/1/11.
//  Copyright © 2016年 ZC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySingleton : NSObject
+(instancetype) shareInstance;
/**
 *  用户名
 */
@property (nonatomic,copy)NSString *userNameStr;
@end
