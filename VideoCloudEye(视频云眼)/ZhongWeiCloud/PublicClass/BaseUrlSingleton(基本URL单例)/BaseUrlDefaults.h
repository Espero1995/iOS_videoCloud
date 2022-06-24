//
//  BaseUrlDefaults.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/8.
//  Copyright © 2018 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseUrlDefaults : NSObject
///获取urlmodel
+(BaseUrlModel *)geturlModel;
///修改urlmodel并保存到本地
+(void)setUrlModel:(BaseUrlModel *)urlModel;
///清除本地缓存信息
+(void)clearUrlModelInfo:(BaseUrlModel *)urlModel;
@end

