//
//  MultiChannelModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/11/12.
//  Copyright © 2019 苏旋律. All rights reserved.
//
/**
 * description:
 */
#import <Foundation/Foundation.h>

@interface MultiChannelModel : NSObject
/**
 * @brief 设备id
 */
@property (nonatomic, copy) NSString *deviceId;
/**
 * @brief 通道id
 */
@property (nonatomic, assign) NSInteger chanId;
/**
 * @brief 通道名称
 */
@property (nonatomic, copy) NSString *chanName;
/**
 * @brief 通道编码
 */
@property (nonatomic, copy) NSString *chanCode;
/**
 * @brief 通道别名
 */
@property (nonatomic, copy) NSString *alias;
/**
 * @brief 地址
 */
@property (nonatomic, copy) NSString *address;
/**
 * @brief 景区地址
 */
@property (nonatomic, copy) NSString *scenic_area;
/**
 * @brief 景区Id
 */
@property (nonatomic, copy) NSString *scenic_area_id;
/**
 * @brief 监控点
 */
@property (nonatomic, copy) NSString *monitoring_point;
/**
 * @brief ”0-离线，1-在线”
 */
@property (nonatomic, assign) BOOL chanStatus;

@end

