//
//  ZWCameraInfo.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
/// 此类为通道信息对象
@interface JWCameraInfo : NSObject
/// 摄像头名称
@property (nonatomic, copy) NSString *cameraName;
/// 通道号
@property (nonatomic) NSInteger cameraNo;
/// 设备序列号
@property (nonatomic, copy) NSString *deviceSerial;
/// 分享状态：0、未分享，1、分享所有者，2、分享接受者（表示此摄像头是别人分享给我的）
@property (nonatomic) NSInteger isShared;
/// 通道封面
@property (nonatomic, copy) NSString *cameraCover;

@end
