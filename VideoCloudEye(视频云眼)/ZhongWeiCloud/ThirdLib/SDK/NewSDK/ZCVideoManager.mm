//
//  ZCVideoManager.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/11/7.
//  Copyright © 2016年 张策. All rights reserved.
//
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ZCVideoManager.h"

#import "ZCVideoTimeModel.h"
#import "VmNet.h"
#import "VideoModel.h"
#import "CCbVideoData.h"
#import "MSWeakTimer.h"
#import "NewTwoOpenAl.h"
#import "H264HwDecoderImpl.h"//H264解码器(内含265解码)
#import "TBMALaw2PCMConverter.h"
#import "JWVideoAddressInfo.h"
#import "HeadClass.h"
//#import "Sadp.h"

//域名转IP
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>

//直播
#import "jw_type.h"
#import "jw_rtmp.h"
#import "LiveVideoData.h"


#import "WCLRecordEncoder.h"
static NSString *lockStr = @"lock";

#define HEARTBEAT_SERVER_ADDRESS         @"yun.joyware.com"//@"yun.joyware.com"
#define HEARTBEAT_TEST_SERVER_ADDRESS    @"y.yun.joyware.com"
#define HEARTBEAT_SERVER_ADDRESS_IP      @"118.178.239.58"
static short HEARTBEAT_SERVER_PORT = 10989;

static NSString * const decodeQueueLock  = @"decodeQueueLock";
static NSString * const JWStreamDecodeDealDataLock  = @"JWStreamDecodeDealDataLock";

@interface ZCVideoManager ()<H264HwDecoderImplDelegate>
@property (nonatomic,strong)NSOperationQueue *AudioQueue;
@property (nonatomic,strong)NSOperationQueue *VideoQueue;
@property (nonatomic,strong)NSOperationQueue *DecodeBoxQueue;

@property (nonatomic,strong)NSOperationQueue *AudioRecQueue;
@property (nonatomic,strong)NSOperationQueue *VideoRecQueue;

//数据数组
@property (nonatomic,strong)NSMutableArray *videoDataArr;
//录音的数组
@property (nonatomic,strong)NSMutableArray *audioRecDataArr;
//码流id
@property (nonatomic,assign)unsigned int streamId;
/**
 * 音频码流id
 */
@property (nonatomic, assign) unsigned int  audioStreamId;

//rtsp码流id
@property (nonatomic,assign)long rtspStreamId;
//h264解码
@property (nonatomic,strong)H264HwDecoderImpl *h264Decoder;
//截图字典
@property (nonatomic,strong)NSMutableDictionary *dataDic;
//保存视频
@property (strong, nonatomic) WCLRecordEncoder *recordEncoder;//录制编码
//录制视频的时间戳
@property (nonatomic,assign)int videoFps;
@property (nonatomic,assign)int audioFps;
//视频宽高
@property (nonatomic,assign)int videoWidth;
@property (nonatomic,assign)int videoHeight;
//录像写入线程
@property (nonatomic,strong)dispatch_queue_t myVideoQueue;
//截图线程
@property (nonatomic,strong)dispatch_queue_t toolBoxQueue;
//心跳包线程
@property (nonatomic,strong)dispatch_queue_t heartBeatQueue;
//查询回有录像的时间段数组
@property (nonatomic,strong)NSMutableArray *videoTimeModelArr;
@property (nonatomic, strong) NSMutableArray* timeStampArr;/**< 回调应用层的视频时间戳数组 */
@property (nonatomic, strong) dispatch_queue_t returnTimeStampQueue;/**< 回调应用层的视频时间戳线程 */
//子线程
@property (nonatomic,strong)NSThread *custThread;
//主线程添加定时器 超时停止监控 连接成功开启新线程
@property (nonatomic,strong)MSWeakTimer *checkTimer;
//监控超时连接的定时器
@property (nonatomic,strong)MSWeakTimer *lineTimeer;
//openal
@property (nonatomic,strong)NewTwoOpenAl *openAl;
//码流回调的时间
@property (nonatomic,assign)int lineTimeInt;
//是否ps流
@property (nonatomic,assign)BOOL isPsStream;
//是否录制声音
@property (nonatomic,assign)BOOL isRecordAudio;

@property (nonatomic,assign)int trans;
@property (nonatomic,assign)int mTrans;

@property (nonatomic,assign)BOOL isSubStream;
@property (nonatomic,copy)NSString *fdidStr;
@property (nonatomic,assign)int chanleInt;

@property (nonatomic,assign)BOOL haveData;//是否找到数据起始

@property (nonatomic,assign)long pts;

@property (nonatomic,assign)BOOL bIsEncrypt;

@property (nonatomic,assign)BOOL bIsPlayBack;

@property (nonatomic, copy)NSString * key;

@property (nonatomic, assign)JW_CIPHER_CTX cipher;

@property (nonatomic,strong)NSTimer *heartBeatTimer;

@property (nonatomic,assign)BOOL bIsDataQueueSizeFull;//缓存队列满了

@property (nonatomic,assign)BOOL bIsResetNowTime;

@property (nonatomic,assign)BOOL bIsRtsP;//是rtsp流

@property (nonatomic,assign)unsigned long long utcTime1;
@property (nonatomic,assign)int oneTimeValue;
@property (nonatomic,assign)unsigned long timeStamp;
@property (nonatomic, assign) BOOL is_I_frameAppear;/**< 用来计算I帧的utc时间 */

@property (nonatomic,assign)char* SockBuf;

@property (nonatomic) JWRTMPReaderHandle RTMPhandle;//RTMPhandel

@property (nonatomic) JWSPHandle SPhandle;//取流handel

@property (nonatomic, strong) CADisplayLink* decodeDisplayLink;/**< 解码定时器 */


@end


@implementation ZCVideoManager
{
    int _nCheckCnt;
    unsigned int uMonitorid;
    //ps流视频
    BOOL isVideo;
    // 找到数据起始
    BOOL findDataStart;
}
#pragma mark - JWRTMP RTMPHandle
- (JWRTMPReaderHandle )RTMPhandle
{
    _RTMPhandle = JWRTMPReader_Create();
    NSLog(@"创建的RTMPhandle：%d",_SPhandle);
    return _RTMPhandle;
}

#pragma mark - JWStream JWSPHandle
- (JWSPHandle)SPhandle
{
    _SPhandle = JWStream_Create();
    NSLog(@"创建的JWSPHandle：%d",_SPhandle);
    return _SPhandle;
}


//H264硬解码
- (H264HwDecoderImpl *)h264Decoder
{
    if (!_h264Decoder) {
        _h264Decoder = [[H264HwDecoderImpl alloc] init];
        _h264Decoder.delegate = self;
    }
    return _h264Decoder;
}



//音频播放器
//- (NewTwoOpenAl *)openAl
//{
//    if (_openAl== nil) {
//        _openAl = [NewTwoOpenAl sharePalyer];
//    }
//    return _openAl;
//}
//截图字典
- (NSMutableDictionary *)dataDic
{
    if (!_dataDic) {
        _dataDic = [NSMutableDictionary dictionary];
    }
    return _dataDic;
}
//录像线程
- (dispatch_queue_t)myVideoQueue
{
    if (!_myVideoQueue) {
        _myVideoQueue = dispatch_queue_create("videorecord", NULL);
    }
    return _myVideoQueue;
}
//截图线程
- (dispatch_queue_t)toolBoxQueue
{
    if (!_toolBoxQueue) {
        _toolBoxQueue = dispatch_queue_create("photoScreenshot", NULL);
    }
    return _toolBoxQueue;
}
//心跳包线程
- (dispatch_queue_t)heartBeatQueue
{
    if (!_heartBeatQueue) {
        _heartBeatQueue = dispatch_queue_create("heartBeat", NULL);
    }
    return _heartBeatQueue;
}
//回调应用层视频时间戳线程
- (dispatch_queue_t)returnTimeStampQueue
{
    if (!_returnTimeStampQueue) {
        _returnTimeStampQueue = dispatch_queue_create("returnTimeStamp", NULL);
    }
    return _returnTimeStampQueue;
}
////视频数据数组
- (NSMutableArray *)videoDataArr
{
    if (!_videoDataArr) {
        _videoDataArr = [NSMutableArray array];
    }
    return _videoDataArr;
}

- (NSMutableArray *)timeStampArr
{
    if (!_timeStampArr) {
        _timeStampArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _timeStampArr;
}

- (NSMutableArray *)videoTimeModelArr
{
    if (!_videoTimeModelArr) {
        _videoTimeModelArr = [NSMutableArray array];
    }
    return _videoTimeModelArr;
}

- (void)setVideoModel:(VideoModel *)videoModel
{
    _videoModel = videoModel;
    self.fdidStr = videoModel.sFdId;
    self.chanleInt = videoModel.nChannelId;
}

- (void)setIsAudioOpen:(BOOL)isAudioOpen
{
    _isAudioOpen = isAudioOpen;
    [_openAl stopSound];
}

- (void)setIsStop:(BOOL)isStop
{
    _isStop = isStop;
    NSNumber *isStopNum = [NSNumber numberWithBool:isStop];
    [[NSNotificationCenter defaultCenter]postNotificationName:VIDEOISSTOP object:isStopNum];
}

#pragma mark ------ stream码流连接状态回调
// uStreamId：码流id； bIsConnected：true 已连接 false 断开； pUser：用户参数
void streamConnectStatusCallBack(unsigned uStreamId,
                                 bool bIsConnected, void* pUser)
{
    ZCVideoManager *userSelf = (__bridge ZCVideoManager *)pUser;
    NSLog(@"Video==streamConnectStatusCallBack===self.streamId:%u",uStreamId);
}
#pragma mark ------码流回调函数
// uStreamId：码流id； uStreamType：数据类型； payloadType：码流承载类型；pBuffer：数据指针；
// nLen：数据长度； uTimeStamp：时间戳； pUser：用户参数；sequenceNumber：序列号；isMark：是否是结束
//视频回调
void StreamCallBack(unsigned uStreamId,
                    unsigned uStreamType, char payloadType, char* pBuffer, int nLen,
                    unsigned uTimeStamp, unsigned short sequenceNumber, bool isMark, void* pUser)
{
    ZCVideoManager *userSelf = (__bridge ZCVideoManager *)pUser;
   // NSLog(@"bIsEncrypt：%@",userSelf.bIsEncrypt?@"YES":@"NO");
    userSelf.bIsDataQueueSizeFull = NO;
//    NSLog(@"码流回调函数==payloadType:%d",payloadType);
    if ( payloadType == 113 ||payloadType == 96) {//payloadType == 96||【注：因为现在中心录像修改过后，来的payloadType也是96，但是其为es流，试了之前的也为96的ps流，不通过那样去头处理，也是正常播放。所以暂时先改成这样。睿哥过滤问下之后在修改。】
        userSelf.isPsStream = YES;
    }else{
        userSelf.isPsStream = NO;
    }
  //数据长度
    if(nLen > 204800) {
        NSLog(@"data too long, len=%d", nLen);
        return;
    }
    NSDate *senddate = [NSDate date];
    int lineTimeInt =  [senddate timeIntervalSince1970];
    //码流回调时的时间
    userSelf.lineTimeInt = lineTimeInt;
    userSelf.bIsRtsP = NO;
    //数据个数
    @synchronized(userSelf) {
        NSInteger nQueueSize = userSelf.videoDataArr.count;
        
        if(nQueueSize > 500)
        {
            userSelf.bIsDataQueueSizeFull = YES;
            NSLog(@"data buffer queue is full, size=%ld", (long)nQueueSize);
            [userSelf.videoDataArr removeAllObjects];
             return;
        }else
        {
            userSelf.bIsDataQueueSizeFull = NO;
        }
        //视频数据
        CCbVideoData* videoData = [[CCbVideoData alloc]init];
        videoData.nType = uStreamType;
        videoData.pData = (char*)malloc(nLen);
        memcpy(videoData.pData, pBuffer, nLen);
        videoData.nLen = nLen;
        videoData.uTimeStamp = uTimeStamp;
        [userSelf.videoDataArr addObject:videoData];
        if (userSelf.isPsStream == NO) {
            if (userSelf.isAudioOpen) {
                [userSelf.openAl openAudioFromQueue:(uint8_t *)pBuffer dataSize:nLen samplerate:8000 channels:1 bit:16];
            }
        }
    }
}

#pragma mark - 拓展协议后的码流回调函数
void StreamCallBackExt(unsigned uStreamId, unsigned uStreamType, char payloadType,
                       char *pBuffer, int nLen, unsigned uTimeStamp,
                       unsigned short sequenceNumber, bool isMark, bool isJWHeader,
                       bool isFirstFrame, bool isLastFrame, unsigned long long utcTimeStamp, void *pUser)
{
    /**
     bool isJWHeader,
     bool isFirstFrame, bool isLastFrame, unsigned long long utcTimeStamp,
     */
   // NSLog(@"data buffer queue is full【ext】");
    ZCVideoManager *userSelf = (__bridge ZCVideoManager *)pUser;
    userSelf.bIsDataQueueSizeFull = NO;
   
    if ( payloadType == 113 ||  payloadType == 96) {
        userSelf.isPsStream = YES;
    }else{
        userSelf.isPsStream = NO;
    }
    // NSLog(@"所在线程：%@====码流回调函数==payloadType:%d, len=[%d]",[NSThread currentThread],payloadType,nLen);
    //return;
    //数据长度
    if(nLen > 204800) {
        NSLog(@"data too long, len=%d", nLen);
        return;
    }
    
    NSDate *senddate = [NSDate date];
    int lineTimeInt =  [senddate timeIntervalSince1970];
    //码流回调时的时间
    userSelf.lineTimeInt = lineTimeInt;
    userSelf.bIsRtsP = NO;
    
    //数据个数
    @synchronized(decodeQueueLock) {
        NSInteger nQueueSize = userSelf.videoDataArr.count;
        if(nQueueSize > 500)
        {
            userSelf.bIsDataQueueSizeFull = YES;
            NSLog(@"data buffer queue is full【ext】, size=%ld", (long)nQueueSize);
            [userSelf.videoDataArr removeAllObjects];
            return;
        }else
        {
            userSelf.bIsDataQueueSizeFull = NO;
        }
       // NSLog(@"所在线程：%@==uStreamId:%u===length:%u",[NSThread currentThread],uStreamId,nLen);
        //视频数据
        CCbVideoData* videoData = [[CCbVideoData alloc]init];
        videoData.nType = uStreamType;
        videoData.pData = (char*)malloc(nLen);
        memcpy(videoData.pData, pBuffer, nLen);//这里偶尔会有崩溃现象。
        //memcpy(videoData->pData_ext, pBuffer, nLen);
        videoData.nLen = nLen;
        videoData.uTimeStamp = uTimeStamp;
        videoData.utcTimeStamp = utcTimeStamp;
        if (userSelf.returnTimeStampBlock != nil) {
            userSelf.returnTimeStampBlock(videoData.utcTimeStamp);
        }
        if (videoData.utcTimeStamp != 0) {
//            NSLog(@"videoData.utcTimeStamp:%llu",videoData.utcTimeStamp);
                NSDictionary * dic = @{@"TimeStamp":[NSNumber numberWithDouble:videoData.utcTimeStamp]};
                [[NSNotificationCenter defaultCenter]postNotificationName:RETURNTIMESTAMP object:nil userInfo:dic];
        }
        
        if (userSelf.isPsStream == NO) {
           // NSLog(@"打印 isPsStream == NO");
            if (userSelf.isAudioOpen) {
                if (userSelf.audioStreamId == uStreamId) {
                    NSLog(@"userSelf.audioStreamId:%u",userSelf.audioStreamId);
                    NSData *bufData = [NSData dataWithBytes:pBuffer length:nLen];
                    NSData *audioData = [TBMALaw2PCMConverter decodeWithData:bufData];
                    [userSelf.openAl openAudioFromQueue:(uint8_t *)audioData.bytes dataSize:nLen*2 samplerate:8000 channels:1 bit:16];
                }
            }
             if (userSelf.audioStreamId != uStreamId) {
                 [userSelf.videoDataArr addObject:videoData];
             }
        }else{//ps流，直接全部数据加入
           // NSLog(@"所在线程：%@===打印 isPsStream == YES",[NSThread currentThread]);
                [userSelf.videoDataArr addObject:videoData];
        }
    }
}

- (void)returnTimeStamp:(ReturnUtcTimeStampBlock)block{
    self.returnTimeStampBlock = block;
}

#pragma mark ------rtsp码流数据回调
char* zcPayloadData;
void rtspStreamCallBackV2(const char* pStreamData, unsigned uStreamLen, void *pUser)
{
     
    if (pUser == NULL) {
        NSLog(@"rtsp码流数据回调 pUser 为NULL");
    }
    ZCVideoManager *userSelf = (__bridge ZCVideoManager *)pUser;
    if (!zcPayloadData) {
        zcPayloadData = new char[10000];
    }
    int payloadLen = 10000;
    int payloadType = 0;
    
    int seqNumber;
    int timestamp;
    bool isMark;
    bool boolVmPlayer_FilterRtpHeader = VmNet_FilterRtpHeader((char*)pStreamData, uStreamLen, zcPayloadData, payloadLen, payloadType,seqNumber,timestamp,isMark);
//    NSLog(@"rtsp码流回调类型========%d",payloadLen);
    
    if (boolVmPlayer_FilterRtpHeader) {
        if (payloadType == 96 || payloadType == 98) {
            payloadType = 98;
            userSelf.isPsStream = NO;
            
            //        else{
            //            userSelf.isPsStream = YES;
            //        }
            //数据长度
            if(payloadLen > 204800) {
                NSLog(@"data too long, len=%d", payloadLen);
                return;
            }
            
            NSDate *senddate = [NSDate date];
            int lineTimeInt =  [senddate timeIntervalSince1970];
            //码流回调时的时间
            userSelf.lineTimeInt = lineTimeInt;
            
            
            
            //数据个数
            
            @synchronized(userSelf) {
                NSInteger nQueueSize = userSelf.videoDataArr.count;
                
                if(nQueueSize > 500)
                {
                    userSelf.bIsDataQueueSizeFull = YES;
                    NSLog(@"data buffer queue is full【RTSP】, size=%ld", (long)nQueueSize);
                    [userSelf.videoDataArr removeAllObjects];
                    // return;
                }else
                {
                    userSelf.bIsDataQueueSizeFull = NO;
                }
                userSelf.bIsRtsP = YES;
                //视频数据
                CCbVideoData* videoData = [[CCbVideoData alloc]init];
                videoData.nType = payloadType;
                videoData.pData = (char*)malloc(payloadLen);
                memcpy(videoData.pData, zcPayloadData, payloadLen);
                videoData.nLen = payloadLen;
                videoData.uTimeStamp = timestamp;
                [userSelf.videoDataArr addObject:videoData];
        
                if (userSelf.isPsStream == NO) {
                    //                if (userSelf.isAudioOpen) {
                    //                    [userSelf.openAl openAudioFromQueue:(uint8_t *)pBuffer dataSize:payloadLen samplerate:8000 channels:1 bit:16];
                    //                }
                }
            }
        }
        else if (payloadType == 8) {
            //添加操作到队列中
            NSData *bufData = [NSData dataWithBytes:zcPayloadData length:payloadLen];
            NSData *audioData = [TBMALaw2PCMConverter decodeWithData:bufData];
            if (userSelf.isStartRecord) {
                [userSelf.audioRecDataArr addObject:audioData];
            }
            
            if (userSelf.isAudioOpen == NO) {
                
            }
            else{
                WeakSelf(userSelf);
                [userSelf.AudioQueue addOperationWithBlock:^{
                    [weakSelf.openAl openAudioFromQueue:(uint8_t *)audioData.bytes dataSize:audioData.length samplerate:8000 channels:1 bit:16];
                }];
            }
        }
    }
}
#pragma mark ------rtsp码流连接回调
void rtspStreamConnectStatusCallBackV2(bool bIsConnected, void *pUser)
{
    
    
}
#pragma mark ------rtmp码流连接回调
void rtmpStreamfJWConnectStreamCallBack(int32_t handle, int connect ,void *pUser)
{
   // NSLog(@"rtmp码流连接回调:%d===%d====%@",handle,connect,pUser);
    
}

#pragma mark - JWStream ConnectStreamCallBack回调
void JWStreamfJWConnectStreamCallBack(int32_t handle, int connect ,void *pUser)
{
     NSLog(@"JWStreamfJWConnectStreamCallBack码流连接回调:%d===%d====%@",handle,connect,pUser);
    ZCVideoManager *userSelf = (__bridge ZCVideoManager *)pUser;
    if (connect == 1) {//码流连接成功
        NSLog(@"JWStreamfJWConnectStreamCallBack【码流连接成功】");
    }else
    {
        NSLog(@"JWStreamfJWConnectStreamCallBack【码流连接失败】，触发超时，关闭码流连接，销毁解码线程，停止播放");
        [userSelf StreamConnectFaild];
    }
}
#pragma mark - JWStream 取流回调函数
void JWStreamResultCallBack(int32_t handle, int msg, int success, void *user)
{
    if (msg == MSG_ID_CONNECT_RESULT) {
        if (success == 1) {
            int JWStreamReaderSuccess = JWStream_Play(handle,JWStreamfJWConnectStreamCallBack,JWStreamVideoTagCallBack,JWStreamAudioTagCallBack,JWStreamFlowInfoCallBack,user,0);
            if (JWStreamReaderSuccess == 1) {
                NSLog(@"【实时】JWStream开始【取流成功】");
            }else
            {
                NSLog(@"【实时】JWStream开始【取流失败】");
            }
        }else
        {
            NSLog(@"【实时】JWStream开始【连接失败】:%d",success);
        }
    }
}

#pragma mark - JWStream JWStreamVideoTagCallBack回调
//中威视频播放部分
void JWStreamVideoTagCallBack(int32_t handle, const JWVideoTag *videoTag, void *user)
{
//     NSLog(@"JWStream JWStreamVideoTagCallBack【视频】回调:%d===%p====%@===time：%llu",handle,videoTag,user,videoTag->utcTimeStamp);
     
     
//     uint8_t frameType;  // 帧类型
//     uint8_t codecId;  // 编解码器id
//     uint8_t avcPacketType;  // avc包类型，当codecId 等于7时为H264,等于8时为H265
//     int32_t compositionTime;  // 成分时间偏移, 当avcPacketType == 1时才有效，否则都为0
     
     
//    if ((void *)user == NULL || user == nil) {
//        return;
//    }
    ZCVideoManager *userSelf = (__bridge ZCVideoManager *)user;
    // NSLog(@"转换后的userSelf：%@ ====%@",userSelf,userSelf.h264Decoder);
     
     //编码是7为 H264  编码是8为 H265
     if (videoTag->codecId == 8) {
          userSelf.h264Decoder.isNeedH265Decoder = YES;
     }else{
          userSelf.h264Decoder.isNeedH265Decoder = NO;
     }
     
     
     
    //视频数据
    /*
    LiveVideoData * liveData = [[LiveVideoData alloc]init];
    liveData.data = (char *)malloc(videoTag->dataLen);
    memcpy(liveData.data, videoTag->data, videoTag->dataLen);
    */

   // NSLog(@"JWStreamVideoTagCallBack current Thread:%@",[NSThread currentThread]);
    
  //  [unitl writeFrameToH264File:(uint8_t *)videoTag->data FrameSize:(uint32_t)videoTag->dataLen];
    
    // [userSelf.h264Decoder decodeNalu:(uint8_t *)videoTag->data withSize:(uint32_t)videoTag->dataLen];

    @synchronized (JWStreamDecodeDealDataLock) {
        NSInteger nQueueSize = userSelf.videoDataArr.count;
       // NSLog(@"解码当前线程1：queSize:%ld  %@",(long)nQueueSize,[NSThread currentThread]);

//       NSLog(@"data buffer queue size=%ld", (long)nQueueSize);
        if (nQueueSize > 320) {
            userSelf.bIsDataQueueSizeFull = YES;
            //NSLog(@"data buffer queue is full, size=%ld", (long)nQueueSize);
            //[userSelf.videoDataArr removeAllObjects];
            userSelf.h264Decoder.DecoderNeedSpeedUp = YES;
            return;
        }else
        {
            userSelf.bIsDataQueueSizeFull = NO;
            if (nQueueSize < 32) {
                userSelf.h264Decoder.DecoderNeedSpeedUp = NO;
            }
        }
    userSelf.oneTimeValue++;
   // NSLog(@"userSelf.oneTimeValue：%d",userSelf.oneTimeValue);
    if (videoTag->utcTimeStamp != 0) {
        //NSLog(@"videoTag->utcTimeStamp:%llu",videoTag->utcTimeStamp);
        userSelf.utcTime1 = videoTag->utcTimeStamp;
        userSelf.timeStamp = videoTag->timeStamp;
        userSelf.is_I_frameAppear = YES;
        NSDictionary * dic = @{@"TimeStamp":[NSNumber numberWithDouble:userSelf.utcTime1]};
        [[NSNotificationCenter defaultCenter]postNotificationName:RETURNTIMESTAMP object:nil userInfo:dic];
        userSelf.oneTimeValue = 0;
        [[NSNotificationCenter defaultCenter]postNotificationName:RETURNTIMESTAMP_TIMERULER object:nil userInfo:dic];
    }
    
    if (userSelf.is_I_frameAppear && videoTag->utcTimeStamp == 0 && userSelf.oneTimeValue == 4) {
        unsigned long tempDValue = 0;
        tempDValue = (videoTag->timeStamp - userSelf.timeStamp) / 1000;
       // NSLog(@"相加之前：%llu",userSelf.utcTime1);
        userSelf.utcTime1 = userSelf.utcTime1 + tempDValue;
       // NSLog(@"打印值是：%llu=== tempDValue:%lu",userSelf.utcTime1,tempDValue);
        NSDictionary * dic = @{@"TimeStamp":[NSNumber numberWithDouble:userSelf.utcTime1]};
        [[NSNotificationCenter defaultCenter]postNotificationName:RETURNTIMESTAMP object:nil userInfo:dic];
        userSelf.oneTimeValue = 0;
      //  [[NSNotificationCenter defaultCenter]postNotificationName:RETURNTIMESTAMP_TIMERULER object:nil userInfo:dic];
    }
        LiveVideoData * liveData = [[LiveVideoData alloc]init];
        liveData.data = (char *)malloc(videoTag->dataLen);
        liveData.dataLen = (uint32_t)videoTag->dataLen;
        memcpy(liveData.data, videoTag->data, videoTag->dataLen);
//    NSLog(@"zrtest【0x05】: 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x", liveData.data[0], liveData.data[1], liveData.data[2], liveData.data[3], liveData.data[4]);//其他帧

     // [userSelf.h264Decoder decodeNalu:(uint8_t *)liveData.data withSize:(uint32_t)liveData.dataLen];
        [userSelf.videoDataArr addObject:liveData];
       // [userSelf JWStreamCheckVideoData];
    }
}

- (BOOL)emptyVideoData
{
    self.h264Decoder.DecoderNeedSpeedUp = YES;
    if (self.videoDataArr.count > 0) {
        [self.videoDataArr removeAllObjects];
        return YES;
    }else
    {
        return NO;
    }
}

#pragma mark - JWStream JWStreamAudioTagCallBack回调
void JWStreamAudioTagCallBack(int32_t handle, const JWAudioTag *audioTag, void *user)
{
   // NSLog(@"JWStreamAudioTagCallBack【音频】回调:%d===%p====%@",handle,audioTag,user);
    /*
     if ((__bridge ZCVideoManager*)user == NULL) {
     }
     */
    // NSLog(@"audioTagCallBack连接回调:%d===%d====%@",handle,audioTag,user);
 
     ZCVideoManager *userSelf = (__bridge ZCVideoManager *)user;
     if (userSelf.isAudioOpen) {
         NSData *bufData = [NSData dataWithBytes:(uint8_t *)audioTag->data length:audioTag->dataLen];
         NSData *audioData = [TBMALaw2PCMConverter decodeWithData:bufData];
       //  [unitl writeFrameToH264File:(uint8_t *)audioData.bytes FrameSize:audioData.length];
        // NSLog(@"音频数据打印：audioData:%@  || dataSize:%lu",audioData,audioData.length);
         [userSelf.AudioQueue addOperationWithBlock:^{
         [userSelf.openAl openAudioFromQueue:(uint8_t *)audioData.bytes dataSize:audioData.length samplerate:8000 channels:1 bit:16];
         }];
         if (userSelf.isStartRecord) {
             [userSelf.audioRecDataArr addObject:audioData];
         }
     }
}
#pragma mark - JWStream JWStreamFlowInfoCallBack回调
void JWStreamFlowInfoCallBack(int32_t handle, int64_t flowBytes, int32_t byteRate, void *user)
{
   // NSLog(@"JWStreamFlowInfoCallBack【流量速度】回调,【注：就算没有视频数据也会回调】");
     if ((__bridge ZCVideoManager*)user != NULL) {
     ZCVideoManager* videoM = (__bridge ZCVideoManager*)user;
     //NSLog(@"flowInfoCallBack连接回调:%d===%lld====%d===%p",handle,flowBytes,byteRate, v);
         if (videoM.returnFlowInfoBlock != nil) {
             videoM.returnFlowInfoBlock(flowBytes,byteRate);
         }
     }
}

#pragma mark ------rtp停止播放【实时】【JWStream 关闭接口】
- (void)JWStreamStopCloudPlayRtpHandle:(JWSPHandle)handle
{
    // 关闭并释放码流句柄
    NSLog(@"rtp停止播放【实时/录像】handle:%d",handle);
    JWStream_Close(handle);
    JWStream_Release(handle);

    //停止定时器
    [self stopTimer];
    //跳出循环
    self.isPlay = NO;
    //播放音频线程停止
    [_AudioQueue cancelAllOperations];
    _AudioQueue = nil;
    //解码类销毁
    _h264Decoder.delegate = nil;
    _h264Decoder = nil;
    //解码视频线程停止
    [_VideoQueue cancelAllOperations];
    _VideoQueue = nil;
    //self.delegate = nil;//模仿新添加
    //解码视频线程停止
    [_DecodeBoxQueue cancelAllOperations];
    _DecodeBoxQueue = nil;
    
   //清空数据
    [self.videoDataArr removeAllObjects];
    //释放音频对象
    [_openAl stopSound];
    [_openAl stopDealloc];
    self.isStop = YES;
    //关闭定时器
    [_heartBeatTimer setFireDate:[NSDate distantFuture]];
}

- (void)stopTimer
{
    [self.decodeDisplayLink invalidate];
    self.decodeDisplayLink = nil;
//    [_checkTimer invalidate];
//    _checkTimer = nil;
//    [_lineTimeer invalidate];
//    _lineTimeer = nil;
}

#pragma mark - 码流连接断开【超时】
- (void)StreamConnectFaild
{
    NSLog(@"JWStream waiting stream timeout! stop monitor");
    //[self stopCloudPlay];
    //[self stopCloudPlayRtsp];//新添加
//    [_checkTimer invalidate];
//    _checkTimer = nil;
     
//    [XHToast showTopWithText:NSLocalizedString(@"播放失败", nil) topOffset:160 duration:2];
//     NSLog(@"播放失败111~");
//    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
//    [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
     
     dispatch_async(dispatch_get_main_queue(),^{
          [XHToast showTopWithText:NSLocalizedString(@"播放失败", nil) topOffset:160 duration:2];
          [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
          [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
     });

     
    _nCheckCnt = 0;
    JWVideoAddressInfo *addressInfo = self.videoAddressModel;
    [self JWStreamStopCloudPlayRtpHandle:addressInfo.handle];
}


#pragma mark - ps流处理
- (int )OCExtractPsBufferNalBuf:(char *)NalBuf begin:(int)begin len:(int)len
{
    /**
     这里ps流处理是之前的，可能有些问题。
     */
    WeakSelf(self);
    // todo:
//    if (len < 4) {
//        return len;
//    }
    
    //        Log.e(TAG, "time start=" + System.currentTimeMillis());
    int beginNew = [weakSelf OCfilterData:NalBuf begin:begin len:len];

    //        Log.e(TAG, "time end=" + System.currentTimeMillis());
    return beginNew;
}

- (void)OCExtractPsBufferNalBuf:(char *)NalBuf begin:(int)begin len:(int)len readBegin:(int)readBegin callBack:(Callback)callback callackOnRemainingData:(CallackOnRemainingData)callackOnRemainingData
{
    WeakSelf(self);
    if (callback == nil) {
        return ;
    }
    [weakSelf OCfilterData:NalBuf begin:begin len:len readBegin:readBegin callBack:callback callackOnRemainingData:callackOnRemainingData];
}

- (void)OCfilterData:(char *)data begin:(int)begin len:(int)len readBegin:(int)readBegin callBack:(Callback)callback callackOnRemainingData:(CallackOnRemainingData)callackOnRemainingData
{
    int currentPosition = readBegin;    //当前读到的字节的位置
    
    int dataBegin = begin;    //数据开始位置
    
    int tmp;

    @try {
        for (;currentPosition < readBegin + len; ++ currentPosition) {
            tmp = (data[currentPosition]) & 0xFF;
            
            //Log.e(TAG, "trans=" + trans);
            _trans <<= 8;
            //Log.e(TAG, "trans=" + trans);
            _trans |= tmp;
            
            if (_trans == 0x000001BA) {  // ps头
                _trans = 0xFFFFFFFF; // 先恢复这个判断变量
                if (self.haveData) {
                    if (callback) {
                        int outLen = currentPosition - 3 - dataBegin;
                        if (outLen > 0) {
#warning 这里回调 callback.onESData(isVideo, pts, data, dataBegin, outLen);类似的数据回去
                            callback(isVideo,self.pts,data,dataBegin,outLen);
                        }
                    }
                    self.haveData = NO;
                }
                
                // i 向后移动10个字节
                currentPosition += 10;
                
                //获取PS包的长度
                if (currentPosition >= readBegin + len) {//长度不足，全部过滤掉
                    return;
                }
                
                //获取PS包头长度
                int stuffingLength = data[currentPosition] & 0x07;
                
                if (stuffingLength > 0) { //如果还有额外数据
                    currentPosition += stuffingLength;
                    if (currentPosition >= readBegin + len) {//长度不足，则全部过滤
                        return;
                    }
                }
                
                dataBegin = currentPosition + 1;
            }else if(_trans == 0x000001BB || _trans ==  0x000001BC) {//系统标题头或节目映射流
                _trans =  0xFFFFFFFF; //先恢复这个判断变量
                
                //如果前面有数据，那么久调用回调调回上层拼帧
                if (self.haveData) {
                    if (callback != nil) {
                        int outLen = currentPosition - 3 - dataBegin;
                        if (outLen> 0) {
#warning 这里回调 callback.onESData(isVideo, pts, data, dataBegin, outLen);类似的数据回去
                            callback(isVideo,self.pts,data,dataBegin,outLen);
                        }
                    }
                    self.haveData = NO;
                }
                // i 向后移动2个字节
                currentPosition += 2;
                
                //获取PS包头长度
                if (currentPosition >= readBegin + len) { //长度不足，则全部过滤掉
                    return;
                }
#warning 这里java中是用的byte关键字。oc 中打不出小的byte关键字，暂时没查询先用Byte来代替
                //获取PS包头长度
                Byte high = data[currentPosition - 1];
                Byte low = data[currentPosition];
                int length = high * 16 + low;
                
                if (length > 0) {//如果还有额外数据
                    currentPosition += length;
                    if (currentPosition >= readBegin + len) { //长度不足，则全部过滤掉
                        return;
                    }
                }
                dataBegin = currentPosition + 1;
            }else if (((_trans & 0xFFFFFFE0) == 0x000001E0) || ((_trans & 0xFFFFFFE0) ==
                                                                0x000001C0)){//视频头
                //如果前面有数据，那么久调用回调让上层拼帧
                if (self.haveData) {
                    if (callback != nil) {
                        int outLen = currentPosition - 3 - dataBegin;
                        if (outLen > 0) {
#warning 这里回调 callback.onESData(isVideo, pts, data, dataBegin, outLen);类似的数据回去
                            callback(isVideo,self.pts,data,dataBegin,outLen);
                        }
                    }
                }
                isVideo = (_trans & 0xFFFFFFE0) == 0x000001E0;
                _trans = 0xFFFFFFFF;
                
                self.haveData = YES;
                
                currentPosition += 4;//向后移动4个字节判断是否有pts
                if (currentPosition >= readBegin +len) {
                    return;
                }
                
                BOOL havePts = NO;
                int ptsDpsMark = (data[currentPosition] & 0xc0) >> 7;
                if (ptsDpsMark == 1) {
                    havePts = YES;
                }
                
                // i向后移动1字节, pes包头长度
                currentPosition += 1;
                if (currentPosition >= readBegin + len) {  // 长度不足，则全部过滤掉
                    return;
                }
                
                // 获取PS包头长度
                int length = data[currentPosition];
                
                if (havePts) {
                    int ptsPosition = currentPosition + 5;
                    if (ptsPosition >= readBegin + len) {
                        return;
                    }
                    self.pts = ((data[currentPosition + 1] & 0x0e) << 29);
                    
                    long tmpPts = ((data[currentPosition + 2] & 0xFF) << 8);
                    tmpPts += (data[currentPosition + 3] & 0xFF);
                    self.pts += ((tmpPts & 0xfffe) << 14);
                    
                    tmpPts = ((data[currentPosition + 4] & 0xFF) << 8);
                    tmpPts += (data[currentPosition + 5] & 0xFF);
                    self.pts += ((tmpPts & 0xfffe) >> 1);
                }else{
                    //               self.pts = 0;//没有pts的话就默认用上一个。
                }
                
                if (length > 0) {//如果还有额外数据
                    currentPosition += length;
                    if (currentPosition >= readBegin + len) {  // 长度不足，则全部过滤掉
                        return;
                    }
                }
                
                //将新的起点移动到i的后一位
                dataBegin = currentPosition + 1;
            }else if (_trans == 0x00000001){//264头，有种情况是I帧的sps、pps、Iframe中夹杂这视频头
                if (!self.haveData && (currentPosition - 3 > 0)) {
//                    dataBegin = currentPosition - 3;
//                    self.haveData = YES;
                }
//                isVideo = YES;
            }
        }
    }
    @catch (NSException *exception) {
    
        NSLog(@"过滤ps流：%s\n%@", __FUNCTION__, exception);
    }
    @finally {
        // 读完还有剩余数据，回调给上层供下次使用
        if (dataBegin < readBegin + len) {
            if (callackOnRemainingData != nil) {
                int outLen = readBegin + len - dataBegin;
                if (outLen > 0) {
#warning 这里回调 callackOnRemainingData(data,dataBegin,outLen,currentPosition);类似的数据回去
                    callackOnRemainingData(data,dataBegin,outLen,currentPosition);
                }
            }
        }
       // NSLog(@"tryTwo - 我一定会执行");
    }
}

- (int)OCfilterData:(char *)data begin:(int)begin len:(int)len
{
    WeakSelf(self);
    int beginNew = begin;  // 新的起始点，若没有匹配，则为begin
    int tmp;
    
    // 临时视频数据
    //        byte[] tmpData = new byte[len];  // 不会超过len;
    int tmpLen = 0;
    
    //        Log.e(TAG, "输入长度 len=" + len + ", begin=" + begin);
    for (int i = 0; i < len; ++i) {
        tmp = (data[i + begin]) & 0xFF;  // 转化成无符号
        
        // 如果临时数据不为空，那么就是视频数据，需要保存了
        //            Log.e(TAG, "i=" + i);
        //            tmpData[tmpLen++] = data[i + begin];
        tmpLen++;
        
        //Log.e(TAG, "trans=" + trans);
        _trans <<= 8;
        //Log.e(TAG, "trans=" + trans);
        _trans |= tmp;
        
        //Log.e(TAG, "tmp=" + tmp + ", trans=" + trans + ", 0x000001BA=" + 0x000001BA + ",0xFFFFFFFF=" + 0xFFFFFFFF);
        
        if (_trans == 0x000001BA) {  // ps头
            _trans = 0xFFFFFFFF;  // 先恢复这个判断变量
            
            if (tmpLen >= 4) {
                tmpLen -= 4;  // 向前移动4位
                // 将新起始点移动到i的后一位
            }
            
            //                Log.e(TAG, "ps头");
            
            // i向后移动10字节
            i += 10;
            
            // 获取PS包头长度
            if (i >= len) {  // 长度不足，则全部过滤掉
                beginNew = len;
                return beginNew;
            }
            
            // 获取PS包头长度
            int stuffingLength = data[begin + i] & 0x07;
            
            if (stuffingLength > 0) {  // 如果还有额外数据
                i += stuffingLength;
                if (i >= len) {  // 长度不足，则全部过滤掉
                    beginNew = len;
                    return beginNew;
                }
            }
            
            // 将新起始点移动到i的后一位
            beginNew += (i + 1);
            
            break;
        } else if (_trans == 0x000001BB || _trans == 0x000001BC) {  // 系统标题头或节目映射流
            _trans = 0xFFFFFFFF;  // 先恢复这个判断变量
            
            if (tmpLen >= 4) {
                tmpLen -= 4;  // 向前移动4位
            }
            
            //                Log.e(TAG, "系统标题头或节目映射流");
            
            // i向后移动2字节
            i += 2;
            
            // 获取PS包头长度
            if (i >= len) {  // 长度不足，则全部过滤掉
                beginNew = len;
                return beginNew;
            }
            
            // 获取PS包头长度
            Byte high = data[i -1 + begin];
            Byte low = data[i + begin];
            int length = high * 16 + low;
            
            if (length > 0) {  // 如果还有额外数据
                i += length;
                if (i >= len) {  // 长度不足，则全部过滤掉
                    beginNew = len;
                    return beginNew;
                }
            }
            
            // 将新起始点移动到i的后一位
            beginNew += (i + 1);
            
            break;
        } else if ((_trans & 0xFFFFFFE0) == 0x000001E0) {  // 视频头
            _trans = 0xFFFFFFFF;
            findDataStart = YES;
            isVideo = YES;
            
            if (tmpLen >= 4) {
                tmpLen -= 4;  // 向前移动4位
            }
            //                Log.e(TAG, "视频头");
            
            // i向后移动5字节
            i += 5;
            
            // 获取PS包头长度
            if (i >= len) {  // 长度不足，则全部过滤掉
                beginNew = len;
                return beginNew;
            }
            
            // 获取PS包头长度
            int length = data[begin + i];
            
            if (length > 0) {  // 如果还有额外数据
                i += length;
                if (i >= len) {  // 长度不足，则全部过滤掉
                    beginNew = len;
                    return beginNew;
                }
            }
            
            // 将新起始点移动到i的后一位
            beginNew += (i + 1);
            
            break;
        } else if ((_trans & 0xFFFFFFE0) == 0x000001C0) {  // 音频头
            _trans = 0xFFFFFFFF;
            findDataStart = YES;
            isVideo = NO;
            
            if (tmpLen >= 4) {
                tmpLen -= 4;  // 向前移动4位
            }
            
            //                Log.e(TAG, "音频头");
            
            // i向后移动5字节
            i += 5;
            
            // 获取PS包头长度
            if (i >= len) {  // 长度不足，则全部过滤掉
                beginNew = len;
                return beginNew;
            }
            
            // 获取PS包头长度
            int length = data[begin + i];
            
            if (length > 0) {  // 如果还有额外数据
                i += length;
                if (i >= len) {  // 长度不足，则全部过滤掉
                    beginNew = len;
                    return beginNew;
                }
            }
            
            // 将新起始点移动到i的后一位
            beginNew += (i + 1);
            
            break;
        } else if (_trans == 1) {  // 264头，有种情况是I帧的sps、pps、Iframe中夹杂着视频头
            //                Log.e(TAG, "发现264头");
            _trans = 0xFFFFFFFF;
            findDataStart = YES;
            isVideo = YES;
            
            // 加上分隔符
            
            //                tmpData[tmpBegin++] = 0x00;
            //                tmpData[tmpBegin++] = 0x00;
            //                tmpData[tmpBegin++] = 0x00;
            //                tmpData[tmpBegin++] = 0x01;
            
            //                break;
        }
    }
    
    // 如果还有未过滤完的数据，则继续过滤
    if (beginNew > begin && beginNew < begin + len) {
        //            Log.e(TAG, "再次过滤 剩余长度" + (len - (beginNew - begin)));
//        beginNew = filter(data, beginNew, len - (beginNew - begin));
        beginNew = [weakSelf OCfilterData:data begin:beginNew len:len - (beginNew - begin)];

    }
    
    //        Log.e(TAG, "beginNew=" + beginNew);
    // 有视频数据在，那么再加到前面去
    if (tmpLen > 0 && beginNew > begin) {
        //            Log.e(TAG, "复制视频数据 起点" +(beginNew - tmpBegin) + " 长度" + tmpBegin);
        //        byte[] tmpData = new byte[tmpLen];
        char *tmpData = new char[tmpLen];
        //        System.arraycopy(data, begin, tmpData, 0, tmpLen);
        //        System.arraycopy(tmpData, 0, data, beginNew - tmpLen, tmpLen);
        memcpy(tmpData, data+begin, tmpLen);
        memcpy(data+beginNew - tmpLen, tmpData, tmpLen);
        delete []tmpData;
    }
    
    //        Log.e(TAG, "过滤后起始点" + (beginNew > begin ? beginNew - tmpBegin : beginNew));
    return beginNew > begin ? beginNew - tmpLen : beginNew;
}

#pragma mark ------数据处理 检测到第二帧
/**
 *
 *
 *  @ NalBuf      处理拼帧后的数据
 *  @ NalBufUsed  已使用的数据位置
 *  @ SockBuf     包缓存数据
 *  @ SockBufUsed 已使用数据
 *  @ SockRemain  未使用数据
 *
 *  @
 */
- (int)OCMergeBufferNalBuf:(char*)NalBuf NalBufUsed:(int)NalBufUsed SockBuf:(char *)SockBuf SockBufUsed:(int)SockBufUsed SockRemain:(int)SockRemain
{//把读取的数剧分割成NAL块
   int  i=0;
    char Temp;
   // NSLog(@"SockRemain:%d====SockBufUsed:%d===NalBufUsed:%d",SockRemain,SockBufUsed,NalBufUsed);
    for(i=0; i<SockRemain; i++)
    {
        Temp  = SockBuf[i+SockBufUsed];
        NalBuf[i+NalBufUsed]=Temp;
        _mTrans <<= 8;
        _mTrans  |= Temp;
        if(_mTrans == 1) // 找到一个开始字
        {
            i++;
            break;
        }
    }
    return i;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self newSDK];
    }
    return self;
}
- (void)newSDK
{
    _trans = 0xFFFFFFFF;
    _mTrans=0x0F0F0F0F;
    isVideo = YES;
    // 找到数据起始
    findDataStart = NO;
    _nCheckCnt = 0;
    //是否正在处理数据
    self.isPlay = NO;
    self.isStop = YES;
    self.isStartRecord = NO;//录像关闭
    self.isStep = NO;//云台关闭
    self.isAudioOpen = NO;//默认关闭声音
    self.isRecordAudio = NO;
    //视频数据数组初始化
    self.videoDataArr = [NSMutableArray array];
    NSLog(@"视频数据数组初始化");
    _utcTime1 = 0;
    self.oneTimeValue = 0;
    //硬解码对象
    self.h264Decoder = [[H264HwDecoderImpl alloc] init];
    self.h264Decoder.delegate = self;
    
    //音频对象
    self.openAl = [NewTwoOpenAl sharePalyer];
}

-(void)checkVideoData
{
    
//   // NSLog(@"我只想数据显示");
//    WeakSelf(self);
//    _nCheckCnt++;
//    if (weakSelf.videoDataArr.count == 0)
//    {
//        //等待超流时停止监控
//        if(_nCheckCnt > 100)
//        {
//            NSLog(@"waiting stream timeout! stop monitor");
//            [self stopCloudPlay];
//            [self stopCloudPlayRtsp];//新添加
//            [_checkTimer invalidate];
//            _checkTimer = nil;
//            NSLog(@"retry over!");
//            [XHToast showTopWithText:@"播放失败" topOffset:160 duration:2];
//            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
//            [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
//            _nCheckCnt = 0;
//        }
//
//      //  [XHToast showTopWithText:@"请等待...." topOffset:160];
//        return ;
//    }
//    //提示框消失
//    //定时器停止
//    [_checkTimer invalidate];
//    _checkTimer = nil;
//    if (iOS_8_OR_LATER) {
//        WeakSelf(self);
//        //监控超时连接的定时器
////        _lineTimeer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(observeOnline) userInfo:nil repeats:YES];
//
//        _lineTimeer = [MSWeakTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(observeOnline) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
//
////        _DecodeBoxQueue = [[NSOperationQueue alloc]init];
////        _DecodeBoxQueue.maxConcurrentOperationCount = 1;
////        [_DecodeBoxQueue addOperationWithBlock:^{
//           // [weakSelf videoBoxdecode];
//       // NSLog(@"我只想数据显示1：videoCount:%lu [0]：%@",(unsigned long)self.videoDataArr.count,self.videoDataArr[0]);
//
//            if (self.videoDataArr.count > 0) {
//                LiveVideoData *videoData = self.videoDataArr[0];
////                liveData.data = (char *)malloc(videoTag->dataLen);
////                memcpy(liveData.data, videoTag->data, videoTag->dataLen);
//               // NSLog(@"我只想数据显示2：%s 长度：%d",videoData.data,videoData.dataLen);
//                [self.h264Decoder decodeNalu:(uint8_t *)videoData.data withSize:(uint32_t)videoData.dataLen];
//            }
//       // }];
//    }else
//    {
//    }
//    _nCheckCnt = 0;
//    return ;
}

//中威视频播放部分
-(void)JWStreamCheckVideoData
{
    WS(weakSelf);
//    _nCheckCnt++;
//    if (weakSelf.videoDataArr.count == 0)
//    {
//        //NSLog(@"JWStream timeout:%d",_nCheckCnt);
//        //等待超流时停止监控
//        if(_nCheckCnt > timeOutLimited * FPS)
//        {
//            NSLog(@"JWStream waiting stream timeout! stop monitor");
//            //[self stopCloudPlay];
//            //[self stopCloudPlayRtsp];//新添加
//            [_checkTimer invalidate];
//            _checkTimer = nil;
//            [XHToast showTopWithText:NSLocalizedString(@"播放失败", nil) topOffset:160 duration:2];
//            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
//            [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
//            _nCheckCnt = 0;
//            JWVideoAddressInfo *addressInfo = self.videoAddressModel;
//            [self JWStreamStopCloudPlayRtpHandle:addressInfo.handle];
//        }
//        return ;
//    }
    @synchronized (JWStreamDecodeDealDataLock) {//
        if (iOS_8_OR_LATER) {
            //监控超时连接的定时器
//             _lineTimeer = [MSWeakTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(observeOnline) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
            [_DecodeBoxQueue addOperationWithBlock:^{
                 //weakSelf.videoDataArr.count
                if (weakSelf.videoDataArr.count > 0) {
//                    NSLog(@"视频播放码流self.videoDataArr：%@", weakSelf.videoDataArr);
                     LiveVideoData *videoData;
                     //注释：self.videoDataArr[0]可能.count里面放一个空的值，下面会崩溃
                     if (_videoDataArr) {
                          if (weakSelf.videoDataArr[0]) {
                                videoData = weakSelf.videoDataArr[0];
                          }
                     }
//                     if (weakSelf.videoDataArr.count > 0 && weakSelf.videoDataArr[0] ) {
//                              videoData = weakSelf.videoDataArr[0];
//                     }
                    
                    [weakSelf.videoDataArr removeObjectAtIndex:0];
                   // NSLog(@"我只想数据显示JWStream 1：%s 长度：%d 线程：%@",videoData.data,videoData.dataLen,[NSThread currentThread]);
                    [weakSelf.h264Decoder decodeNalu:(uint8_t *)videoData.data withSize:(uint32_t)videoData.dataLen];
                    _nCheckCnt = 0;
                }
            }];
        }else//低于iOS8的可以用FFmpeg去软解
        {
             NSLog(@"我要去软解？？？");
        }
    }
}

#pragma mark ------监控超时连接
- (void)observeOnline
{
    [XHToast showTopWithText:NSLocalizedString(@"播放失败", nil) topOffset:160 duration:2];
    NSLog(@"播放失败222~");
  
    WeakSelf(self);
    NSDate *senddate = [NSDate date];
    int lineTimeInt =  [senddate timeIntervalSince1970];
    int differenceValue = lineTimeInt - weakSelf.lineTimeInt;
    NSLog(@"超时机制，差值：%d",differenceValue);
    if ( differenceValue > 10) {
        [self stopCloudPlay];
        [self stopCloudPlayRtsp];//新添加
        [XHToast showTopWithText:NSLocalizedString(@"视频流中断，请重新播放", nil) topOffset:160 duration:2];
        //对外发出播放失败的通知
        [[NSNotificationCenter defaultCenter]postNotificationName:ONLINESTREAM object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
    }
    
}

#pragma mark ------硬解码_new
- (void)videoBoxdecode
{
    //音频对象
    self.openAl = [NewTwoOpenAl sharePalyer];
    //硬解码对象
    //解音频的队列
    self.AudioQueue = [[NSOperationQueue alloc] init];
    self.AudioQueue.maxConcurrentOperationCount = 1;
    //解视频队列
    self.VideoQueue = [[NSOperationQueue alloc]init];
    self.VideoQueue.maxConcurrentOperationCount = 1;
    
    _nCheckCnt=0;
    self.isPlay = YES;
    self.isStop = NO;
   __block int nalLen;
    //包数据总长度
    int bytesNeedRead = 0;

    
    //已经读取的包长
   __block int SockBufUsed = 0;
    
    int dataBegin = 0;//数据开始的位置
    
    bFirst=true;
    bFindPPS=true;
    
    tmpRemainLen = 0;
    tmpReadStart = 0;
    firstPts = -1.000;
    nowTime = -1.000;
    firstDataUtimeStamp = -1.000;
    self.bIsResetNowTime = NO;
    
    //包数据的缓存
     self.SockBuf = (char*)malloc(804800);
    
    //解码之后的数据
    char *buffOut;
    buffOut = (char*)malloc(1920*1080);
    //转成rgb位图的数据
    char *rgbBuffer;
    rgbBuffer = (char*)malloc(1920*1080*3);
    //解码之后数据大小 宽度 高度
    int outSize;
    outSize = 1920*1080;
    memset(_SockBuf,0,204800);
    memset(buffOut,0, outSize);
    //拼帧后的数据
   // char  NalBuf[409800]; // 400k
    
    NalBufUsed = 0;
    
    char *NalBufPtr;
    NalBufPtr = NalBuf;
    //已使用的数据位置

    char * SockBufPtr;
    SockBufPtr = _SockBuf;

    while (self.isPlay) {
        @autoreleasepool {
            //已经读取的包长
            SockBufUsed = 0;
            
            if (self.videoDataArr.count == 0)
            {
                usleep(30);
                continue;
            }
            @synchronized(decodeQueueLock) {
               // NSLog(@"self.videoDataArr:%@",self.videoDataArr);
              
                if (self.videoDataArr.count > 0 && self.videoDataArr[0]) {//注释：self.videoDataArr[0]可能.count里面放一个空的值，下面会崩溃
                    CCbVideoData *videoData = self.videoDataArr[0];
                    //NSData *VideoBufData = [[NSData alloc]initWithBytes:videoData.pData length:videoData.nLen];
                  // NSLog(@"所在线程：%@==!!!!!!!!!!!!!!!!!!len[%d] VideoBufData.bytes,type:%d",[NSThread currentThread],videoData.nLen,videoData.nType);
                    if (tmpRemainLen > 0) {
                        memcpy(_SockBuf, tmpRemainBuf, tmpRemainLen);
                    }
                    memcpy(_SockBuf + tmpRemainLen, videoData.pData, videoData.nLen);
                    //                                        for (int i = 0; i < 100; i++) {
                    //                                            NSLog(@"SockBuf:%02x",SockBuf[i]);
                    //                                        }
                    //                                        NSLog(@"===================");
                    //包数据长度
                    bytesNeedRead = videoData.nLen;
                    SockBufUsed = tmpRemainLen;
                    tmpRemainLen = 0;
                    if (self.videoDataArr.count > 0) {
                        [self.videoDataArr removeObjectAtIndex:0];
                    }
                    if (videoData.pData) {
                        free(videoData.pData);
                        videoData.pData = NULL;
                        //videoData = nil;
                    }
                    if (nowTime == -1.000 || self.bIsResetNowTime) {
                        nowTime = [[self getNowTimeTimestamp3] longLongValue];
                        // NSLog(@"nowTime:%ld",nowTime);
                    }
                    if (firstDataUtimeStamp == -1.000) {
                        firstDataUtimeStamp = videoData.uTimeStamp;
                    }
                    DataUtimeStamp = videoData.uTimeStamp;
                }
            }//锁
            
            if (bytesNeedRead<=0) {
                break;
            }
            //是ps流
            if (_isPsStream) {
                
                //int newSockBufUsed = [self OCExtractPsBufferNalBuf:SockBuf begin:SockBufUsed len:bytesRead];
               // NSLog(@"是ps流");
#warning 这边是新写的过滤ps流的方法。
                WS(weakSelf);
               // NSLog(@"input dataBegin:【%d】===bytesNeedRead:【%d】==SockBufUsed[%d]",dataBegin,bytesNeedRead,SockBufUsed);
                [self OCExtractPsBufferNalBuf:_SockBuf begin:dataBegin len:bytesNeedRead readBegin:SockBufUsed callBack:^(BOOL video, long pts, char *outData, int outStart, int outLen) {
                   // NSData * VideoOutData = [NSData dataWithBytes:outData + outStart length:outLen];
                  // NSLog(@"所在线程：%@==新【callBack】===video:%@===pts:%ld===outStart:【%d】===outLen:【%d】data:",[NSThread currentThread],video?@"YES":@"NO",pts,outStart,outLen);

                    if (firstPts == -1.000) {
                        firstPts = pts;
                    }
                   // NSLog(@"firstPts:%ld===pts:%ld",firstPts,pts);
                    [weakSelf OCDealWithOnCurrentData:outData Video:video Pts:pts OutStart:outStart OutLen:outLen];
                    
                }callackOnRemainingData:^(char *outData, int outStart, int outLen, int readedStart) {

                    memcpy(tmpRemainBuf + tmpRemainLen, outData + outStart, outLen);
                    tmpRemainLen += outLen;
                    tmpReadStart = readedStart;
                }];
            } else {
               // NSLog(@"所在线程：%@==不是ps流==isVideo：%@==len:%d===dataBegin:%d",[NSThread currentThread],isVideo?@"YES":@"NO",bytesNeedRead,dataBegin);
                [self OCDealWithOnCurrentData:_SockBuf Video:isVideo Pts:0 OutStart:dataBegin OutLen:bytesNeedRead];
            }
        }
    }
}

- (void)OCDealWithOnCurrentData:(char *)outData
                          Video:(BOOL)video
                            Pts:(long)pts
                       OutStart:(int)outStart
                         OutLen:(int)outLen
{
    WS(weakSelf);
    //unsigned char* a = (unsigned char*)outData;
   //NSLog(@"zrtest ps video:%d len:%d---------: 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x||0x%02x 0x%02x 0x%02x 0x%02x 0x%02x", video, outLen, a[outStart], a[outStart+1], a[outStart+2], a[outStart+3], a[outStart+4],a[outStart+5], a[outStart+6], a[outStart+7], a[outStart+8], a[outStart+9], a[outStart+outLen-5], a[outStart+outLen-4], a[outStart+outLen-3], a[outStart+outLen-2], a[outStart+outLen-1]);//其他帧
    if (video) {
        int readed = 0;
        while (outLen - readed > 0) {
            
            /**
             *  @ NalBuf      处理拼帧后的数据
             *  @ NalBufUsed  已使用的数据位置 outStart
             *  @ SockBuf     包缓存数据
             *  @ SockBufUsed 已使用数据
             *  @ SockRemain  未使用数据
             *  @
             */
            
            int coyplen =[weakSelf OCMergeBufferNalBuf:NalBuf
                                            NalBufUsed:NalBufUsed
                                               SockBuf:outData + outStart
                                           SockBufUsed:readed
                                            SockRemain:outLen-readed];
            readed += coyplen;
            NalBufUsed += coyplen;
           // NSLog(@"outData：%@===outStart:%d",outData,outStart);
            if (NalBufUsed > 409800) {
                NalBuf[0]=0;
                NalBuf[1]=0;
                NalBuf[2]=0;
                NalBuf[3]=1;
                NalBufUsed=4;
                break;
            }
            
            while(_mTrans == 1)
            {
                _mTrans = 0xFFFFFFFF;
                if(bFirst==true) // the first start flag
                {
                    bFirst = false;
                    NalBuf[0]=0;
                    NalBuf[1]=0;
                    NalBuf[2]=0;
                    NalBuf[3]=1;
                    NalBufUsed=4;
                    break;
                }
                else  // a complete NAL data, include 0x00000001 trail.
                {
                    if(bFindPPS==true) // true
                    {
                        if( (NalBuf[4]&0x1F) == 7 )
                        {
                            bFindPPS = false;
                        }
                        else
                        {
                            NalBuf[0]=0;
                            NalBuf[1]=0;
                            NalBuf[2]=0;
                            NalBuf[3]=1;
                            NalBufUsed = 4;
                            break;
                        }
                    }
                }
                if (NalBufUsed<=4) {
                    NalBuf[0]=0;
                    NalBuf[1]=0;
                    NalBuf[2]=0;
                    NalBuf[3]=1;
                    NalBufUsed=4;
                    NSLog(@"！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！");
                    break;
                }
               // NSLog(@"zrtest es--------: 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x||0x%02x 0x%02x 0x%02x 0x%02x 0x%02x", NalBuf[0], NalBuf[1], NalBuf[2], NalBuf[3], NalBuf[4],NalBuf[5], NalBuf[6], NalBuf[7], NalBuf[8], NalBuf[9], NalBuf[NalBufUsed-5], NalBuf[NalBufUsed-4], NalBuf[NalBufUsed-3], NalBuf[NalBufUsed-2], NalBuf[NalBufUsed-1]);//其他帧
                //NSLog(@"video:%d VideoBufData.bytes:%@", video,VideoBufData);
                NSData *VideoBufData = [[NSData alloc]initWithBytes:NalBuf length:NalBufUsed];

                NalBuf[0]=0;
                NalBuf[1]=0;
                NalBuf[2]=0;
                NalBuf[3]=1;
                NalBufUsed=4;

                float speedValue = 1.0;
                if ([[NSUserDefaults standardUserDefaults]objectForKey:@"SpeedValue"]) {
                    speedValue = [[[NSUserDefaults standardUserDefaults]objectForKey:@"SpeedValue"] floatValue];
                }
                //NSLog(@"speedValue:%f",speedValue);
                nowTime2 = ([[weakSelf getNowTimeTimestamp3] longLongValue])/speedValue;
                long currentDecodeTime = nowTime + (pts - firstPts);
                long timeddd = currentDecodeTime - nowTime2;
                //NSLog(@"timeddd:%ld====now:%ld====pts:%ld",timeddd,(nowTime2 - nowTime),(pts - firstPts));
                
                long currentDecodeTime_BY_RTSP = nowTime + (DataUtimeStamp - firstDataUtimeStamp);
                long timeddd_RTSP = currentDecodeTime_BY_RTSP - nowTime2;
                
                if (speedValue >1.0) {
                    weakSelf.h264Decoder.DecoderNeedSpeedUp = YES;
                }else{
                    if (self.bIsRtsP) {
                        if (timeddd_RTSP < -107374182) {
                            self.bIsResetNowTime = YES;
                        }
                        if ( timeddd_RTSP < -3 ||self.bIsDataQueueSizeFull) {
                            weakSelf.h264Decoder.DecoderNeedSpeedUp = YES;
                            self.bIsResetNowTime = NO;
                        }
                        if (timeddd_RTSP > 3 || !self.bIsDataQueueSizeFull) {
                           // weakSelf.h264Decoder.DecoderNeedSpeedUp = NO;
                            self.bIsResetNowTime = NO;
                        }
                    }else{
                        if (timeddd < -107374182) {
                            self.bIsResetNowTime = YES;
                        }
                        if ( timeddd < -3 ||self.bIsDataQueueSizeFull) {
                            weakSelf.h264Decoder.DecoderNeedSpeedUp = YES;
                            self.bIsResetNowTime = NO;
                        }
                        if (timeddd > 3 || !self.bIsDataQueueSizeFull) {
                          //  weakSelf.h264Decoder.DecoderNeedSpeedUp = NO;
                            self.bIsResetNowTime = NO;
                        }
                    }
                }
                [weakSelf.VideoQueue addOperationWithBlock:^{
                    if (weakSelf.key && weakSelf.bIsEncrypt) {
                        weakSelf.h264Decoder.key = weakSelf.key;
                        weakSelf.h264Decoder.bIsEncrypt = weakSelf.bIsEncrypt;
                    }
                    // NSLog(@"所在线程：%@===输入解码器之前==VideoBufData.len:%ld", [NSThread currentThread],VideoBufData.length);
                    [weakSelf.h264Decoder decodeNalu:(uint8_t *)VideoBufData.bytes withSize:(uint32_t)VideoBufData.length];
                }];
            }
        }
    } else {
        //音频处理：
        //添加操作到队列中
        NSData *bufData = [NSData dataWithBytes:outData + outStart length:outLen];
       // NSLog(@"音频处理前长度2：%d===outData:%d==outStart:%d====%@",outLen,outData,outStart,bufData);
        NSData *audioData = [TBMALaw2PCMConverter decodeWithData:bufData];
       //  NSLog(@"audioBufData.len:%ld =====：%@", audioData.length,audioData);
        if (_isStartRecord) {
            [self.audioRecDataArr addObject:audioData];
        }
        
        if (self.isAudioOpen == NO) {
            return;
        } else {
            [self.AudioQueue addOperationWithBlock:^{
                [weakSelf.openAl openAudioFromQueue:(uint8_t *)audioData.bytes dataSize:audioData.length samplerate:8000 channels:1 bit:16];
            }];
        }
    }
}

#pragma mark ------硬解代理
//H264解码后的视图buffer返回代理
- (void)displayDecodedFrame:(CVImageBufferRef)imageBuffer//CVImageBufferRef原本是这个，但是会有转换的时候，让buffer为0的情况。故后面在判断为空的时候，不能渲染CVPixelBufferRef
{
    if(imageBuffer)
    {
        //得到视频宽高
        _videoWidth = (int)CVPixelBufferGetWidth(imageBuffer);
        _videoHeight = (int)CVPixelBufferGetHeight(imageBuffer);
        //NSLog(@"解码当前线程3：%@",[NSThread currentThread]);

        if (self.delegate && [self.delegate respondsToSelector:@selector(setUpBuffer:)]) {
            [self.delegate setUpBuffer:imageBuffer];
        }
        if (imageBuffer != nil ) {
            if (_isStartRecord) {
                CVPixelBufferRetain(imageBuffer);
                WeakSelf(self);
                [_VideoRecQueue addOperationWithBlock:^{
                    weakSelf.videoFps++;
                    CMTime presentTime = CMTimeMake(weakSelf.videoFps,FPS);
                    CMTime audioTime = CMTimeMake(weakSelf.videoFps, FPS);

                    [weakSelf.recordEncoder encodeFrame:imageBuffer isVideo:_isStartRecord time:presentTime];
                    if (self.audioRecDataArr.count != 0) {
                        NSData *audioData = self.audioRecDataArr[0];

                        [weakSelf.recordEncoder writeAudioBytesWithDataBuffer:(unsigned char *)audioData.bytes withLength:(unsigned int)audioData.length time:audioTime];
                        [self.audioRecDataArr removeObject:audioData];
                    }
                    CVPixelBufferRelease(imageBuffer);
                }];
            }
        }
    }else{
       // NSLog(@"解码当前线程3：【imageBuffer为空】");
    }
}


#pragma mark ------JWStream 播放
- (void)JWStreamStartBIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsPlayBack:(BOOL)bIsPlayBack DeviceId:(NSString *)deviceId bIsCenterPalyType:(BOOL)CenterType{
     
     NSLog(@"是否要加密：%d====密钥匙：%@====以及deviceId:%@===还有是不是：%d",self.bIsEncrypt,self.key,deviceId,CenterType);

     /**
      * @brief 注意
      *  @param bIsEncrypt:是通过设备列表获取到视频是否需要传密钥的(YES:需传；NO:不用传)
      *  @param key:是通过设备列表获取到视频需要的密钥(注意:此值默认一定会有的，所以故此处需要通过bIsEncrypt来判断是否需要加密。
                YES:就设置key为传来的值；NO:就设置key为空即可，若不做如此判断，一些国标设备【不需要加密的设备将无法播放】)
      */
     self.bIsEncrypt = bIsEncrypt;
     if (self.bIsEncrypt) {
        self.key = key;
     }else{
        self.key = @"";
     }
     
    self.bIsPlayBack = bIsPlayBack;
    [self JWStreamGetMainThreadStartWithDeviceId:deviceId bIsCenterPalyType:CenterType];
}

- (void)JWStreamGetMainThreadStartWithDeviceId:(NSString *)deviceId bIsCenterPalyType:(BOOL)CenterType
{
    NSLog(@"在码流连接的时候TTTT  JWStreamGetMainThreadStartWithDeviceId：%d",CenterType);
    mrts *model = self.videoAddressModel.mrts;
    // 开始获取码流(获取实时流 或者 获取录像流)
    //void *puser = (__bridge void *)self;
    void *puser = (__bridge_retained void *)self;
    NSLog(@"在码流连接的时候：%p",&puser);
    //jwsp://tcp-aeb4ea4f-ab90-4c03-88a7-2ae8ece1c4ee:180505711008956@47.96.253.15:22067/rtp=fu    安卓录像
    //jwsp://tcp-458dc4f0-a4dc-417b-baa2-d1f8cfb6c892:180505711008956@47.96.253.15:22004/rtp=fu    安卓实时
    
    //jwsp://47.97.71.82:11279:11315:rtp=fu iOS录像
    //jwsp://47.97.71.82:11324:11294:rtp=fu iOS实时
    WS(weakSelf);
    dispatch_async(weakSelf.heartBeatQueue, ^{
        NSLog(@"JWStream开启心跳线程");
        if (![NSThread isMainThread]) {
            //开启定时器
            [_heartBeatTimer setFireDate:[NSDate distantPast]];
            _heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:heartBeat_intervalTime target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
            //将定时器添加到runloop中
            [[NSRunLoop currentRunLoop] addTimer:_heartBeatTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        }
    });

    if (model.v_ip.length != 0) {
        NSString * tempUrl = [NSString stringWithFormat:@"jwsp://%@:%d:%d:rtp=fu",model.v_ip,model.v_port,model.a_port];
        
        const char* url = [tempUrl UTF8String];const char* key = [self.key UTF8String];
         NSLog(@"在码流连接的时候 tempURL:%@以及完整的Url:%s",tempUrl,url);
        int stream_Connect = JWStream_Connect(self.SPhandle,url,key,JWStreamResultCallBack,puser,5);
        //获取码流成功
        if (stream_Connect == 1) {
            NSLog(@"getMainThreadStart==打开了码流【视频】【成功】1");
            //主线程添加定时器 超时停止监控 连接成功开启新线程
            _DecodeBoxQueue = [[NSOperationQueue alloc]init];
            [_DecodeBoxQueue setName:@"_DecodeBoxQueue"];
            _DecodeBoxQueue.maxConcurrentOperationCount = 1;
            self.AudioQueue = [[NSOperationQueue alloc] init];
            [self.AudioQueue setName:@"_AudioQueue"];
            self.AudioQueue.maxConcurrentOperationCount = 1;
            self.isPlay = YES;
            self.isStop = NO;
            //暂时注释
            //_checkTimer = [MSWeakTimer scheduledTimerWithTimeInterval:SPF target:self selector:@selector(JWStreamCheckVideoData) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];//
            self.decodeDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(JWStreamCheckVideoData)];
           //  self.decodeDisplayLink.frameInterval = ;
            [self.decodeDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//            [self.decodeDisplayLink setPaused:YES];
//            [self.mDispalyLink setPaused:NO];
              //_lineTimeer = [MSWeakTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(observeOnline) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        }
        else{
            NSLog(@"getMainThreadStart==打开了码流【视频】【失败】1");
            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
        }
    }
}


#pragma mark ------威云开始播放
- (void)startCloudPlayBIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsPlayBack:(BOOL)bIsPlayBack DeviceId:(NSString *)deviceId bIsCenterPalyType:(BOOL)CenterType{
    self.bIsEncrypt = bIsEncrypt;
    self.key = key;
    self.bIsPlayBack = bIsPlayBack;
    [self getMainThreadStartWithDeviceId:deviceId bIsCenterPalyType:CenterType];
}

- (void)getMainThreadStartWithDeviceId:(NSString *)deviceId bIsCenterPalyType:(BOOL)CenterType
{
    WS(weakSelf);
    dispatch_async(weakSelf.heartBeatQueue, ^{
        NSLog(@"开启心跳线程");
        if (![NSThread isMainThread]) {
            //开启定时器
            [_heartBeatTimer setFireDate:[NSDate distantPast]];
            _heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:heartBeat_intervalTime target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
            //将定时器添加到runloop中
            [[NSRunLoop currentRunLoop] addTimer:_heartBeatTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        }
    });
    mrts * model = [[mrts alloc]init];
    model = self.videoAddressModel.mrts;
    // 开始获取码流(获取实时流 或者 获取录像流)
    unsigned int uStreamId = 0;
    unsigned int audioStreamId;
    void *puser = (__bridge void *)self;
    if (model.v_ip.length != 0) {
        if (self.streamId > 0) {
            VmNet_StopStream(self.streamId);
            NSLog(@"getMainThreadStart==停止了码流=======%u",self.streamId);
            self.streamId = 0;
        }
       // NSLog(@"monitor_id:%s====bIsPlayBack:%@====deviceId:%s",[self.videoAddressModel.monitor_id cStringUsingEncoding:NSUTF8StringEncoding],self.bIsPlayBack?@"YES":@"NO",[deviceId cStringUsingEncoding:NSUTF8StringEncoding]);
        if (CenterType) {
            NSLog(@"【码流获取】云端，开启2路流");
            int startStreamIntExt_video = VmNet_StartStreamExt([model.v_ip cStringUsingEncoding:NSASCIIStringEncoding],
                                                               model.v_port,
                                                               StreamCallBackExt,
                                                               streamConnectStatusCallBack,
                                                               puser,
                                                               uStreamId,
                                                               [self.videoAddressModel.monitor_id cStringUsingEncoding:NSUTF8StringEncoding],
                                                               [deviceId cStringUsingEncoding:NSUTF8StringEncoding],
                                                               self.bIsPlayBack ? VMNET_PLAY_TYPE_PLAYBACK:VMNET_PLAY_TYPE_REALPLAY,
                                                               VMNET_CLIENT_TYPE_IOS);
            int startStreamIntExt_audio = VmNet_StartStreamExt([model.a_ip cStringUsingEncoding:NSASCIIStringEncoding],
                                                               model.a_port,
                                                               StreamCallBackExt,
                                                               streamConnectStatusCallBack,
                                                               puser,
                                                               audioStreamId,
                                                               [self.videoAddressModel.monitor_id cStringUsingEncoding:NSUTF8StringEncoding],
                                                               [deviceId cStringUsingEncoding:NSUTF8StringEncoding],
                                                               self.bIsPlayBack ? VMNET_PLAY_TYPE_PLAYBACK:VMNET_PLAY_TYPE_REALPLAY,
                                                               VMNET_CLIENT_TYPE_IOS);
            self.streamId = uStreamId;
            self.audioStreamId = audioStreamId;
            // NSLog(@"getMainThreadStart==打开了码流=====uStreamId:%u===startStreamInt是否等于0(成功)：%@",uStreamId,startStreamInt?@"NO":@"YES");
            NSLog(@"getMainThreadStart==打开了码流startStreamIntExt_audio【音频】【%@】",startStreamIntExt_audio == 0 ?@"成功":@"失败");
            //获取码流成功
            if (startStreamIntExt_video == 0) {
                NSLog(@"getMainThreadStart==打开了码流【视频】【成功】1");
                //主线程添加定时器 超时停止监控 连接成功开启新线程
                _checkTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkVideoData) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
            }
            else{
                NSLog(@"getMainThreadStart==打开了码流【视频】【失败】1");
                [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
            }
        }
        else{
             NSLog(@"【码流获取】设备，开启ps流获取");
            NSLog(@"获取码流入参：%s  ===  %d  ==  %@  ==  bIsPlayBack:%@ === %u === %s == %@",[model.v_ip cStringUsingEncoding:NSASCIIStringEncoding],model.v_port,self.videoAddressModel.monitor_id,self.bIsPlayBack?@"YES":@"NO",uStreamId,[deviceId cStringUsingEncoding:NSUTF8StringEncoding],puser);
            int startStreamIntExt = VmNet_StartStreamExt([model.v_ip cStringUsingEncoding:NSASCIIStringEncoding],
                                                         model.v_port,
                                                         StreamCallBackExt,
                                                         streamConnectStatusCallBack,
                                                         puser,
                                                         uStreamId,
                                                         [self.videoAddressModel.monitor_id cStringUsingEncoding:NSUTF8StringEncoding],
                                                         [deviceId cStringUsingEncoding:NSUTF8StringEncoding],
                                                         self.bIsPlayBack ? VMNET_PLAY_TYPE_PLAYBACK:VMNET_PLAY_TYPE_REALPLAY,
                                                         VMNET_CLIENT_TYPE_IOS);
            self.streamId = uStreamId;
            // NSLog(@"getMainThreadStart==打开了码流=====uStreamId:%u===startStreamInt是否等于0(成功)：%@",uStreamId,startStreamInt?@"NO":@"YES");

            // [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];//调试用

            //获取码流成功
            if (startStreamIntExt == 0) {
                 NSLog(@"getMainThreadStart==打开了码流【成功】2");
                //主线程添加定时器 超时停止监控 连接成功开启新线程TODO= checkVideoData
                _checkTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkVideoData) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
            }
            else{
                NSLog(@"getMainThreadStart==打开了码流【失败】2  ===startStreamIntExt:%d",startStreamIntExt);
                [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
            }
        }
    }else
    {
        NSLog(@"播放参数：model.v_ip为空");
    }
}

- (void)heartBeat
{
     NSLog(@"self.videoAddressModel.monitor_id:%@===self.bIsPlayBack:%@",self.videoAddressModel.monitor_id,self.bIsPlayBack?@"YES":@"NO");
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL] && self.videoAddressModel.monitor_id) {
        NSData * oldRect = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:oldRect];
         /*
        APP_Environment environment = [unitl environment];
        NSString * SERVER_IP = @"";
        switch (environment) {
            case Environment_official:
                SERVER_IP = [self queryIpWithDomain:HEARTBEAT_SERVER_ADDRESS];
                break;
            case Environment_test:
                SERVER_IP = [self queryIpWithDomain:HEARTBEAT_TEST_SERVER_ADDRESS];
                break;
            default:
                break;
        }
         */
         NSString * SERVER_IP = IP;
        NSLog(@"SERVER_IP:%@",SERVER_IP);
        if (SERVER_IP) {
            BOOL SendHeartbeat = VmNet_SendHeartbeat([SERVER_IP cStringUsingEncoding:NSASCIIStringEncoding],
                                                     HEARTBEAT_SERVER_PORT,
                                                     self.bIsPlayBack ? VMNET_HEARTBEAT_TYPE_PLAYBACK:VMNET_HEARTBEAT_TYPE_REALPLAY,
                                                     [self.videoAddressModel.monitor_id cStringUsingEncoding:NSASCIIStringEncoding],
                                                     [userModel.user_id cStringUsingEncoding:NSASCIIStringEncoding]);
            if (SendHeartbeat) {
                NSLog(@"【发送心跳包成功】,%@",self.bIsPlayBack?@"PLAYBACK":@"REALPLAY");
            }else{
                NSLog(@"【发送心跳包失败】,%@",self.bIsPlayBack?@"PLAYBACK":@"REALPLAY");
            }
        }
    }
}

#pragma mark 域名转IP
- (NSString *)queryIpWithDomain:(NSString *)domain
{
    struct hostent *hs;
    struct sockaddr_in server;
    if ((hs = gethostbyname([domain UTF8String])) != NULL)
    {
        server.sin_addr = *((struct in_addr*)hs->h_addr_list[0]);
        return [NSString stringWithUTF8String:inet_ntoa(server.sin_addr)];
    }
    return nil;
}

#pragma mark 获取当前时间（毫秒）
//获取当前时间戳  （以毫秒为单位）
- (NSString *)getNowTimeTimestamp3{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制 YYYY-MM-dd
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
   // NSLog(@"当前的时间是：%@",timeSp);
    return timeSp;
}
#pragma mark ------威云停止播放
- (void)stopCloudPlay
{
    [self getMainThreadEnd];
}
-(void)getMainThreadEnd
{
  // free(self.SockBuf);
    //停止定时器
    [self stopTimer];
    NSLog(@"停止码流的编号=========== %d %d",self.streamId,self.audioStreamId);
    if (self.streamId > 0) {
        VmNet_StopStream(self.streamId);
        VmNet_ClosePlaybackStream(self.streamId);
        VmNet_StopStreamByRtsp(self.streamId);
        
        VmNet_StopStream(self.audioStreamId);
        VmNet_ClosePlaybackStream(self.audioStreamId);
        VmNet_StopStreamByRtsp(self.audioStreamId);
        NSLog(@"getMainThreadEnd==停止了码流=======%u %u",self.streamId,self.audioStreamId);
        self.streamId = 0;
        nowTime = 0;
        nowTime2 = 0;
    }
    //跳出循环
    self.isStop = YES;
    self.isPlay = NO;
    //播放音频线程停止
    [_AudioQueue cancelAllOperations];
    _AudioQueue = nil;

    [_VideoQueue cancelAllOperations];
    _VideoQueue = nil;
    
    [_DecodeBoxQueue cancelAllOperations];
    _DecodeBoxQueue = nil;
    //停止接收码流
    //解码视频线程停止
    _h264Decoder.delegate = nil;
    _h264Decoder = nil;
    self.delegate = nil;
    
    
    //清空数据
    [self.videoDataArr removeAllObjects];
    //释放音频对象
    [_openAl stopSound];
    [_openAl stopDealloc];
    //关闭定时器
    [_heartBeatTimer setFireDate:[NSDate distantFuture]];
}

#pragma mark ------rtsp开始播放
- (void)startCloudPlayRtspWithUrl:(NSString *)url bIsEncrypt:(BOOL)encrypt Key:(NSString *)key
{
    self.bIsEncrypt = encrypt;
    self.key = key;
    
    mrts *model = self.videoAddressModel.mrts;
    // 开始获取码流(获取实时流 或者 获取录像流)
    unsigned rtspStreamId;
    void *puser = (__bridge void *)self;
    if (url.length!=0) {
        if (self.rtspStreamId > 0) {
            VmNet_StopStreamByRtsp(self.rtspStreamId);
            NSLog(@"startCloudPlayRtspWithUrl==停止了码流=======%ld",self.rtspStreamId);
            self.rtspStreamId = 0;
        }
        int startStreamInt = VmNet_StartStreamByRtsp([url cStringUsingEncoding:NSASCIIStringEncoding], rtspStreamCallBackV2, rtspStreamConnectStatusCallBackV2, puser, rtspStreamId,encrypt);
        self.rtspStreamId = rtspStreamId;
        NSLog(@"startCloudPlayRtspWithUrl:%s==打开了码流======%u startStreamInt：%d",[url cStringUsingEncoding:NSASCIIStringEncoding],rtspStreamId,startStreamInt);
        //获取码流成功
        if (startStreamInt == 0) {
            //主线程添加定时器 超时停止监控 连接成功开启新线程
            _checkTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkVideoData) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        }
        else{
            NSLog(@"获取rtsp码流失败~~");
            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
        }
    }
    else
    {
    }
}

#pragma mark ===ap模式下rtsp的播放
-(void)start_AP_backPlay_byRtspWithUrl:(NSString *)url
{
    mrts *model = self.videoAddressModel.mrts;
    // 开始获取码流(获取实时流 或者 获取录像流)
    unsigned rtspStreamId;
    void *puser = (__bridge void *)self;
    if (url.length!=0) {
        if (self.rtspStreamId>0) {
            VmNet_StopStreamByRtsp(self.rtspStreamId);
            NSLog(@"startCloudPlayRtspWithUrl【ap】==停止了码流=======%ld",self.rtspStreamId);
            self.rtspStreamId = 0;
        }
        int startStreamInt = VmNet_StartStreamByRtsp([url cStringUsingEncoding:NSASCIIStringEncoding], rtspStreamCallBackV2, rtspStreamConnectStatusCallBackV2, puser, rtspStreamId,false);
        self.rtspStreamId = rtspStreamId;
        NSLog(@"startCloudPlayRtspWithUrl【ap】:%s==打开了码流======%u startStreamInt：%d",[url cStringUsingEncoding:NSASCIIStringEncoding],rtspStreamId,startStreamInt);
        //获取码流成功
        if (startStreamInt == 0) {
            //主线程添加定时器 超时停止监控 连接成功开启新线程
            _checkTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkVideoData) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        }
        else{
            NSLog(@"ap模式下``获取rtsp码流失败~~");
            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
        }
    }
    else
    {
    }
}

#pragma mark ------rtmp开始播放【直播】
- (void)startCloudPlayRtmpWithUrl:(NSString *)url
{
    
//     void *puser = (__bridge void *)p;
//    void *puser = (void *)CFBridgingRetain(self);
       void *puser1 = (__bridge_retained void *)self;
   
    /*
    int JWRTMPReader_Connect(JWRTMPReaderHandle rtmpReaderHandle, const char *url,
                             fJWResultCallBack resultCallBack, void *user, int linkTimeout = 5);
     */
   // StrongSelf();
      const char* addr=[url UTF8String];
    //解视频队列
    self.VideoQueue = [[NSOperationQueue alloc]init];
    self.VideoQueue.maxConcurrentOperationCount = 1;
    //const char* addr = "rtmp://live.hkstv.hk.lxdns.com/live/hks";
    //const char* addr = "rtmp://hlive.yun.joyware.com/AppName/180505711009000_1?auth_key=1543218625-0-0-c80fb337ff8041b893c94994abb30d22";
    int connectSuccess = JWRTMPReader_Connect(self.RTMPhandle,addr,ResultCallBack,puser1,5);
    
    if (connectSuccess == 1) {
        NSLog(@"【直播】rtmp开始连接成功");
    }else{
        NSLog(@"【直播】rtmp开始连接失败");
    }
    /*
     int JWRTMPReader_Play(JWRTMPReaderHandle rtmpReaderHandle,
     fJWConnectStreamCallBack connectStreamCallBack,
     fJWVideoTagCallBack videoTagCallBack,
     fJWAudioTagCallBack audioTagCallBack,
     fJWFlowInfoCallBack flowInfoCallBack,
     void *user, int seekTime = 0);
     */
}
#pragma mark - rtmp 直播连接结果回调
//连接结果回调
void ResultCallBack(int32_t handle, int msg, int success, void *user)
{
    if (msg == MSG_ID_CONNECT_RESULT) {
        if (success) {
            int JWRTMPReaderSuccess = JWRTMPReader_Play(handle,rtmpStreamfJWConnectStreamCallBack,videoTagCallBack,audioTagCallBack,flowInfoCallBack,user,0);
            if (JWRTMPReaderSuccess == 1) {
                NSLog(@"【直播】rtmp开始取流成功");
            }else{
                NSLog(@"【直播】rtmp开始取流失败");
            }
        } else {
            NSLog(@"【直播】rtmp连接失败");
        }
    }
}
#pragma mark - rtmp 直播 videoTag 数据处理 回调
void videoTagCallBack(int32_t handle, const JWVideoTag *videoTag, void *user)
{
    // NSLog(@"videoTagCallBack连接回调:%d===%p====%@",handle,videoTag,user);
    ZCVideoManager *userSelf = (__bridge ZCVideoManager *)user;
    // NSLog(@"转换后的userSelf：%@ ====%@",userSelf,userSelf.h264Decoder);
    //视频数据
    LiveVideoData * liveData = [[LiveVideoData alloc]init];
    liveData.data = (char *)malloc(videoTag->dataLen);
    memcpy(liveData.data, videoTag->data, videoTag->dataLen);
   // dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //[userSelf.VideoQueue addOperationWithBlock:^{
    //NSLog(@"解码当前线程11:%@",[NSThread currentThread]);
    [userSelf.h264Decoder decodeNalu:(uint8_t *)videoTag->data withSize:(uint32_t)videoTag->dataLen];

  //  }];
   // });
}
#pragma mark - rtmp 直播 audioTag 数据处理 回调
void audioTagCallBack(int32_t handle, const JWAudioTag *audioTag, void *user)
{
    /*
     if ((__bridge ZCVideoManager*)user == NULL) {
     
     }
     */
    // NSLog(@"audioTagCallBack连接回调:%d===%d====%@",handle,audioTag,user);
    /*
     ZCVideoManager *userSelf = (__bridge ZCVideoManager *)user;
     if (userSelf.isAudioOpen) {
     [userSelf.openAl openAudioFromQueue:(uint8_t *)audioTag->data dataSize:audioTag->dataLen samplerate:8000 channels:1 bit:16];
     }
     */
}
#pragma mark - rtmp 直播 flowInfo码流连接上 数据处理 回调
void flowInfoCallBack(int32_t handle, int64_t flowBytes, int32_t byteRate, void *user)
{
    /*
     if ((__bridge ZCVideoManager*)user == NULL) {
     ZCVideoManager* v = (__bridge ZCVideoManager*)user;
     NSLog(@"flowInfoCallBack连接回调:%d===%lld====%d===%p",handle,flowBytes,byteRate, v);
     }
     */
}

#pragma mark ------rtmp停止播放【直播】
- (void)stopCloudPlayRtmp
{
    JWRTMPReader_Close(self.RTMPhandle);
    JWRTMPReader_Release(self.RTMPhandle);
    //停止定时器
    [self stopTimer];
    //跳出循环
    self.isPlay = NO;
    //播放音频线程停止
    [_AudioQueue cancelAllOperations];
    _AudioQueue = nil;
    //解码视频线程停止
    _h264Decoder.delegate = nil;
    _h264Decoder = nil;
    [_VideoQueue cancelAllOperations];
    _VideoQueue = nil;
    self.delegate = nil;//模仿新添加
    [_DecodeBoxQueue cancelAllOperations];
    _DecodeBoxQueue = nil;
    //停止接收码流
    //清空数据
    [self.videoDataArr removeAllObjects];
    //释放音频对象
    [_openAl stopSound];
    [_openAl stopDealloc];
    self.isStop = YES;
    //关闭定时器
    [_heartBeatTimer setFireDate:[NSDate distantFuture]];
}

#pragma mark ------rtsp停止播放
- (void)stopCloudPlayRtsp
{
    //停止定时器
    [self stopTimer];
    NSLog(@"【rtsp停止播放】停止码流的编号=========== %ld",self.rtspStreamId);
    if ((int)self.rtspStreamId > 0) {
        VmNet_StopStreamByRtsp((int)self.rtspStreamId);
        NSLog(@"stopCloudPlayRtsp==停止了码流=======%ld",self.rtspStreamId);
        self.rtspStreamId = 0;
        nowTime = 0;
        nowTime2 = 0;
    }
    //跳出循环
    self.isPlay = NO;
    //播放音频线程停止
    [_AudioQueue cancelAllOperations];
    _AudioQueue = nil;
    //解码视频线程停止
    _h264Decoder.delegate = nil;
    _h264Decoder = nil;
    [_VideoQueue cancelAllOperations];
    _VideoQueue = nil;
    self.delegate = nil;//模仿新添加
    [_DecodeBoxQueue cancelAllOperations];
    _DecodeBoxQueue = nil;
    //停止接收码流
    //清空数据
    [self.videoDataArr removeAllObjects];
    //释放音频对象
    [_openAl stopSound];
    [_openAl stopDealloc];
    self.isStop = YES;
    //关闭定时器
    [_heartBeatTimer setFireDate:[NSDate distantFuture]];
}

#pragma mark - 暂停播放
- (void)suspendedPlayNo
{
    [self stopCloudPlay];
}
#pragma mark - 重新播放
- (void)suspendedPlayYes
{
    if (self.streamId > 0) {
        [self stopCloudPlay];
    }
}
#pragma mark - 切换播放速度
//切换倍速播放功能
- (void)changePlayVideoFrequencyMultiple:(NSInteger)mutiple;
{
//    if (mutiple == 8) {
//        mutiple = 4;
//    }
//    if (mutiple == 1/8) {
//        mutiple = 1/4;
//    }
//   // self.decodeDisplayLink.frameInterval = 1;
//    self.decodeDisplayLink.preferredFramesPerSecond = 32;//
//    NSLog(@"改变了播放帧率，当前帧率是：【%ld】 == link:%ld",FPS * mutiple,self.decodeDisplayLink.preferredFramesPerSecond);
    
    NSLog(@"进行了倍速播放切换");
//    [_checkTimer invalidate];
//    _checkTimer = nil;
   // _checkTimer = [MSWeakTimer scheduledTimerWithTimeInterval:0.0625 /2 target:self selector:@selector(JWStreamCheckVideoData) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}


#pragma mark ------视频录制
//开始录制
-(void)startRecordWithPath:(NSString *)path fileName:(NSString *)filename;
{
    //原本这个方法，后来，不用filename了，就改为下面的方法，这个方法暂时留存
    /*
    _VideoRecQueue = [[NSOperationQueue alloc]init];
    _VideoRecQueue.maxConcurrentOperationCount = 1;
//    _AudioRecQueue = [[NSOperationQueue alloc]init];
//    _AudioRecQueue.maxConcurrentOperationCount = 1;
    self.audioRecDataArr = [NSMutableArray array];
    self.videoFps = 0;
    self.audioFps = 0;
    _isStartRecord = YES;
    //NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie22222.mov"];
    NSString *pathStr = [NSString stringWithFormat:@"/Documents/%@/video",path];
    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:pathStr];

    NSString *videoPathStr = [NSString stringWithFormat:@"%@/%@.mp4",betaCompressionDirectory,filename];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //1、拼接目录
    [fileManager changeCurrentDirectoryPath:videoPathStr];
    NSLog(@"【视频录制】拼接目录111%@",videoPathStr);
    [fileManager createDirectoryAtPath:betaCompressionDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    unlink([videoPathStr UTF8String]);
    int channels = 1;//音频通道
    Float64 samplerate = 8000;//音频采样率
    self.recordEncoder = [WCLRecordEncoder encoderForPath:videoPathStr Height:_videoWidth width:_videoHeight channels:channels samples:samplerate];
     */
}


//新的开始录制
-(void)startRecordWithPath:(NSString *)path;
{
    _VideoRecQueue = [[NSOperationQueue alloc]init];
    _VideoRecQueue.maxConcurrentOperationCount = 1;
    _AudioRecQueue = [[NSOperationQueue alloc]init];
    _AudioRecQueue.maxConcurrentOperationCount = 1;
    self.audioRecDataArr = [NSMutableArray array];
    self.videoFps = 0;
    self.audioFps = 0;
    _isStartRecord = YES;
    NSString *videoPathStr = [NSString stringWithFormat:@"%@.mp4",path];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //1、拼接目录
    [fileManager changeCurrentDirectoryPath:videoPathStr];
    NSLog(@"【视频录制】拼接目录222%@",videoPathStr);
    [fileManager createDirectoryAtPath:videoPathStr withIntermediateDirectories:YES attributes:nil error:nil];
    unlink([videoPathStr UTF8String]);
    int channels = 1;//音频通道
    Float64 samplerate = 8000;//音频采样率
     if (_videoWidth && _videoHeight) {
          self.recordEncoder = [WCLRecordEncoder encoderForPath:videoPathStr Height:_videoWidth width:_videoHeight channels:channels samples:samplerate];
     }
    
}


//停止录制
- (void)stopRecord
{
    [_VideoRecQueue cancelAllOperations];
    _VideoRecQueue = nil;
    [_AudioRecQueue cancelAllOperations];
    _AudioRecQueue = nil;
    _isStartRecord = NO;
    _isRecordAudio = NO;
  
    [self.recordEncoder finishWithCompletionHandler:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(stopRecordBlockFunc)]) {
            [self.delegate stopRecordBlockFunc];
        }
    }];
    self.videoFps = 0;
    self.audioFps = 0;
}

#pragma mark ------云台控制
- (void)beginControlType:(unsigned)type Parm1:(unsigned)parm1 Parm2:(unsigned)parm2
{
    if (self.videoModel == nil) {
        return;
    }else{
        if (self.isStep) {
            VmNet_SendControl([self.videoModel.sFdId cStringUsingEncoding:NSASCIIStringEncoding], self.videoModel.nChannelId, type, parm1, parm2);
        }
    }
}

- (void)dealloc
{
    NSLog(@"zcvideodealloc");
  // [self stopCloudPlay];
}
@end
