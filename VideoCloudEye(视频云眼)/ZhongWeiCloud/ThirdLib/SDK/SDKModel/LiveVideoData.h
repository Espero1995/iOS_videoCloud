//
//  LiveVideoData.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/1/25.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

//uint64_t utcTimeStamp;  // utc时间, 可能为0
//uint32_t timeStamp;    /* timestamp */
//uint8_t frameType;  // 帧类型
//uint8_t codecId;  // 编解码器id
//uint8_t avcPacketType;  // avc包类型，【codecId==>等于7时为H264,等于8时为H265】
//int32_t compositionTime;  // 成分时间偏移, 当avcPacketType == 1时才有效，否则都为0

//char *data;  // 视频数据
//size_t dataLen;  // 视频数据长度

@interface LiveVideoData : NSObject

@property (nonatomic,assign)unsigned long long utcTimeStamp;
@property (nonatomic,assign)unsigned int timeStamp;
@property (nonatomic,assign)int frameType;
@property (nonatomic,assign)int codecId;
@property (nonatomic,assign)int avcPacketType;
@property (nonatomic,assign)int compositionTime;

@property (nonatomic,assign)char* data;
@property (nonatomic,assign)int dataLen;
@end
