//
//  chansModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/12/30.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface chansModel : NSObject
/**
 * @brief id
 */
@property (nonatomic, copy) NSString *ID;
/**
 * @brief 通道别名
 */
@property (nonatomic, copy) NSString *alias;
/**
 * @brief 通道id
 */
@property (nonatomic, assign) NSInteger chan_id;
/**
 * @brief 监控点
 */
@property (nonatomic, copy) NSString *monitoring_point;
/**
 * @brief 通道名称
 */
@property (nonatomic, copy) NSString *name;
/**
 * @brief 景区地址
 */
@property (nonatomic, copy) NSString *scenic_area;
/**
 * @brief 景区Id
 */
@property (nonatomic, copy) NSString *scenic_area_id;
/**
 * @brief ”0-离线，1-在线”
 */
@property (nonatomic, assign) BOOL status;
@end
