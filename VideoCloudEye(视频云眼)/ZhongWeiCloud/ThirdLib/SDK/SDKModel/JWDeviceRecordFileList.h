//
//  JWDeviceRecordFileList.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/18.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWDeviceRecordFile.h"
/// 此类为设备录像文件信息（包含SD卡、后端关联设备的录像）列表 数组中包含JWDeviceRecordFile对象
@interface JWDeviceRecordFileList : NSObject
@property (nonatomic,copy)NSArray *his_recs;

@end
