//
//  ChannelCodeListModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2020/8/14.
//  Copyright © 2020 苏旋律. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//适用于只有通道列表的Model
@interface ChannelCodeListModel : NSObject

/**
 * @brief 通道编码
 */
@property (nonatomic, copy) NSString *chanCode;
/**
 * @brief 设备Id
 */
@property (nonatomic, copy) NSString *deviceId;
/**
 * @brief 通道ID
 */
@property (nonatomic, copy) NSString *chanId;
/**
 * @brief 通道名
 */
@property (nonatomic, copy) NSString *chanName;
/**
 * @brief ”0-离线，1-在线”
 */
@property (nonatomic, assign) BOOL chanStatus;
/**
 * @brief 通道别名
 */
@property (nonatomic, copy) NSString *chanAlias;
/**
 * @brief 地址
 */
@property (nonatomic, copy) NSString *address;
/**
 * @brief 经度
 */
@property (nonatomic, copy) NSString *longitude;
/**
 * @brief 纬度
 */
@property (nonatomic, copy) NSString *latitude;
/**
 * @brief 设备名
 */
@property (nonatomic, copy) NSString *devName;
/**
 * @brief 设备类型
 */
@property (nonatomic, copy) NSString *devType;
/**
 * @brief 用户Id
 */
@property (nonatomic, copy) NSString *ownerId;
/**
 * @brief 用户名
 */
@property (nonatomic, copy) NSString *ownerName;
/**
 * @brief ”0-不加密，1-加密”
 */
@property (nonatomic, assign) BOOL enableSecLib;
/**
 * @brief 加密码
 */
@property (nonatomic, copy) NSString *dev_p_code;
/**
 * @brief 节点Id
 */
@property (nonatomic, copy) NSString *nodeId;
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


@end

NS_ASSUME_NONNULL_END
