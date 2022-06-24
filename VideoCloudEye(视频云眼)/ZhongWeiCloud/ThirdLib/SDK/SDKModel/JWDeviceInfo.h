//
//  ZWDeviceInfo.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWConstants.h"
/// 此类为设备信息对象
@interface JWDeviceInfo : NSObject
/// 设备关联的通道信息
@property (nonatomic, strong) NSArray *cameraInfo;
/// 设备关联的通道数量
@property (nonatomic) NSInteger cameraNum;
/// 设备布防状态，A1设备布撤防状态，0:睡眠 8:在家 16:外出；非A1设备，0-撤防 1-布防
@property (nonatomic) NSInteger defence;
///// 设备关联的探测器数量
//@property (nonatomic) NSInteger detectorNum;
///// 设备关联的探测器信息
//@property (nonatomic, strong) NSArray *detectorInfo;
/// 设备图片
@property (nonatomic, copy) NSString *deviceCover;
/// 设备名称
@property (nonatomic, copy) NSString *deviceName;
/// 设备序列号
@property (nonatomic, copy) NSString *deviceSerial;
/// 设备类型
@property (nonatomic, copy) NSString *deviceType;
/// 设备版本号
@property (nonatomic, copy) NSString *deviceVersion;
/// 设备是否开启加密
@property (nonatomic) BOOL isEncrypt;
///// 设备状态，1-在线，2-不在线
//@property (nonatomic) NSInteger status;
/// 是否支持对讲 0-不支持对讲，1-支持全双工对讲，3-支持半双工对讲
@property (nonatomic) NSInteger isSupportTalk;
/// 是否支持云台控制
@property (nonatomic) BOOL isSupportPTZ;
/// 是否支持放大
@property (nonatomic) BOOL isSupportZoom;
/// 是否支持镜像翻转
@property (nonatomic) BOOL isSupportMirrorCenter;

///设备当前版本号
@property (nonatomic,copy)NSString *cur_version;
///设备最新版本号
@property (nonatomic,copy)NSString *latest_version;
///升级状态
@property (nonatomic,assign)JWDeviceUpdateStatus status;
///升级进度
@property (nonatomic,assign)int upDataProgress;



@end
