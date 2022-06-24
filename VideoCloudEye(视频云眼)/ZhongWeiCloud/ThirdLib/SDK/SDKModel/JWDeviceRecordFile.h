//
//  ZWDeviceRecordFile.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
/// 此类为设备录像文件信息（包含SD卡、后端关联设备的录像）
@interface JWDeviceRecordFile : NSObject
/// 设备录像文件的开始时间 //因为是时间戳
@property (nonatomic, assign) int start_time;
/// 设备录像文件的结束时间
@property (nonatomic, assign) int stop_time;
@property (nonatomic, copy) NSString* name;/**< 当前段录像文件名称 */

@end
