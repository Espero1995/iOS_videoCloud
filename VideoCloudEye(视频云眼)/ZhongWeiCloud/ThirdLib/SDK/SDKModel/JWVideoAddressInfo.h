//
//  JWVideoAddressInfo.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/17.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
//JWStream相关
#import "jw_stream.h"

@class mrts;
/// 此类视频地址相关对象
@interface JWVideoAddressInfo : NSObject
///playId
@property (nonatomic,copy)NSString *monitor_id;
///mrts包含音\视频 端口\地址
@property (nonatomic,strong)mrts *mrts;
//每一路视频对于的一个handle
@property (nonatomic) JWSPHandle handle;
@end
@interface mrts : NSObject
//视频地址
@property (nonatomic,copy)NSString * v_ip;
//视频端口
@property (nonatomic,assign)int v_port;
//音频地址
@property (nonatomic,copy)NSString *a_ip;
//音频端口
@property (nonatomic,assign)int a_port;

@end
