//
//  ZWPlayerManage.m
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "JWPlayerManage.h"
#import "JWVideoAddressInfo.h"
#import "ZCVideoManager.h"
#import "HeadClass.h"
#import "JWConstants.h"
#import "JWPlayView.h"
#import "HDNetworking.h"
#import "JWDeviceRecordFileList.h"
#import "JWAudioAddressInfo.h"
#import "AudioRecord.h"

#import "libt2u.h"

#import "APModel.h"
#import "wifiInfoManager.h"

#import "PPCS_API.h"


#ifndef weakify
#define weakify(o) __typeof__(o) __weak o##__weak_ = o;
#define strongify(o) __typeof__(o##__weak_) __strong o =    o##__weak_;
#endif

#define MaxSCale 6.0  //最大缩放比例
#define MinScale 1.0  //最小缩放比例

#define queryEndTime_list_alarm 86399
#define queryEndTime_list_record 86399
#define queryEndTime_video 86399
CHAR _InitString[256] = {0};   // Save InitString

@interface JWPlayerManage ()<ZCVideoManageDelegate>
///解码管理者
@property (nonatomic,strong)ZCVideoManager *videoManager;
///录音对讲管理者
@property (nonatomic,strong)AudioRecord *audioRecordManager;
///视频地址、端口
@property (nonatomic,strong)JWVideoAddressInfo *jwVideoAddressInfo;
///播放的view
@property (nonatomic,strong)JWPlayView *playView;
//记录声音开关
@property (nonatomic,assign)BOOL isAudioOpen;

///token
@property (nonatomic,copy)NSString *token;
///userid
@property (nonatomic,copy)NSString *userId;
///DevidId
@property (nonatomic,copy)NSString *deviceId;
///cannelNO
@property (nonatomic,assign)NSInteger cannelNo;
///channelCode
@property (nonatomic,copy)NSString *channelCode;
//缩放比例
@property (nonatomic,assign) CGFloat lastScale;

//p2pret
@property (nonatomic,assign)int p2pRet;
//播放id
@property (nonatomic,copy)NSString *monitor_idStr;

@property (nonatomic,strong)dispatch_queue_t que_port_status_Queue;

@property(nonatomic, strong) NSDictionary* foldInfoDic;// Save TextField Info 【p2p】
@property (nonatomic , strong)NSArray *dataArray;
@end
@implementation JWPlayerManage
{
    NSString * APIVersionString;//用来ppcs打印
}

//视频解码管理者
- (ZCVideoManager *)videoManager
{
    if (!_videoManager) {
        _videoManager = [[ZCVideoManager alloc]init];
        _videoManager.delegate = self;
        _videoManager.isAudioOpen = _isAudioOpen;
    }
    return _videoManager;
}

//录音对讲管理者
- (AudioRecord *)audioRecordManager
{
    if (!_audioRecordManager) {
        _audioRecordManager = [[AudioRecord alloc]init];
    }
    return _audioRecordManager;
}

/**
 *  @since 1.0.0
 *  播放管理类初始化
 */
- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
//        BOOL isInit = VmNet_Init(16);
//        self.videoManager = [[ZCVideoManager alloc]init];
//        self.videoManager.delegate = self;
        self.token = token;
  
    }
    return self;
}

//查询p2p接口是否通 的线程
- (dispatch_queue_t)que_port_status_Queue
{
    if (!_que_port_status_Queue) {
        _que_port_status_Queue = dispatch_queue_create("que_port_status_Queue", NULL);
    }
    return _que_port_status_Queue;
}

- (instancetype)initWithToken:(NSString *)token
                       userId:(NSString *)userId
                     deviceId:(NSString *)deviceId
                     cannelNo:(NSInteger)cannelNo
{
    self = [super init];
    if (self) {
//        self.videoManager = [[ZCVideoManager alloc]init];
//        self.videoManager.delegate = self;
        self.token = token;
        self.userId = userId;
        self.deviceId = deviceId;
        self.cannelNo = cannelNo;
        NSLog(@"通道:%ld",(long)cannelNo);
        //video停止播放 让audiomanage播放打开
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioManagerIsOpenYes:) name:VIDEOISSTOP object:nil];
    }
    return self;
}

/**
 * @brief JWplayerManage 含通道的初始化
 */
- (instancetype)initWithToken:(NSString *)token
                       userId:(NSString *)userId
                       deviceId:(NSString *)deviceId
                       chanId:(NSInteger)chanId
                       chanCode:(NSString *)chanCode
{
     self = [super init];
        if (self) {
            self.token = token;
            self.userId = userId;
            self.deviceId = deviceId;
            self.cannelNo = chanId;
            self.channelCode = chanCode;
            NSLog(@"通道模式通道:%ld==%@",(long)chanId,chanCode);
            //video停止播放 让audiomanage播放打开
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioManagerIsOpenYes:) name:VIDEOISSTOP object:nil];
        }
        return self;
}

/**
 *  设置播放器的view
 *
 *  @param playerView 播放器view
 */
- (void)JWPlayerManageSetPlayerView:(UIView *)playerView
{
    self.lastScale = 1.0;
    CGRect glPlayViewFrame = playerView.bounds;
    JWPlayView *playView = [JWPlayView viewFromXib];
    playView.frame =glPlayViewFrame;
    [playView.openView setupGL];
    playView.clipsToBounds = YES;
    
    /*
    //p2p开始
    t2u_init("nat.vveye.net", 8000, NULL);//在刚开始就初始化这个
    
    //p2p替换新sdk 标记
    //步骤  1
    int gAPIVer = PPCS_GetAPIVersion();//获取当前正在使用的P2P API的版本号并打 印输出版本号信息到终端显示。
    
    APIVersionString = [[NSString alloc] initWithFormat:@"PPCS_API Version: %d.%d.%d.%d\n",
                        (gAPIVer & 0xFF000000)>>24,
                        (gAPIVer & 0x00FF0000)>>16,
                        (gAPIVer & 0x0000FF00)>>8,
                        (gAPIVer & 0x000000FF) >>0];
    printf("%s", [APIVersionString UTF8String]);
*/
    

    //添加缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [playView.openView addGestureRecognizer:pinch];
    
    //捏合手势
    UIPanGestureRecognizer *recognizer = [[ UIPanGestureRecognizer alloc] initWithTarget: self action: @selector (handleSwipe:)];
    [playView.openView addGestureRecognizer:recognizer];
    [playerView addSubview:playView];
    _playView = playView;
    CGRect newRect1 = [self.playView convertRect:self.playView.bounds toView:self.playView.openView];
    CGRect openRect = self.playView.openView.frame;
}

/**
 *  设置播放器声音开关
 *
 *  @param isOpen 播放器view
 */
- (void)JWPlayerManageSetAudioIsOpen:(BOOL)isOpen
{
    self.isAudioOpen = isOpen;
    self.videoManager.isAudioOpen = isOpen;
}
/**
 *  获取播放器播放状态
 *
 *  返回播放状态
 */

- (BOOL)JWPlayerManageGetPlayState
{
    if (self.videoManager.isStop)
    {
        NSLog(@"获取视频状态--停止播放");
        return NO;
    }
    else
    {
        NSLog(@"获取视频状态--正在播放");
        return YES;
    }
}

/**
 *  @since 用【JWStream】接口
 *  根据设备id打开播放接口
 *
 *  @param videoType   视频类型
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWStreamPlayerManagePlayVideoWithVideoType:(JWVideoTypeStatus)videoType BIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsAP:(BOOL)bIsAp completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //视频格式
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];
    //通道
    if (self.cannelNo == 0) {
        self.cannelNo = 1;
    }
//    NSLog(@"通道2:%ld",self.cannelNo);
    NSLog(@"我是走这里嘛？？？：%@",postDic);
    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:videoTypeNum forKey:@"video_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];

    self.videoManager.isStop = NO;
    [self JWStreamPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:NO P2pInfoDic:nil BIsAP:NO completionBlock:completionBlock];

    return [ZCNetWorking shareInstance].operationQueue;
}

//JWStream 接口调用【使用中】
- (void)JWStreamPlayWithDic:(NSMutableDictionary *)postDic BIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsRtsp:(BOOL)bIsRtsp P2pInfoDic:(NSDictionary *)p2pInfoDic BIsAP:(BOOL)bIsAp completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{

    weakify(self);
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
        [postDic setObject:[NSNumber numberWithInteger:model.chanId] forKey:@"chan_id"];
    }
    //多一个server_ip字段
    NSUserDefaults *ipDefault = [NSUserDefaults standardUserDefaults];
    NSString *ipStr = [ipDefault objectForKey:CURRENT_IP_KEY];
    [postDic setObject:ipStr forKey:@"server_ip"];
   
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/play" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return;
        int ret = [responseObject[@"ret"]intValue];
         NSLog(@"单纯一个设备进入ret:%d===responseObject:%@~~~postDic:%@",ret,responseObject,postDic);
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:1.0] forKey:@"SpeedValue"];
        
        if (ret == 0) {
            JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
            self.videoManager.videoAddressModel = videoAddressInfo;
            
            if (!bIsRtsp) {
                NSString *dev_id = [NSString isNullToString:self.deviceId];  //设备id
                [self.videoManager JWStreamStartBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:NO DeviceId:dev_id bIsCenterPalyType:NO];//还要修改
            }else{
                if (bIsEncrypt) {//加密：自己的；不加密：海康的，sub，子码
//                    if (p2pInfoDic) {
//                        NSString * ownUrl =     [NSString stringWithFormat:@"rtsp://%@:%@@127.0.0.1:%@/h264/ch1/main/av_stream/",self.deviceId,key,p2pInfoDic[@"port"]];
//                        [self.videoManager startCloudPlayRtspWithUrl:ownUrl bIsEncrypt:bIsEncrypt Key:key];
//                    }
                }else{
//                    if (p2pInfoDic) {
//                        NSString * haikangUrl = [NSString stringWithFormat:@"rtsp://admin:%@@127.0.0.1:%@/h264/ch1/main/av_stream/",p2pInfoDic[@"devpass"],p2pInfoDic[@"port"]];
//                        [self.videoManager startCloudPlayRtspWithUrl:haikangUrl bIsEncrypt:bIsEncrypt Key:key];
//                    }
                }
            }
            //[self.videoManager startCloudPlayRtspWithUrl:@"rtsp://admin:abcd1234@192.168.3.38:554/h264/ch1/main/av_stream/" bIsEncrypt:bIsEncrypt];
            
            completionBlock(JW_SUCCESS);
        }else{
            if (ret == 1301) {
                completionBlock(JW_PLAY_NO_PERMISSION);
            }else
            {
                completionBlock(JW_FAILD);
            }
        }
    } failure:^(NSError * _Nonnull error) {
//        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
    }];
}

/**
 @brief 【实时rtp】JWStream 播放关闭接口
 @param completionBlock 回调
 @return 成功或失败
 */
- (NSOperationQueue *)JWStreamPlayerManageEndPlayLiveVideoIsStop:(BOOL)stop CompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSString *monitor_idStr = @"";
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];

    //playid
    JWVideoAddressInfo *addressInfo = self.videoManager.videoAddressModel;
    monitor_idStr = [addressInfo.monitor_id mutableCopy];
    
    [self.videoManager JWStreamStopCloudPlayRtpHandle:addressInfo.handle];
    _videoManager.delegate = nil;
    _videoManager = nil;
    
    NSLog(@"用了停止码流的monitor_idStr：%@",monitor_idStr);
    if (stop) {
        NSLog(@"停止保留最后一帧");
    }else{
        [self.playView.openView cleanBackColor];
    }
    if (monitor_idStr.length > 0) {
        [postDic setObject:monitor_idStr forKey:@"monitor_id"];
        weakify(self);
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/stopplay" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            strongify(self);
            NSLog(@"【JWStream】用了停止码流的monitor_idStr 3：%@",monitor_idStr);
            if (!self__weak_) return ;
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0) {
                completionBlock(JW_SUCCESS);
            }else{
                completionBlock(JW_FAILD);
            }
        } failure:^(NSError * _Nonnull error) {
            strongify(self);
            if (!self__weak_) return ;
            completionBlock(JW_FAILD);
        }];
    }else{
        completionBlock(JW_FAILD);
    }
    return [ZCNetWorking shareInstance].operationQueue;
}


/**
 调整码率接口

 @param videoType 码率
 @param completionBlock 回调
 @return queue
 */
- (NSOperationQueue *)JWPlayerManageChangePlayVideoVideoType:(JWVideoTypeStatus)videoType completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //视频格式
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];
    //通道
    if (self.cannelNo == 0) {
        self.cannelNo = 1;
    }
    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:videoTypeNum forKey:@"video_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];
    
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
        [postDic setObject:[NSNumber numberWithInteger:model.chanId] forKey:@"chan_id"];
    }
    weakify(self);
#warning 注意事项如下
    /**
     注释：这里本不应该用 @"v1/media/play" 这个播放接口来设置主子码，这个问题和项目经理反应过了，会对后台造成性能浪费。但是暂时用这个接口，后期会改。改了，就删除这个注释。
     这里，调用接口之后，不用再起解码操作。
     */
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/play" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        if (!self__weak_) return;
        int ret = [responseObject[@"ret"]intValue];
//         NSLog(@"ret:%d===responseObject:%@",ret,responseObject);
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:1.0] forKey:@"SpeedValue"];
        if (ret == 0) {
            completionBlock(JW_SUCCESS);
        }else{
            if (ret == 1301) {
                completionBlock(JW_PLAY_NO_PERMISSION);
            }else
            {
                completionBlock(JW_FAILD);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        completionBlock(JW_FAILD);
    }];

    return [ZCNetWorking shareInstance].operationQueue;
}


/**
 *  @since 1.0.0
 *  根据设备id打开播放接口
 *
 *  @param videoType   视频类型
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageBeginPlayVideoWithVideoType:(JWVideoTypeStatus)videoType BIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsAP:(BOOL)bIsAp completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //视频格式
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];
    //通道
    if (self.cannelNo == 0) {
        self.cannelNo = 1;
    }
    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:videoTypeNum forKey:@"video_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];
    
    NSLog(@"NT4:%@",postDic);
    
    weakify(self);
#warning new p2p SDK
    // 打开p2p播放速度
    /*
    _dataArray = @[@"DID",@"InitString",@"Mode",@"Repeat",@"DelaySec",@"WakeupKey",@"IP1",@"IP2",@"IP3"];
    _foldInfoDic = [NSMutableDictionary dictionary];
    for (NSString *obj in _dataArray) {
        [_foldInfoDic setValue:@"" forKey:obj];
    }
    
    NSString *AlertStr = [NSMutableString string];
    [_foldInfoDic setValue:@"PPCS-016871-MFCUD" forKey:@"DID"];
    [_foldInfoDic setValue:@"EBGAEIBIKHJJGFJKEOGCFAEPHPMAHONDGJFPBKCPAJJMLFKBDBAGCJPBGOLKIKLKAJMJKFDOOFMOBECEJIMM" forKey:@"InitString"];
    [_foldInfoDic setValue:@"1" forKey:@"Mode"];
    
    BOOL NullDID = [_foldInfoDic[@"DID"] isEqualToString: @""];
    BOOL NullInitString = [_foldInfoDic[@"InitString"] isEqualToString: @""];
    BOOL NullMode = [_foldInfoDic[@"Mode"] isEqualToString: @""];
    if (NullDID) {
        AlertStr = @"DID";
    }
    if (NullInitString) {
        if ([AlertStr isEqualToString:@""]) {
            AlertStr = @"InitString";
        }else{
            AlertStr = [NSString stringWithFormat:@"%@,InitString",AlertStr];
        }
    }
    if (NullMode) {
        if ([AlertStr isEqualToString:@""]) {
            AlertStr = @"Mode";
        }else{
            AlertStr = [NSString stringWithFormat:@"%@,Mode",AlertStr];
        }
    }
    
    int ret;
    //步骤  2
    ret = PPCS_Initialize(_InitString);//添加InitString字符串进行初始化，如果InitString信 息错误，将会返回负数值并打印输出错误信息到终端显示后退出程序。
    
    
    // 3. Network Detect
    st_PPCS_NetInfo NetInfo;
    //步骤 3
    ret = PPCS_NetworkDetect(&NetInfo, 0);//对当前网络进行侦测以及和服务器进行连 接测试，侦测结果打印输出到终端显示

    */

#warning ------hksdk
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/playp2p" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        if (!self__weak_) return ;
        NSLog(@"P2PPlay：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            //以下
            
            //播放id
            NSString *monitor_idStr = responseObject[@"body"][@"monitor_id"];
            //p2p信息
            NSString *p2pStr = responseObject[@"body"][@"p2p_info"];
            //根据,分割
            NSArray *p2pInfoArr = [p2pStr componentsSeparatedByString:@","];
            NSString *p2pid = p2pInfoArr[0];
            NSString *p2pPass = p2pInfoArr[1];
            NSString *devpass = p2pInfoArr[2];
            /*
            //p2p开始
            t2u_init("nat.vveye.net", 8000, NULL);//放在init里面。
            */
/*
            //添加映射端口 >0 映射到本地的端口 -1 失败本地端口被占用
            int port =  t2u_add_port([p2pid UTF8String], 8000, 0);
            NSLog(@"ret1=添加映射端口 >0 映射到本地的端口 -1 失败本地端口被占用===%d",port);
            
            NSDictionary * p2pInfoDic = @{@"port":[NSNumber numberWithInt:port],@"devpass":devpass};

            if (port==-1) {
                // [self platformPlayWithDic:postDic completionBlock:completionBlock];
                //[self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic completionBlock:completionBlock];
                return;
            }
            */
            /*
            //查询与服务器连接状态 1 连接正常 0 未连接 -1 sdk未初始化 -2 服务器秘钥无效
            int num1 = t2u_status();
            if (num1!=1) {
                //[self platformPlayWithDic:postDic completionBlock:completionBlock];
                //[self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic completionBlock:completionBlock];
                return;
            }
            NSLog(@"查询与服务器连接状态：%d",num1);
            //设备状态 1在线 0 不在线 —1 查询失败
            int ret =  t2u_query([p2pid UTF8String]);
             NSLog(@"设备是否在线：%d",ret);
            if (ret!=1) {
                //[self platformPlayWithDic:postDic completionBlock:completionBlock];
               // [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic completionBlock:completionBlock];
                return;
            }
            //添加映射端口 >0 映射到本地的端口 -1 失败本地端口被占用
            int port =  t2u_add_port([p2pid UTF8String], 8000, 0);
             NSLog(@"端口是否大于0：%d",port);
            NSDictionary * p2pInfoDic = @{@"port":[NSNumber numberWithInt:port],@"devpass":devpass};
            */
//            if (port==-1) {
//               // [self platformPlayWithDic:postDic completionBlock:completionBlock];
//                //[self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic completionBlock:completionBlock];
//                return;
//            }
            WS(weakSelf);
//            dispatch_async(weakSelf.que_port_status_Queue, ^{
//                //查询映射端口状态 1 已联通 0 未联通 -1 失败端口不存在 -2 p2p连接失败等待30秒自动连接 -3 中断 等待30秒 -4 对方离线 等待30秒  -5 设备有密码认证失败
//                int ret2;
//                ret2 = t2u_port_status(port,NULL);
//                int count = 0;
//                while (ret2 != 1) {
//                    ret2 = t2u_port_status(port,NULL);
//                    count ++;
//                    NSLog(@"count:%d",count);
//                    if (count > 3000) {
//                        break;
//                    }
//                }
//                NSLog(@"查询映射端口是否成功：%d",ret2);
//                if (ret2 == 1) {
//                    //都连接成功了赋值Ret
//                    self.p2pRet = port;
////                    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
////                    deviceInfo.chDeviceAddr = devpass;
////                    deviceInfo.nDevicePort = port;
////                    deviceInfo.chLoginName = p2pid;
////                    deviceInfo.chPassWord = p2pPass;
//                    [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic BIsAP:NO completionBlock:completionBlock];
//                    return;
//                }
//                else{
//                    //[self platformPlayWithDic:postDic completionBlock:completionBlock];
//                    // [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic completionBlock:completionBlock];
//
//                    return;
//                }
//            });

            //以上
            
            
            //  [self platformPlayWithDic:postDic completionBlock:completionBlock];
            
            [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:NO P2pInfoDic:nil BIsAP:NO completionBlock:completionBlock];
        }
        else{//这里就是判断ret ！= 0
            //原本这里是直接网络请求播放，这边要加入设备的软ap，rtsp流播放
            if (bIsAp) {
                [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:nil BIsAP:YES completionBlock:completionBlock];
            }else{
                [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:NO P2pInfoDic:nil BIsAP:NO completionBlock:completionBlock];
//                [self JWStreamPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:NO P2pInfoDic:nil BIsAP:NO completionBlock:completionBlock];//todo
            }
        }

    } failure:^(NSError * _Nonnull error) {
        //原本这里是直接网络请求播放，这边要加入设备的软ap，rtsp流播放
        if (bIsAp) {
            [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:nil BIsAP:YES completionBlock:completionBlock];
        }else{
            [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:NO P2pInfoDic:nil BIsAP:NO completionBlock:completionBlock];
        }
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}


- (void)platformPlayWithDic:(NSMutableDictionary *)postDic BIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsRtsp:(BOOL)bIsRtsp P2pInfoDic:(NSDictionary *)p2pInfoDic BIsAP:(BOOL)bIsAp completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSLog(@"播放NT4需要的postDic:%@~~~",postDic);
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
        [postDic setObject:[NSNumber numberWithInteger:model.chanId] forKey:@"chan_id"];
    }
    
    if (bIsAp) {
        /**
         这里是设备 软ap模式下的rtsp流播放。
         ***/
        //rtsp://admin:abcd1234@192.168.1.1:554/Stream/Live/101/track=1
        //NSString * ownUrl = [NSString stringWithFormat:@"rtsp://%@:%@@127.0.0.1:%@/h264/ch1/main/av_stream/",self.deviceId,key,p2pInfoDic[@"port"]];
        /*TODO
        NSString * ownUrl = @"rtsp://admin:abcd1234@192.168.1.1:554/Stream/Live/101/track=1";//:554/Stream/Live/101/track=1
        [self.videoManager startCloudPlayRtspWithUrl:ownUrl bIsEncrypt:bIsEncrypt Key:key];
         */
    }
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/play" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return;
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"NT4通道进入:ret:%d===responseObject:%@",ret,responseObject);
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:1.0] forKey:@"SpeedValue"];

        if (ret == 0 ) {
            JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
            self.videoManager.videoAddressModel = videoAddressInfo;
            
            
            if (!bIsRtsp) {
                NSString *dev_id = [NSString isNullToString:self.deviceId];  //设备id
                [self.videoManager startCloudPlayBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:NO DeviceId:dev_id bIsCenterPalyType:NO];//还要修改
                
//                [self.videoManager JWStreamStartBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:NO DeviceId:dev_id bIsCenterPalyType:NO];
                
            }else{
                if (bIsEncrypt) {//加密：自己的；不加密：海康的，sub，子码
                    if (p2pInfoDic) {
                        NSString * ownUrl =	 [NSString stringWithFormat:@"rtsp://%@:%@@127.0.0.1:%@/h264/ch1/main/av_stream/",self.deviceId,key,p2pInfoDic[@"port"]];
                        [self.videoManager startCloudPlayRtspWithUrl:ownUrl bIsEncrypt:bIsEncrypt Key:key];
                    }
                }else{
                    if (p2pInfoDic) {
                        NSString * haikangUrl = [NSString stringWithFormat:@"rtsp://admin:%@@127.0.0.1:%@/h264/ch1/main/av_stream/",p2pInfoDic[@"devpass"],p2pInfoDic[@"port"]];
                        [self.videoManager startCloudPlayRtspWithUrl:haikangUrl bIsEncrypt:bIsEncrypt Key:key];
                    }
                }
            }
            
            //[self.videoManager startCloudPlayRtspWithUrl:@"rtsp://admin:abcd1234@192.168.3.38:554/h264/ch1/main/av_stream/" bIsEncrypt:bIsEncrypt];
            
            completionBlock(JW_SUCCESS);
        }else{
            if (ret == 1301) {
                completionBlock(JW_PLAY_NO_PERMISSION);
            }else
            {
                completionBlock(JW_FAILD);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
    }];
}
/*
- (void)ceshiP2P{
    
    //p2p替换新sdk 标记
    //步骤  1
    int gAPIVer = PPCS_GetAPIVersion();//获取当前正在使用的P2P API的版本号并打 印输出版本号信息到终端显示。
    
    APIVersionString = [[NSString alloc] initWithFormat:@"PPCS_API Version: %d.%d.%d.%d\n",
                        (gAPIVer & 0xFF000000)>>24,
                        (gAPIVer & 0x00FF0000)>>16,
                        (gAPIVer & 0x0000FF00)>>8,
                        (gAPIVer & 0x000000FF) >>0];
    printf("%s", [APIVersionString UTF8String]);
    
    
    t2u_init("nat.vveye.net", 8000, NULL);
    //    int num = t2u_search(NULL, 1024);
    //    NSLog(@"%d",num);
    //查询与服务器连接状态 1 连接正常 0 未连接 -1 sdk未初始化 -2 服务器秘钥无效
    int num1 = t2u_status();
    NSLog(@"%d",num1);
    
    
    
    //设备状态 1在线 0 不在线 —1 查询失败
    int ret =  t2u_query("JWTEST730001762");
    NSLog(@"%d",ret);
    
    
    //添加映射端口 >0 映射到本地的端口 -1 失败本地端口被占用
    int ret1 =  t2u_add_port("JWTEST730001762", 8000, 0);
    NSLog(@"%d",ret1);
    
    
    //查询映射端口状态 1 已联通 0 未联通 -1 失败端口不存在 -2 p2p连接失败等待30秒自动连接 -3 中断 等待30秒 -4 对方离线 等待30秒  -5 设备有密码认证失败

        int ret2 = t2u_port_status(ret1,NULL);
        NSLog(@"%d",ret2);
        if (ret2 == 1) {
        }

    //删除端口
    t2u_del_port(ret1);
    //退出
    t2u_exit();
}
 */
/**
 *  @since 1.0.0
 *  根据播放管理者关闭播放接口【实时】
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageEndPlayVideoWithBIsStop:(BOOL)stop CompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
   // [[HDNetworking sharedHDNetworking]canleAllHttp];
    NSString *monitor_idStr = @"";
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
//
//    if (self.p2pRet>0) {
//        NSLog(@"删除p2p端口");
//        monitor_idStr = self.monitor_idStr;
//        //删除端口
//        t2u_del_port(self.p2pRet);
//        //退出
//        t2u_exit();
//        [_videoManager stopCloudPlayRtsp];//新添加
//    }else{
//        //playid
//        JWVideoAddressInfo *addressInfo = self.videoManager.videoAddressModel;
//        monitor_idStr = [addressInfo.monitor_id mutableCopy];
//        //停止播放
//        _videoManager.delegate = nil;
//        [_videoManager stopCloudPlay];
//        [_videoManager stopCloudPlayRtsp];
//        _videoManager = nil;
//    }
    
    //playid
    JWVideoAddressInfo *addressInfo = self.videoManager.videoAddressModel;
    monitor_idStr = [addressInfo.monitor_id mutableCopy];
    //停止播放
    _videoManager.delegate = nil;
    [_videoManager stopCloudPlay];
    [_videoManager stopCloudPlayRtsp];
    _videoManager = nil;
    
    NSLog(@"用了停止码流的monitor_idStr：%@",monitor_idStr);
    if (stop) {
        NSLog(@"停止保留最后一帧");
    }else{
        [self.playView.openView cleanBackColor];
    }
    if (monitor_idStr.length > 0) {
        [postDic setObject:monitor_idStr forKey:@"monitor_id"];
        weakify(self);
         NSLog(@"用了停止码流的monitor_idStr 2：%@",monitor_idStr);
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/stopplay" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            strongify(self);
             NSLog(@"用了停止码流的monitor_idStr 3：%@",monitor_idStr);
            if (!self__weak_) return ;
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0 ) {
                completionBlock(JW_SUCCESS);
            }else{
                completionBlock(JW_FAILD);
            }
        } failure:^(NSError * _Nonnull error) {
            strongify(self);
            if (!self__weak_) return ;
            completionBlock(JW_FAILD);
        }];
    }else{
        completionBlock(JW_FAILD);
    }
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 *  @since 1.0.0
 *  根据url打开播放接口
 *   @param url 地址
 *  @param videoType   视频类型
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageBeginPlayVideoWithUrl:(NSString *)url VideoType:(JWVideoTypeStatus)videoType bIsEncrypt:(BOOL)encrypt
                                          completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //视频格式
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];
    //通道
    if (self.cannelNo == 0) {
        self.cannelNo = 1;
    }
    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:videoTypeNum forKey:@"video_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
        [postDic setObject:[NSNumber numberWithInteger:model.chanId] forKey:@"chan_id"];
    }
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/play" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
            self.videoManager.videoAddressModel = videoAddressInfo;
            
#warning 警告，这里不知道为什么还要调用。key暂时先填写nil
            [self.videoManager startCloudPlayRtspWithUrl:url bIsEncrypt:encrypt Key:nil];
            completionBlock(JW_SUCCESS);
        }else{
            if (ret == 1301) {
                completionBlock(JW_PLAY_NO_PERMISSION);
            }else
            {
                completionBlock(JW_FAILD);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 *  @since 1.0.0
 *  根据url打开播放接口 【直播新增】
 *   @param url 地址
 *  @param videoType   视频类型
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageBeginPlayLiveVideoWithUrl:(NSString *)url
                                          completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    self.videoManager.isStop = NO;//不知道正常播放在哪里设置的，这里先在这边设置。
    [self.videoManager startCloudPlayRtmpWithUrl:url];
    completionBlock(JW_SUCCESS);
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 直播播放关闭接口

 @param completionBlock 回调
 @return 成功或失败
 */
- (NSOperationQueue *)JWPlayerManageEndPlayLiveVideoCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    [self.videoManager stopCloudPlayRtmp];
    _videoManager = nil;
    [self.playView.openView cleanBackColor];
    
     return [ZCNetWorking shareInstance].operationQueue;
}

/**
 *  @since 1.0.0
 *  根据URL播放管理者关闭播放接口
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageEndPlayVideoWithURLCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
   // [[HDNetworking sharedHDNetworking]canleAllHttp];
    NSString *monitor_idStr;
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
        //playid
        JWVideoAddressInfo *addressInfo = self.videoManager.videoAddressModel;
        monitor_idStr = addressInfo.monitor_id;
        //停止播放
        [_videoManager stopCloudPlayRtsp];
        _videoManager = nil;

    [self.playView.openView cleanBackColor];
    //网络请求
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    if (monitor_idStr.length>0) {
        [postDic setObject:monitor_idStr forKey:@"monitor_id"];
        weakify(self);
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/stopplay" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            strongify(self);
            if (!self__weak_) return ;
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0 ) {
                completionBlock(JW_SUCCESS);
            }else{
                completionBlock(JW_FAILD);
            }
        } failure:^(NSError * _Nonnull error) {
            strongify(self);
            if (!self__weak_) return ;
            completionBlock(JW_FAILD);
        }];
    }else{
        completionBlock(JW_FAILD);
    }
    
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 *  @since 1.0.0
 *  根据设备id查询录像播放接口
 *  @param deviceId 设备id
 *  @param recVideoType   录像视频类型
 *  @param beginTime   开始时间
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考JWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)searchRecordVideoWithDevidId:(NSString *)deviceId
                                      recVideoType:(JWRecVideoTypeStatus)recVideoType
                                         beginTime:(NSDate *)beginTime
                                   completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock
{
//    [[HDNetworking sharedHDNetworking]canleAllHttp];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //录像类型
    NSNumber *recVideoTypeNum;
    if (recVideoType == JWRecVideoTypeStatusCenter) {
        recVideoTypeNum = [NSNumber numberWithInteger:0];
    }else
    {
        recVideoTypeNum = [NSNumber numberWithInteger:1];
    }
    
    //通道
    if (self.cannelNo == 0) {
        self.cannelNo = 1;
    }
    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    //开始时间
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[beginTime timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
    NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
    int endTimeInt = beginTimeInt + queryEndTime_list_record;
    NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
    
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:recVideoTypeNum forKey:@"rec_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];
    [postDic setObject:beginNum forKey:@"s_date"];
    [postDic setObject:endNum forKey:@"s_date_end"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
    }
    NSLog(@"录像回放时进的这吧：%@",postDic);
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWDeviceRecordFileList *jwDeviceRecordFileList = [JWDeviceRecordFileList mj_objectWithKeyValues:responseObject[@"body"]];
            if (jwDeviceRecordFileList.his_recs.count > 0) {
                completionBlock(jwDeviceRecordFileList.his_recs,JW_SUCCESS_SEARCH_VIDEO_LIST);
//                NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
//                //设备id
//                NSString *dev_id = [NSString isNullToString:self.deviceId];
//                //令牌
//                NSString *access_token = [NSString isNullToString:self.token];
//                //视频格式
//                NSNumber *videoTypeNum = [NSNumber numberWithInteger:recVideoType];
//                //开始时间
//                NSString *startDateStr = [NSString stringWithFormat:@"%ld", (long)[beginTime timeIntervalSince1970]];
//                int beginTimeInt = [startDateStr intValue];
//                NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
//                int endTimeInt = beginTimeInt + queryEndTime_video;//结束时间
//                NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
//                [postDic setObject:dev_id forKey:@"dev_id"];
//                [postDic setObject:access_token forKey:@"access_token"];
//                [postDic setObject:videoTypeNum forKey:@"rec_type"];
//                [postDic setObject:beginNum forKey:@"start_time"];
//                [postDic setObject:endNum forKey:@"stop_time"];
                NSLog(@"ZZZZZZ 报警录像回放请求：%@===%@",postDic,responseObject);
                //这里因为之前是要请求完就播放，现在不需要，所以接口里面也注释该部分。
                /*
                 weakify(self);
                [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
                    strongify(self);
                    if (!self__weak_) return ;
                    int ret = [responseObject[@"ret"]intValue];
                    if (ret == 0) {
                        JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
                        self.videoManager.videoAddressModel = videoAddressInfo;
                    }else{//v1/media/record/playback请求 ，返回 ret != 0 的情况
                        if (ret == 1401) {
                            completionBlock(jwDeviceRecordFileList.his_recs,JW_PLAYBACK_NO_PERMISSION);
                        }else
                        {
                            completionBlock(jwDeviceRecordFileList.his_recs,JW_FAILD);////JW_FAILD_SEARCH_VIDEO_LIST
                        }
                    }
                } failure:^(NSError * _Nonnull error) {
                    completionBlock(jwDeviceRecordFileList.his_recs,JW_FAILD);
                    strongify(self);
                    if (!self__weak_) return ;
                }];
                               */
            }else{//jwDeviceRecordFileList.his_recs.count<0的情况
                completionBlock(nil,JW_FAILD_SEARCH_VIDEO_LIST);
            }
        }else{//v1/media/record/list 的请求，返回 ret != 0 的情况
            if (ret == 1501) {
                 completionBlock(nil,JW_SEARCH_PLAYBACK_NO_PERMISSION);
            }else
            {
                completionBlock(nil,JW_FAILD_SEARCH_VIDEO_LIST);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(nil,JW_FAILD_SEARCH_VIDEO_LIST);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

#pragma mark --- 报警事件查询录像接口 【没用】
- (NSOperationQueue *)search_Alarm_RecordVideoWithDevidId:(NSString *)deviceId
                                             recVideoType:(JWRecVideoTypeStatus)recVideoType
                                                beginTime:(NSDate *)beginTime
                                          completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock
{
    //    [[HDNetworking sharedHDNetworking]canleAllHttp];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //录像类型
    NSNumber *recVideoTypeNum = [NSNumber numberWithInteger:recVideoType];
    //通道
    if (self.cannelNo == 0) {
        self.cannelNo = 1;
    }
    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    //开始时间
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[beginTime timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
    NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
    int endTimeInt = beginTimeInt+queryEndTime_list_alarm;
    NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
    
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:recVideoTypeNum forKey:@"rec_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];
    [postDic setObject:beginNum forKey:@"s_date"];
    [postDic setObject:endNum forKey:@"s_date_end"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
    }
    NSLog(@"报警事件查询录像接口:%@==时间：%@",postDic,dateStr);
    
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
         NSLog(@"报警事件查询录像接口【返回】:%@",responseObject);
        strongify(self);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWDeviceRecordFileList *jwDeviceRecordFileList = [JWDeviceRecordFileList mj_objectWithKeyValues:responseObject[@"body"]];
            if (jwDeviceRecordFileList.his_recs.count>0) {
                completionBlock(jwDeviceRecordFileList.his_recs,JW_SUCCESS);
                NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
                //设备id
                NSString *dev_id = [NSString isNullToString:self.deviceId];
                //令牌
                NSString *access_token = [NSString isNullToString:self.token];
                //视频格式
                NSNumber *videoTypeNum = [NSNumber numberWithInteger:recVideoType];
                //开始时间
                NSString *startDateStr = [NSString stringWithFormat:@"%ld", (long)[beginTime timeIntervalSince1970]];
                int beginTimeInt = [startDateStr intValue];
                NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
                //结束时间
                
                int endTimeInt = beginTimeInt+queryEndTime_video;
                NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
                
                //结束时间
                [postDic setObject:dev_id forKey:@"dev_id"];
                [postDic setObject:access_token forKey:@"access_token"];
                [postDic setObject:videoTypeNum forKey:@"rec_type"];
                [postDic setObject:beginNum forKey:@"start_time"];
                [postDic setObject:endNum forKey:@"stop_time"];
                //先确认保证通道model是否有
                if ([MultiChannelDefaults getChannelModel]) {
                    MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
                    [postDic setObject:model.chanCode forKey:@"chan_code"];
                }
                
                //NSLog(@"报警录像回放请求：%@",postDic);
                weakify(self);
                [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
                    strongify(self);
                    if (!self__weak_) return ;
                    int ret = [responseObject[@"ret"]intValue];
                    if (ret == 0 ) {
                        JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
                        self.videoManager.videoAddressModel = videoAddressInfo;
                    }else{
                        if (ret == 1401) {
                            completionBlock(nil,JW_PLAYBACK_NO_PERMISSION);
                        }else
                        {
                            completionBlock(nil,JW_FAILD);
                        }
                    }
                } failure:^(NSError * _Nonnull error) {
                    strongify(self);
                    if (!self__weak_) return ;
                }];
            }
            else{
                completionBlock(nil,JW_FAILD);
            }
        }else{
            if (ret == 1501) {
                completionBlock(nil,JW_SEARCH_PLAYBACK_NO_PERMISSION);
            }else
            {
                completionBlock(nil,JW_FAILD);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(nil,JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

#pragma mark ===  ap模式下 打开播放器
- (NSOperationQueue *)searchRecordVideoBIsAp:(BOOL)bIsAp
                                   beginTime:(NSString *)beginTime
                             completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock
{
    [self searchVideoCount_ap:beginTime completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {
        if (recVideoTimeArr.count >0) {
            completionBlock(recVideoTimeArr,JW_SUCCESS);
        }else{
            completionBlock(nil,JW_FAILD);
        }
    }];
     return [ZCNetWorking shareInstance].operationQueue;
}

#pragma mark == ap模式下，查询录像的个数
- (void)searchVideoCount_ap:(NSString *)timeStr completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock
{
    APModel * apModel = [[APModel alloc]init];
    apModel = [unitl getNeedArchiverDataWithKey:@"apModel"];
    //【recordSearchCount】
    //时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [formatter dateFromString:timeStr];
    NSString *tempBeginTimeString = [formatter stringFromDate:date];
    NSString *endTimeStr =[NSString stringWithFormat:@"%@T%@Z",tempBeginTimeString,@"16:00:00"];
    
    NSDate *lasttDat = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
    NSString *nextString = [formatter stringFromDate:lasttDat];
    NSString *beginTimeStr =[NSString stringWithFormat:@"%@T%@Z",nextString,@"16:00:00"];
    
    // NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
    NSMutableDictionary * recordSearchCountDic = [NSMutableDictionary dictionary];
    [recordSearchCountDic setObject:beginTimeStr forKey:@"startTime"];
    [recordSearchCountDic setObject:endTimeStr forKey:@"stopTime"];
    [recordSearchCountDic setObject:@"All" forKey:@"recordType"];
    
    //【params】
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:@0 forKey:@"channel"];
    [paramsDic setObject:recordSearchCountDic forKey:@"recordSearchCount"];
    
    //【call】
    NSMutableDictionary * callDic = [NSMutableDictionary dictionary];
    [callDic setObject:@"storage" forKey:@"service"];
    [callDic setObject:@"getRecordSearchCount" forKey:@"method"];
    
    //【postDic】
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:apModel.session_params forKey:@"session"];
    [postDic setObject:apModel.ID forKey:@"id"];
    [postDic setObject:callDic forKey:@"call"];
    [postDic setObject:paramsDic forKey:@"params"];
    
    NSString * postJsonStr = [unitl dictionaryToJSONString:postDic];
    
    NSString *gatewayIp = [wifiInfoManager getGatewayIpForCurrentWiFi];
    NSString * url = [NSString stringWithFormat:@"http://%@/%@",gatewayIp,WIFI_ADRESS];
    
    NSLog(@"ap搜索录像 【个数】 ：参数：%@===address:%@===postJsonStr:%@",postDic,url,postJsonStr);
    [[HDNetworking sharedHDNetworking] AP_POST:url parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"ap搜索录像 【个数】：返回：%@",responseObject);
        if ([responseObject[@"result"] integerValue] == 1) {
            if ([responseObject[@"params"] isEqual:[NSNull null]]) {
                return ;
            }
            NSInteger seartVideoResultCount = [responseObject[@"params"][@"count"] integerValue];
            [self searchVideo_ap:timeStr WithResultCount:seartVideoResultCount completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {
                if (recVideoTimeArr.count > 0) {
                    completionBlock(recVideoTimeArr,JW_SUCCESS);
                }else{
                    completionBlock(nil,JW_FAILD);
                }
            }];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"ap模式搜索录像 【个数】：请求：失败：%@",error);
        // [XHToast showCenterWithText:[NSString stringWithFormat:@"ap模式搜索录像:%@",error]];
    }];
}

#pragma mark == 查询录像  每段的时间段
- (void)searchVideo_ap:(NSString *)timeStr WithResultCount:(NSInteger)seartVideoResultCount completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock
{
    APModel * apModel = [[APModel alloc]init];
    apModel = [unitl getNeedArchiverDataWithKey:@"apModel"];
    //【recordSearchCount】
    //时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [formatter dateFromString:timeStr];
    NSString *tempBeginTimeString = [formatter stringFromDate:date];
    NSString *endTimeStr =[NSString stringWithFormat:@"%@T%@Z",tempBeginTimeString,@"16:00:00"];
    
    NSDate *lastDat = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
    NSString *nextString = [formatter stringFromDate:lastDat];
    NSString *beginTimeStr =[NSString stringWithFormat:@"%@T%@Z",nextString,@"16:00:00"];
    
    // NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
    NSMutableDictionary * recordSearchCountDic = [NSMutableDictionary dictionary];
    [recordSearchCountDic setObject:beginTimeStr forKey:@"startTime"];
    [recordSearchCountDic setObject:endTimeStr forKey:@"stopTime"];
    [recordSearchCountDic setObject:@"All" forKey:@"recordType"];
    NSArray * rangeArr = @[@1,[NSNumber numberWithInteger:seartVideoResultCount]];
    [recordSearchCountDic setObject:rangeArr forKey:@"itemRange"];
    
    //【params】
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:@0 forKey:@"channel"];
    [paramsDic setObject:recordSearchCountDic forKey:@"recordSearchItem"];
    
    //【call】
    NSMutableDictionary * callDic = [NSMutableDictionary dictionary];
    [callDic setObject:@"storage" forKey:@"service"];
    [callDic setObject:@"getRecordItem" forKey:@"method"];
    
    //【postDic】
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:apModel.session_params forKey:@"session"];
    [postDic setObject:apModel.ID forKey:@"id"];
    [postDic setObject:callDic forKey:@"call"];
    [postDic setObject:paramsDic forKey:@"params"];
    
    NSString * postJsonStr = [unitl dictionaryToJSONString:postDic];
    
    NSString *gatewayIp = [wifiInfoManager getGatewayIpForCurrentWiFi];
    NSString * url = [NSString stringWithFormat:@"http://%@/%@",gatewayIp,WIFI_ADRESS];
    
    //今日零点
    NSString *tempBeginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"00:00:00"];
    NSDate *tempDate = [formatter dateFromString:tempBeginTimeStr];
    // NSLog(@"DATE:%@", date);// 这个时间是格林尼治时间
    // NSDate *date2 = [date dateByAddingTimeInterval:8 * 60 * 60];
    NSString *tempDateStr = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970]];
//    int beginTimeInt = [tempDateStr intValue];
    
    NSLog(@"ap搜索录像：参数：%@===address:%@===postJsonStr:%@",postDic,url,postJsonStr);
    [[HDNetworking sharedHDNetworking] AP_POST:url parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"ap搜索录像：返回：%@",responseObject);
        if ([responseObject[@"result"] integerValue] == 1) {
            if ([responseObject[@"params"] isEqual:[NSNull null]]) {
                return ;
            }
            NSMutableArray * tempResultArr = responseObject[@"params"][@"recordItem"];
            if (tempResultArr.count > 0) {
                completionBlock(tempResultArr,JW_SUCCESS);
            }else
            {
                completionBlock(nil,JW_FAILD);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"ap模式搜索录像：请求：失败：%@",error);
        completionBlock(nil,JW_FAILD);
    }];
}


/**
 *  @since 1.0.0
 *  根据设备id打开录像回放播放接口
 *
 *  @param startTime   开始时间
 *  @param endTime     结束时间
 *  @param videoType   视频类型
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageBeginPlayRecVideoWithVideoType:(JWRecVideoTypeStatus)videoType
                                           startTime:(NSDate *)startTime
                                             endTime:(NSDate *)endTime
                                          BIsEncrypt:(BOOL)bIsEncrypt
                                                 Key:(NSString *)key
                                     completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
   // [[HDNetworking sharedHDNetworking]canleAllHttp];

    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //视频格式
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];
    //开始时间
    NSString *startDateStr = [NSString stringWithFormat:@"%ld", (long)[startTime timeIntervalSince1970]];
    int beginTimeInt = [startDateStr intValue];
    NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
    //结束时间
    NSString *endDateStr = [NSString stringWithFormat:@"%ld", (long)[endTime timeIntervalSince1970]];
    int endTimeInt = [endDateStr intValue];
    NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
    //频道
    NSNumber  *chan_no_ = [NSNumber numberWithInteger:self.cannelNo];

    //结束时间
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:videoTypeNum forKey:@"rec_type"];
    [postDic setObject:beginNum forKey:@"start_time"];
    [postDic setObject:endNum forKey:@"stop_time"];
    [postDic setObject:chan_no_ forKey:@"chan_id"];
    
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
        [postDic setObject:[NSNumber numberWithInteger:model.chanId] forKey:@"chan_id"];
    }
    
   // NSLog(@"请求录像回放播放接口，入参：%@===userID:%@",postDic,userID);
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
            self.videoManager.videoAddressModel = videoAddressInfo;
            if (videoAddressInfo.monitor_id) {
                [[NSUserDefaults standardUserDefaults]setObject:videoAddressInfo.monitor_id forKey:@"monitor_id"];
            }
            if (videoType == JWRecVideoTypeStatusCenter) {
                [self.videoManager startCloudPlayBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:YES DeviceId:dev_id bIsCenterPalyType:YES];
            }else
            {
                [self.videoManager startCloudPlayBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:YES DeviceId:dev_id bIsCenterPalyType:NO];
            }
            completionBlock(JW_SUCCESS);
        }else{
            if (ret == 1401) {
                completionBlock(JW_PLAYBACK_NO_PERMISSION);
            }else
            {
                completionBlock(JW_FAILD);
                //NSLog(@"播放回放录像【失败】：请求ret！=0 responseObject：%@",responseObject);
                [[NSNotificationCenter defaultCenter] postNotificationName:PLAYFAIL object:nil];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
        //NSLog(@"播放回放录像【失败】：请求失败");
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYFAIL object:nil];
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 *  JWStream 播放 【录像回放】
 *
 *  @param videoType   播放类型
 *  @param startTime   开始时间
 *  @param endTime     结束时间
 *  @param bIsEncrypt  视频是否加密
 *  @param key         视频密钥
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWStreamPlayerManageBeginPlayRecVideoWithVideoType:(JWRecVideoTypeStatus)videoType
                                                         startTime:(NSDate *)startTime
                                                           endTime:(NSDate *)endTime
                                                        BIsEncrypt:(BOOL)bIsEncrypt
                                                               Key:(NSString *)key
                                                   completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    // [[HDNetworking sharedHDNetworking]canleAllHttp];
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //视频格式
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];
    //开始时间
    NSString *startDateStr = [NSString stringWithFormat:@"%ld", (long)[startTime timeIntervalSince1970]];
    int beginTimeInt = [startDateStr intValue];
    NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
    //结束时间
    NSString *endDateStr = [NSString stringWithFormat:@"%ld", (long)[endTime timeIntervalSince1970]];
    int endTimeInt = [endDateStr intValue];
    NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
    //频道
    NSNumber  *chan_no_ = [NSNumber numberWithInteger:self.cannelNo];
    
    //结束时间
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:videoTypeNum forKey:@"rec_type"];
    [postDic setObject:beginNum forKey:@"start_time"];
    [postDic setObject:endNum forKey:@"stop_time"];
    [postDic setObject:chan_no_ forKey:@"chan_id"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
        [postDic setObject:[NSNumber numberWithInteger:model.chanId] forKey:@"chan_id"];
    }
    
    // NSLog(@"请求录像回放播放接口，入参：%@===userID:%@",postDic,userID);
    self.videoManager.isStop = NO;
    //TODO
    if (!self.videoManager.delegate) {
        self.videoManager.delegate = self;
        NSLog(@"重新设置后的delegate:%@",self.videoManager.delegate);
    }
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        NSLog(@"【playback】responseObject：%@=====%@",responseObject,postDic);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
            self.videoManager.videoAddressModel = videoAddressInfo;
            if (videoAddressInfo.monitor_id) {
                [[NSUserDefaults standardUserDefaults]setObject:videoAddressInfo.monitor_id forKey:@"monitor_id"];
            }
            if (videoType == JWRecVideoTypeStatusCenter) {
                //[self.videoManager startCloudPlayBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:YES DeviceId:dev_id bIsCenterPalyType:YES];
                [self.videoManager JWStreamStartBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:YES DeviceId:dev_id bIsCenterPalyType:YES];
            }else
            {
                //[self.videoManager startCloudPlayBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:YES DeviceId:dev_id bIsCenterPalyType:NO];
                [self.videoManager JWStreamStartBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:YES DeviceId:dev_id bIsCenterPalyType:NO];//注意这里必须传deviceId
            }
            completionBlock(JW_SUCCESS);
        }else{
            if (ret == 1401) {
                completionBlock(JW_PLAYBACK_NO_PERMISSION);
            }else
            {
                completionBlock(JW_FAILD);
                //NSLog(@"播放回放录像【失败】：请求ret！=0 responseObject：%@",responseObject);
                [[NSNotificationCenter defaultCenter] postNotificationName:PLAYFAIL object:nil];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
        //NSLog(@"播放回放录像【失败】：请求失败");
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYFAIL object:nil];
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}


#pragma mark === ap模式下播放回放
- (NSOperationQueue *)JWPlayerManageBeginPlay_AP_RecVideoWithStartTime:(NSString *)startTime
                                                               endTime:(NSString *)endTime
                                                       completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    //rtsp:///Stream/Replay/101?starttime=20180517T081953Z&endtime=20180517T084808Z
    NSString * url = [NSString stringWithFormat:@"rtsp://admin:abcd1234@192.168.1.1:554/Stream/Replay/101?starttime=%@&endtime=%@",startTime,endTime];
    [self.videoManager start_AP_backPlay_byRtspWithUrl:url];
   return [ZCNetWorking shareInstance].operationQueue;
}


/**
 *  修改后的【录像回放】关闭
 *
 *  @return operation
 */
- (NSOperationQueue *)JWStreamPlayerManageEndRecPlayVideoWithCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
//    [[HDNetworking sharedHDNetworking]canleAllHttp];

    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    
    //playid
    JWVideoAddressInfo *addressInfo = self.videoManager.videoAddressModel;
    //停止播放
    _videoManager.delegate = nil;
    [_videoManager JWStreamStopCloudPlayRtpHandle:addressInfo.handle];
    _videoManager = nil;
    
    
    if (!self.isSuspend) {
        [self.playView.openView cleanBackColor];
    }
        
    
    NSLog(@"单独回放界面addressInfo.monitor_id：%@",addressInfo.monitor_id);
    if (addressInfo.monitor_id.length > 0) {
        [postDic setObject:addressInfo.monitor_id forKey:@"monitor_id"];
        NSLog(@"单独回放界面addressInfo.monitor_id 2：%@",addressInfo.monitor_id);
        
        //先确认保证通道model是否有
        if ([MultiChannelDefaults getChannelModel]) {
            MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
            [postDic setObject:model.chanCode forKey:@"chan_code"];
        }
        
        weakify(self);
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/stop_playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            strongify(self);
            NSLog(@"单独回放界面addressInfo.monitor_id 3：%@==responseObject：%@",addressInfo.monitor_id,responseObject);
            if (!self__weak_) return ;
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0 ) {
                completionBlock(JW_SUCCESS);
            }else{
                completionBlock(JW_FAILD);
            }
        } failure:^(NSError * _Nonnull error) {
            strongify(self);
            if (!self__weak_) return ;
            completionBlock(JW_FAILD);
        }];
    }else{
        completionBlock(JW_FAILD);
    }
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 *  @since 1.0.0
 *  开启语音对讲
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageStartAudioTalkWithCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];

    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/talk/start" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWAudioAddressInfo *audioAddressInfo = [JWAudioAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
           //开启音频
            self.audioRecordManager.audioAddressModel = audioAddressInfo;
            [self.audioRecordManager startRecording];
            completionBlock(JW_SUCCESS);
        }else{
            completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 *  @since 1.0.0
 *  关闭语音对讲
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageEndAudioTalkWithCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
 
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //playid
    JWAudioAddressInfo *addressInfo = self.audioRecordManager.audioAddressModel;
    //停止录音发送
    [self.audioRecordManager stopRecording];
    //字典请求数据
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    if (addressInfo.talk_id.length>0) {
        [postDic setObject:addressInfo.talk_id forKey:@"talk_id"];
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/talk/stop" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            strongify(self);
            if (!self__weak_) return ;
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0 ) {
                completionBlock(JW_SUCCESS);
            }else{
                completionBlock(JW_FAILD);
            }
        } failure:^(NSError * _Nonnull error) {
            strongify(self);
            if (!self__weak_) return ;
            completionBlock(JW_FAILD);
        }];
    }else{
        completionBlock(JW_FAILD);
    }
    return [ZCNetWorking shareInstance].operationQueue;
}


/**
 *  @since 1.0.0
 *  根据播放id控制录像
 *  @param cmd 命令类型
 *  @param action 参数1
 *  @param param 参数2
 
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageControlRecVideoWithCmd:(NSString *)cmd
                                      action:(NSInteger)action
                                       param:(NSInteger)param
                             completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //playid
    JWVideoAddressInfo *addressInfo = self.videoManager.videoAddressModel;
    //cmd
    
    //action
    NSNumber *actionNum = [NSNumber numberWithInteger:action];
    //param
    NSNumber *paramNum = [NSNumber numberWithInteger:param];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:addressInfo.monitor_id forKey:@"monitor_id"];
    [postDic setObject:cmd forKey:@"cmd"];
    [postDic setObject:actionNum forKey:@"action"];
    [postDic setObject:paramNum forKey:@"param"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
    }
    
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback_ctrl" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            completionBlock(JW_SUCCESS);
        }else{
            completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}
//开始/暂停播放
/**
 *  @since 1.0.0
 *  param isSuspended 是否暂停
 */
- (void)JWPlayerManageIsSuspendedPlay:(BOOL)isSuspended
{
    //暂时可能弃用
    /*
    //暂停
    if (isSuspended) {
        [self.videoManager suspendedPlayNo];
    }
    //开始
    else{
        [self.videoManager suspendedPlayYes];
    }
     */
   // [self.videoManager JWStreamStopCloudPlayRtpHandle];

}

//视频录制开始/停止
/**
 *  @since 1.0.0
 *  视频开始录制
 */
-(void)JWPlayerManageStartRecordWithPath:(NSString *)path fileName:(NSString *)filename
{
    [self.videoManager startRecordWithPath:path fileName:filename];
}
-(void)JWPlayerManageStartRecordWithPath:(NSString *)path
{
    [self.videoManager startRecordWithPath:path];
}
/**
 *  @since 1.0.0
 *  视频停止录制
 */
- (void)JWPlayerManageStopRecord
{
    [self.videoManager stopRecord];
}


#pragma mark ------video停止播放时候打开录音的播放
-(void)audioManagerIsOpenYes:(NSNotification *)noit
{
    NSNumber *isOpenNum = noit.object;
    BOOL isOpen = [isOpenNum boolValue];
    if (isOpen) {
        self.audioRecordManager.isOpenAudio = YES;
    }
    else{
        self.audioRecordManager.isOpenAudio = NO;
    }
}

#pragma mark ------捏合手势（放大）
- (void)pinch:(UIPinchGestureRecognizer *)recognizer{
    UIGestureRecognizerState state = [recognizer state];
    if(state == UIGestureRecognizerStateBegan) {
        
        [self correctAnchorPointBaseOnGestureRecognizer:recognizer];
        _lastScale = [recognizer scale];
        
    }
    
    if (state == UIGestureRecognizerStateBegan ||
        state == UIGestureRecognizerStateChanged) {
        //        CGFloat currentScale = self.playView.openView.videoScale;
        // Constants to adjust the max/min values of zoom
        CGFloat currentScale = [[self.playView.openView.layer valueForKeyPath:@"transform.scale"] floatValue];
        CGFloat newScale = 1.0 -  (_lastScale - [recognizer scale]);
        newScale = MIN(newScale, MaxSCale / currentScale);
        newScale = MAX(newScale, MinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([self.playView.openView transform], newScale, newScale);
        self.playView.openView.transform = transform;

        //        self.playView.openView.videoScale *= newScale;
        _lastScale = [recognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateFailed || state == UIGestureRecognizerStateCancelled) {
        [self setDefaultAnchorPointforView:self.playView.openView];
    }
    if (state == UIGestureRecognizerStateEnded) {
        
        CGRect newRect1 = [self.playView convertRect:self.playView.bounds toView:self.playView.openView];
        BOOL canRect =  CGRectContainsRect(self.playView.openView.frame, newRect1);
        if (canRect) {
            
        }else{
            CGPoint CenterPoint = self.playView.center;
            [self.playView.openView setCenter:CenterPoint];
        }
    }
}
//移动手势
- ( void )handleSwipe:( UIPanGestureRecognizer *)gesture
{
    UIView *view = self.playView.openView;
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:view.superview];
        UIView *tiView = [[UIView alloc]init];
        CGRect viewFrame = view.frame;
        [tiView setFrame:viewFrame];
        [tiView setCenter:(CGPoint){tiView.center.x + translation.x, tiView.center.y + translation.y}];
        CGRect newRect1 = [self.playView convertRect:self.playView.bounds toView:self.playView.openView];
        BOOL canRect =  CGRectContainsRect(tiView.frame, newRect1);
        if (canRect) {
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
            [gesture setTranslation:CGPointZero inView:view.superview];
        }
        else{
            return;
        }
    }
}
//获取两指中心点
- (void)correctAnchorPointBaseOnGestureRecognizer:(UIGestureRecognizer *)gr
{
    CGPoint onoPoint = [gr locationOfTouch:0 inView:gr.view];
    CGPoint twoPoint = [gr locationOfTouch:1 inView:gr.view];
    
    CGPoint anchorPoint;
    anchorPoint.x = (onoPoint.x + twoPoint.x) / 2 / gr.view.bounds.size.width;
    anchorPoint.y = (onoPoint.y + twoPoint.y) / 2 / gr.view.bounds.size.height;
    
    [self setAnchorPoint:anchorPoint forView:self.playView.openView];
}
//设置变换中心点
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}
//还原中心点
- (void)setDefaultAnchorPointforView:(UIView *)view
{
    [self setAnchorPoint:CGPointMake(0.5f, 0.5f) forView:view];
}
#pragma mark ------zcvideoManageDelegate
//硬解
- (void)setUpBuffer:(CVPixelBufferRef)buffer//这里本来就是CVPixelBufferRef，试试image
{
   // dispatch_sync(dispatch_get_main_queue(), ^{
        if(buffer && !_videoManager.isStop)
        {
            //NSLog(@"解码当前线程4：%@",[NSThread currentThread]);
            CGSize playViewSize = _playView.bounds.size;
            [_playView.openView displayPixelBuffer:buffer playViewSize:playViewSize];
        }
   // });
}
//停止录制回调
- (void)stopRecordBlockFunc
{

}

- (void)JWPlayerManageEmptyVideoDataCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    BOOL emptySuccess = [self.videoManager emptyVideoData];
    if (emptySuccess) {
        completionBlock(JW_SUCCESS);
    }else
    {
       completionBlock(JW_FAILD);
    }
}

- (void)dealloc
{
//    NSLog(@"JWPlayerManage this is dealloc function");
//    [[HDNetworking sharedHDNetworking]canleAllHttp];
//    _videoManager.delegate = nil;
//    [_videoManager stopCloudPlay];
//    [_videoManager stopCloudPlayRtsp];//新添加
//    _videoManager = nil;
//    
//    [_audioRecordManager stopRecording];
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



/**
 *  @since 用【JWStream】接口-根据"通道"进行播放的播放接口
 *  根据设备id打开播放接口
 *
 *  @param videoType   视频类型
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */

- (NSOperationQueue *)JWStreamPlayerManagePlayVideoWithVideoType:(JWVideoTypeStatus)videoType BIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //视频格式
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];

    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    NSString *channelCode = [NSString isNullToString:self.channelCode];
    
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:videoTypeNum forKey:@"video_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];
    [postDic setObject:channelCode forKey:@"chan_code"];
    NSLog(@"我重新进来，冲了？？？：%@",postDic);
    self.videoManager.isStop = NO;
    [self JWStreamPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:NO P2pInfoDic:nil BIsAP:NO completionBlock:completionBlock];

    return [ZCNetWorking shareInstance].operationQueue;
}



/**
 *  @since 1.0.0 通道查询方式的时间列表查询
 *  根据通道查询录像播放接口
 *  @param recVideoType   录像视频类型
 *  @param beginTime   开始时间
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考JWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)searchChannelPlayBackVideoTimeListRecVideoType:(JWRecVideoTypeStatus)recVideoType                                    beginTime:(NSDate *)beginTime
                                completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock
{
//    [[HDNetworking sharedHDNetworking]canleAllHttp];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //通道Id
    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    //通道Code
    NSString *channelCode = [NSString isNullToString:self.channelCode];
    
    //录像类型
    NSNumber *recVideoTypeNum;
    if (recVideoType == JWRecVideoTypeStatusCenter) {
        recVideoTypeNum = [NSNumber numberWithInteger:0];
    }else
    {
        recVideoTypeNum = [NSNumber numberWithInteger:1];
    }
    
    //开始时间
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[beginTime timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
    NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
    int endTimeInt = beginTimeInt + queryEndTime_list_record;
    NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
    
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:recVideoTypeNum forKey:@"rec_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];
    [postDic setObject:channelCode forKey:@"chan_code"];
    [postDic setObject:beginNum forKey:@"s_date"];
    [postDic setObject:endNum forKey:@"s_date_end"];

    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWDeviceRecordFileList *jwDeviceRecordFileList = [JWDeviceRecordFileList mj_objectWithKeyValues:responseObject[@"body"]];
            if (jwDeviceRecordFileList.his_recs.count > 0) {
                completionBlock(jwDeviceRecordFileList.his_recs,JW_SUCCESS_SEARCH_VIDEO_LIST);
                NSLog(@"channelList的通道进来的：%@===%@",postDic,responseObject);
            }else{//jwDeviceRecordFileList.his_recs.count<0的情况
                completionBlock(nil,JW_FAILD_SEARCH_VIDEO_LIST);
            }
        }else{//v1/media/record/list 的请求，返回 ret != 0 的情况
            if (ret == 1501) {
                 completionBlock(nil,JW_SEARCH_PLAYBACK_NO_PERMISSION);
            }else
            {
                completionBlock(nil,JW_FAILD_SEARCH_VIDEO_LIST);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(nil,JW_FAILD_SEARCH_VIDEO_LIST);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 *  JWStream 播放【"通道"录像回放】
 *
 *  @param videoType   播放类型
 *  @param startTime   开始时间
 *  @param endTime     结束时间
 *  @param bIsEncrypt  视频是否加密
 *  @param key         视频密钥
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWStreamChannelPlayerManageWithVideoType:(JWRecVideoTypeStatus)videoType
                                                         startTime:(NSDate *)startTime
                                                           endTime:(NSDate *)endTime
                                                        BIsEncrypt:(BOOL)bIsEncrypt
                                                               Key:(NSString *)key
                                                   completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{

    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:self.deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //userid
    NSString *userId = [NSString isNullToString:self.userId];
    //视频格式
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];
    //开始时间
    NSString *startDateStr = [NSString stringWithFormat:@"%ld", (long)[startTime timeIntervalSince1970]];
    int beginTimeInt = [startDateStr intValue];
    NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
    //结束时间
    NSString *endDateStr = [NSString stringWithFormat:@"%ld", (long)[endTime timeIntervalSince1970]];
    int endTimeInt = [endDateStr intValue];
    NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
    //通道Id
    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
    //通道Code
    NSString *channelCode = [NSString isNullToString:self.channelCode];
    
    //结束时间
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:userId forKey:@"user_id"];
    [postDic setObject:videoTypeNum forKey:@"rec_type"];
    [postDic setObject:beginNum forKey:@"start_time"];//beginNum 1597720990
    [postDic setObject:endNum forKey:@"stop_time"];//endNum 1597766400
    [postDic setObject:channelNum forKey:@"chan_id"];
    [postDic setObject:channelCode forKey:@"chan_code"];
   
    //多一个server_ip字段
    NSUserDefaults *ipDefault = [NSUserDefaults standardUserDefaults];
    NSString *ipStr = [ipDefault objectForKey:CURRENT_IP_KEY];
    [postDic setObject:ipStr forKey:@"server_ip"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
        [postDic setObject:[NSNumber numberWithInteger:model.chanId] forKey:@"chan_id"];
    }
    
    // NSLog(@"请求录像回放播放接口，入参：%@===userID:%@",postDic,userID);
    self.videoManager.isStop = NO;
    //TODO
    if (!self.videoManager.delegate) {
        self.videoManager.delegate = self;
        NSLog(@"重新设置后的delegate:%@",self.videoManager.delegate);
    }
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        NSLog(@"【playback】responseObject：%@=====%@",responseObject,postDic);
        if (!self__weak_) return ;
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
            self.videoManager.videoAddressModel = videoAddressInfo;
            if (videoAddressInfo.monitor_id) {
                [[NSUserDefaults standardUserDefaults]setObject:videoAddressInfo.monitor_id forKey:@"monitor_id"];
            }
            if (videoType == JWRecVideoTypeStatusCenter) {
                [self.videoManager JWStreamStartBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:YES DeviceId:dev_id bIsCenterPalyType:YES];
            }else
            {
                [self.videoManager JWStreamStartBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:YES DeviceId:dev_id bIsCenterPalyType:NO];//注意这里必须传deviceId dev_id
            }
            completionBlock(JW_SUCCESS);
        }else{
            if (ret == 1401) {
                completionBlock(JW_PLAYBACK_NO_PERMISSION);
            }else
            {
                completionBlock(JW_FAILD);
                //NSLog(@"播放回放录像【失败】：请求ret！=0 responseObject：%@",responseObject);
                [[NSNotificationCenter defaultCenter] postNotificationName:PLAYFAIL object:nil];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
        //NSLog(@"播放回放录像【失败】：请求失败");
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYFAIL object:nil];
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}



@end
