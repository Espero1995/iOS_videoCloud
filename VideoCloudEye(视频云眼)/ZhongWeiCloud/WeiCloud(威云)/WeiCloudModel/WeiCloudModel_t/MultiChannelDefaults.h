//
//  MultiChannelDefaults.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/11/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MultiChannelModel;

@interface MultiChannelDefaults : NSObject

/**
 * @brief 获取通道model
 * @return 返回该通道model
 */
+ (MultiChannelModel *)getChannelModel;

/**
 * @brief 修改通道model
 * @param model 该通道model
 */
+ (void)setChannelModel:(MultiChannelModel *)model;

/**
 * @brief 清空通道model
 */
+ (void)clearChannelModel;


@end

