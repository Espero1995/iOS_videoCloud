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

#import "HKSDKVideoManage.h"
#import "HKSDKLoginManage.h"
#import "DeviceInfo.h"
#import "libt2u.h"

#import "APModel.h"
#import "wifiInfoManager.h"


#ifndef weakify
#define weakify(o) __typeof__(o) __weak o##__weak_ = o;
#define strongify(o) __typeof__(o##__weak_) __strong o =    o##__weak_;
#endif

#define MaxSCale 6.0  //最大缩放比例
#define MinScale 1.0  //最小缩放比例
@interface JWPlayerManage ()<ZCVideoManageDelegate,HKSDKVideoManageDelegate>
///解码管理者
@property (nonatomic,strong)ZCVideoManager *videoManager;

///海康管理者
@property (nonatomic,strong)HKSDKVideoManage *hkVideoManager;
///海康登录管理者
@property (nonatomic,strong)HKSDKLoginManage *hkLoginManager;
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
//缩放比例
@property (nonatomic,assign) CGFloat lastScale;

//p2pret
@property (nonatomic,assign)int p2pRet;
//播放id
@property (nonatomic,copy)NSString *monitor_idStr;

@property (nonatomic,strong)dispatch_queue_t que_port_status_Queue;

@end
@implementation JWPlayerManage


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



//海康解码管理者
- (HKSDKVideoManage *)hkVideoManager
{
    if (!_hkVideoManager) {
        _hkVideoManager = [[HKSDKVideoManage alloc]init];
        _hkVideoManager.delegate = self;
        _hkVideoManager.isAudioOpen = _isAudioOpen;
    }
    return _hkVideoManager;
}

//海康登录管理者
- (HKSDKLoginManage *)hkLoginManager
{
    if (!_hkLoginManager) {
        _hkLoginManager = [[HKSDKLoginManage alloc]init];
    }
    return _hkLoginManager;
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
    
    //p2p开始
    t2u_init("nat.vveye.net", 8000, NULL);//在刚开始就初始化这个

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
    self.hkVideoManager.isAudioOpen = isOpen;
}
/**
 *  设置播放器声音开关
 *
 *  判断播放状态
 */

- (BOOL)JWPlayerManageGetPlayState
{
    if (self.videoManager.isStop) {
        return NO;
    }else
        return YES;
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
    weakify(self);
#warning ------hksdk
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/playp2p" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        if (!self__weak_) return ;
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

            if (port==-1) {
               // [self platformPlayWithDic:postDic completionBlock:completionBlock];
                //[self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic completionBlock:completionBlock];
                return;
            }
            WS(weakSelf);
            dispatch_async(weakSelf.que_port_status_Queue, ^{
                //查询映射端口状态 1 已联通 0 未联通 -1 失败端口不存在 -2 p2p连接失败等待30秒自动连接 -3 中断 等待30秒 -4 对方离线 等待30秒  -5 设备有密码认证失败
                int ret2;
                ret2 = t2u_port_status(port,NULL);
                int count = 0;
                while (ret2 != 1) {
                    ret2 = t2u_port_status(port,NULL);
                    count ++;
                    NSLog(@"count:%d",count);
                    if (count > 3000) {
                        break;
                    }
                }
                NSLog(@"查询映射端口是否成功：%d",ret2);
                if (ret2 == 1) {
                    //都连接成功了赋值Ret
                    self.p2pRet = port;
                    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
                    deviceInfo.chDeviceAddr = devpass;
                    deviceInfo.nDevicePort = port;
                    deviceInfo.chLoginName = p2pid;
                    deviceInfo.chPassWord = p2pPass;
                    
                    if ([self.hkLoginManager loginDeviceWithDeviceInfo:deviceInfo]) {
                        //登录成功了 赋值播放id
                        self.monitor_idStr = monitor_idStr;
                        [self.hkVideoManager startCloudPlayWithlUserID:self.hkLoginManager.isLoginint videoType:videoType];
                    }
                    else{
                        // [self platformPlayWithDic:postDic completionBlock:completionBlock];
                        [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic BIsAP:NO completionBlock:completionBlock];
                        return;
                    }
                }
                else{
                    //[self platformPlayWithDic:postDic completionBlock:completionBlock];
                    // [self platformPlayWithDic:postDic BIsEncrypt:bIsEncrypt Key:key BIsRtsp:YES P2pInfoDic:p2pInfoDic completionBlock:completionBlock];
                    
                    return;
                }
            });

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
    if (bIsAp) {
        /**
         这里是设备 软ap模式下的rtsp流播放。
         ***/
        //rtsp://admin:abcd1234@192.168.1.1:554/Stream/Live/101/track=1
        //NSString * ownUrl = [NSString stringWithFormat:@"rtsp://%@:%@@127.0.0.1:%@/h264/ch1/main/av_stream/",self.deviceId,key,p2pInfoDic[@"port"]];
        NSString * ownUrl = @"rtsp://admin:abcd1234@192.168.1.1:554/Stream/Live/101/track=1";//:554/Stream/Live/101/track=1
        [self.videoManager startCloudPlayRtspWithUrl:ownUrl bIsEncrypt:bIsEncrypt Key:key];
    }
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/play" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        strongify(self);
        if (!self__weak_) return;
        int ret = [responseObject[@"ret"]intValue];
       // NSLog(@"ret:%d===responseObject:%@",ret,responseObject);
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:1.0] forKey:@"SpeedValue"];

        if (ret == 0 ) {
            JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
            self.videoManager.videoAddressModel = videoAddressInfo;
            
            if (!bIsRtsp) {
                NSString *dev_id = [NSString isNullToString:self.deviceId];  //设备id
                [self.videoManager startCloudPlayBIsEncrypt:bIsEncrypt Key:key BIsPlayBack:NO DeviceId:dev_id bIsCenterPalyType:NO];//还要修改
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
            completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
    }];
}
- (void)ceshiP2P{
    
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
/**
 *  @since 1.0.0
 *  根据播放管理者关闭播放接口
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
    if (self.p2pRet>0) {
        NSLog(@"删除p2p端口");
        monitor_idStr = self.monitor_idStr;
        [_hkVideoManager stopCloudPlayWithlUserID:_hkLoginManager.isLoginint];
        _hkVideoManager  = nil;
        //删除端口
        t2u_del_port(self.p2pRet);
        //退出
        t2u_exit();
        [_videoManager stopCloudPlayRtsp];//新添加
    }else{
        //playid
        JWVideoAddressInfo *addressInfo = self.videoManager.videoAddressModel;
        monitor_idStr = [addressInfo.monitor_id mutableCopy];
        //停止播放
        _videoManager.delegate = nil;
        [_videoManager stopCloudPlay];
        _videoManager = nil;
    }
    NSLog(@"用了停止码流的monitor_idStr：%@",monitor_idStr);
    if (stop) {
        NSLog(@"停止保留最后一帧");
    }else{
        [self.playView.openView cleanBackColor];
    }
    if (monitor_idStr.length>0) {
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

    /*
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
    }*/

//    NSNumber *channelNum = [NSNumber numberWithInteger:self.cannelNo];
//    [postDic setObject:dev_id forKey:@"dev_id"];
//    [postDic setObject:access_token forKey:@"access_token"];
//    [postDic setObject:userId forKey:@"user_id"];
//    [postDic setObject:videoTypeNum forKey:@"video_type"];
//    [postDic setObject:channelNum forKey:@"chan_id"];
//    weakify(self);
//    [[HDNetworking sharedHDNetworking]POST:@"v1/media/play" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
//        strongify(self);
//        if (!self__weak_) return ;
//        int ret = [responseObject[@"ret"]intValue];
//        if (ret == 0 ) {
//            JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
//            self.videoManager.videoAddressModel = videoAddressInfo;
//
//#warning 警告，这里不知道为什么还要调用。key暂时先填写nil
//            [self.videoManager startCloudPlayRtspWithUrl:url bIsEncrypt:encrypt Key:nil];
//            completionBlock(JW_SUCCESS);
//        }else{
//            completionBlock(JW_FAILD);
//        }
//    } failure:^(NSError * _Nonnull error) {
//        strongify(self);
//        if (!self__weak_) return ;
//        completionBlock(JW_FAILD);
//    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

- (NSOperationQueue *)JWPlayerManageEndPlayLiveVideoCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    
    [self.videoManager stopCloudPlayRtmp];

    
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
    [[HDNetworking sharedHDNetworking]canleAllHttp];
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
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:recVideoTypeNum forKey:@"rec_type"];
    [postDic setObject:channelNum forKey:@"chan_id"];
    [postDic setObject:beginNum forKey:@"s_date"];
    weakify(self);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
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
               
                int endTimeInt = beginTimeInt+86399;
                NSNumber *endNum = [NSNumber numberWithInt:endTimeInt];
                
                //结束时间
                [postDic setObject:dev_id forKey:@"dev_id"];
                [postDic setObject:access_token forKey:@"access_token"];
                [postDic setObject:videoTypeNum forKey:@"rec_type"];
                [postDic setObject:beginNum forKey:@"start_time"];
                [postDic setObject:endNum forKey:@"stop_time"];
                weakify(self);
                [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
                    strongify(self);
                    if (!self__weak_) return ;
                    int ret = [responseObject[@"ret"]intValue];
                    if (ret == 0 ) {
                        JWVideoAddressInfo *videoAddressInfo = [JWVideoAddressInfo mj_objectWithKeyValues:responseObject[@"body"]];
                        self.videoManager.videoAddressModel = videoAddressInfo;
                    }else{
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
            completionBlock(nil,JW_FAILD);
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
    int beginTimeInt = [tempDateStr intValue];
    
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
 *  @param deviceId 设备id
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
//    [[HDNetworking sharedHDNetworking]canleAllHttp];

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
            completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
        strongify(self);
        if (!self__weak_) return ;
        completionBlock(JW_FAILD);
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
 *  @since 1.0.0
 *  根据播放id关闭录像回放播放接口
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageEndRecPlayVideoWithCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
//    [[HDNetworking sharedHDNetworking]canleAllHttp];


    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //令牌
    NSString *access_token = [NSString isNullToString:self.token];
    //playid
    JWVideoAddressInfo *addressInfo = self.videoManager.videoAddressModel;
    //停止播放
    _videoManager.delegate = nil;
    [_videoManager stopCloudPlay];
    _videoManager = nil;
    [self.playView.openView cleanBackColor];
    NSLog(@"单独回放界面addressInfo.monitor_id：%@",addressInfo.monitor_id);
    if (addressInfo.monitor_id.length>0) {
        [postDic setObject:addressInfo.monitor_id forKey:@"monitor_id"];
        NSLog(@"单独回放界面addressInfo.monitor_id 2：%@",addressInfo.monitor_id);
        weakify(self);
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/stop_playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            strongify(self);
            NSLog(@"单独回放界面addressInfo.monitor_id 3：%@",addressInfo.monitor_id);
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
    //暂停
    if (isSuspended) {
        [self.videoManager suspendedPlayNo];
    }
    //开始
    else{
        [self.videoManager suspendedPlayYes];
    }

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

#pragma mark ------捏合手势
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
- (void)setUpBuffer:(CVPixelBufferRef)buffer
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if(buffer && !_videoManager.isStop)
        {
            CGSize playViewSize = _playView.bounds.size;
            [_playView.openView displayPixelBuffer:buffer playViewSize:playViewSize];
        }
        if(buffer && !_hkVideoManager.isStop)
        {
            //        CGSize playViewSize = _playView.bounds.size;
            //        [_playView.openView displayPixelBuffer:buffer playViewSize:playViewSize];
        }
    });
}
//停止录制回调
- (void)stopRecordBlockFunc
{

}

- (void)dealloc
{
    NSLog(@"JWPlayerManage this is dealloc function");
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    _videoManager.delegate = nil;
    [_videoManager stopCloudPlay];
    [_videoManager stopCloudPlayRtsp];//新添加
    _videoManager = nil;
    
    _hkVideoManager.delegate = nil;
    [_hkVideoManager stopCloudPlayWithlUserID:_hkLoginManager.isLoginint];
    _hkVideoManager = nil;
    
    [_audioRecordManager stopRecording];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
