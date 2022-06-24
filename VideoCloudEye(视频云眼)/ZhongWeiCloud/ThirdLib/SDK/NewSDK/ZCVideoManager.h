//
//  ZCVideoManager.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/11/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//JWStream相关
#import "jw_stream.h"
@class JWVideoAddressInfo;
@protocol ZCVideoManageDelegate <NSObject>
//软解
- (void)setUpImage:(UIImage *)newImage;
//硬解
- (void)setUpBuffer:(CVPixelBufferRef)buffer;
//停止录制回调
- (void)stopRecordBlockFunc;
@end

struct onESData{
    BOOL video;
    long pts;
    char * outData;
    int outStart;
    int outLen;
};

typedef void (^Callback)(BOOL video,long pts,char * outData,int outStart,int outLen);//struct onESData callBackESData   //BOOL video,long pts,Byte outData,int outStart,int outLen
typedef void (^CallackOnRemainingData)(char * outData,int outStart,int outLen,int readedStart);

typedef void (^ReturnUtcTimeStampBlock)(double showTime);

typedef void (^ReturnFlowInfoBlock)( int64_t flowBytes, int32_t byteRate);

@class VideoModel;
@interface ZCVideoManager : NSObject
{
    char tmpRemainBuf[8048000];
    int tmpRemainLen;
    int tmpReadStart;
    char NalBuf[409800];
    int NalBufUsed;
    bool bFirst;
    bool bFindPPS;
    
    long  nowTime;
    long  nowTime2;
    long firstPts;
    long firstDataUtimeStamp;
    long DataUtimeStamp;
}
@property (nonatomic,strong)UIImage *nImage;
@property (nonatomic,weak)id<ZCVideoManageDelegate>delegate;
//老版模型
@property (nonatomic,strong)VideoModel *videoModel;
////新版模型
//@property (nonatomic,strong)VideoAddressModel *videoAddressModel;

@property (nonatomic,strong)JWVideoAddressInfo *videoAddressModel;
@property (nonatomic,assign)BOOL isPlay;
@property (nonatomic,assign)BOOL isStop;
@property (nonatomic,assign)BOOL isAudioOpen;

//是否开始录制
@property (nonatomic,assign)BOOL isStartRecord;
//云台是否开启
@property (nonatomic,assign)BOOL isStep;

@property (nonatomic, copy) ReturnUtcTimeStampBlock returnTimeStampBlock;

@property (nonatomic, copy) ReturnFlowInfoBlock returnFlowInfoBlock;//回调流量和网速

- (void)dealloc;     
//威云开始
- (void)startCloudPlayBIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsPlayBack:(BOOL)bIsPlayBack DeviceId:(NSString *)deviceId bIsCenterPalyType:(BOOL)CenterType;
//威云停止
- (void)stopCloudPlay;

//JWStream
- (void)JWStreamStartBIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsPlayBack:(BOOL)bIsPlayBack DeviceId:(NSString *)deviceId bIsCenterPalyType:(BOOL)CenterType;
- (void)JWStreamStopCloudPlayRtpHandle:(JWSPHandle)handle;

//rtsp开始播放
- (void)startCloudPlayRtspWithUrl:(NSString *)url bIsEncrypt:(BOOL)encrypt Key:(NSString *)key;
//ap直连下，rtsp的播放
-(void)start_AP_backPlay_byRtspWithUrl:(NSString *)url;
//rtsp停止播放
- (void)stopCloudPlayRtsp;
//rtmp 播放【直播】
- (void)startCloudPlayRtmpWithUrl:(NSString *)url;
//rtmp 暂停 【直播】
- (void)stopCloudPlayRtmp;
//返回时间回调
- (void)returnTimeStamp:(ReturnUtcTimeStampBlock)block;
//返回流量和速度回调
- (void)returnFlowInfo:(ReturnFlowInfoBlock)block;
//清空缓存池里面的视频帧缓存
- (BOOL)emptyVideoData;


//暂停播放
- (void)suspendedPlayNo;
//继续播放
- (void)suspendedPlayYes;
//切换倍速播放功能
- (void)changePlayVideoFrequencyMultiple:(NSInteger)mutiple;



//视频录制
- (void)startRecordWithPath:(NSString *)path fileName:(NSString *)filename;
- (void)startRecordWithPath:(NSString *)path;
- (void)stopRecord;
//云台控制
- (void)beginControlType:(unsigned)type Parm1:(unsigned)parm1 Parm2:(unsigned)parm2;

//停止定时器
- (void)stopTimer;
@end
