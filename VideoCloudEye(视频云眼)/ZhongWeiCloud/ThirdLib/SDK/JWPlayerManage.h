//
//  ZWPlayerManage.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JWConstants.h"
@class JWPlayView;

@protocol JWPlayerManageDelegate <NSObject>


@end

///播放管理类
@interface JWPlayerManage : NSObject

/**
 * @brief 是否是暂停
 */
@property (nonatomic,assign) BOOL isSuspend;

/**
 *  @since 1.0.0
 *  播放管理类初始化
 */
- (instancetype)initWithToken:(NSString *)token;


- (instancetype)initWithToken:(NSString *)token
                       userId:(NSString *)userId
                     deviceId:(NSString *)deviceId
                     cannelNo:(NSInteger)cannelNo;

/**
 * @brief JWplayerManage 含通道的初始化
 */
- (instancetype)initWithToken:(NSString *)token
                       userId:(NSString *)userId
                       deviceId:(NSString *)deviceId
                       chanId:(NSInteger)chanId
                       chanCode:(NSString *)chanCode;


/**
 *  设置播放器的view
 *
 *  @param playerView 播放器view
 */
- (void)JWPlayerManageSetPlayerView:(UIView *)playerView;


/**
 *  设置播放器声音开关
 *
 *  @param isOpen 是否开启声音
 */
- (void)JWPlayerManageSetAudioIsOpen:(BOOL)isOpen;

/**
 *  设置播放器声音开关
 *
 *  判断播放状态
 */
- (BOOL)JWPlayerManageGetPlayState;
//开始/暂停播放
/**
 *  @since 1.0.0
 *  param isSuspended 是否暂停
 */
- (void)JWPlayerManageIsSuspendedPlay:(BOOL)isSuspended;

//视频录制开始/停止
/**
 *  @since 1.0.0
 *  视频开始录制
 */
-(void)JWPlayerManageStartRecordWithPath:(NSString *)path fileName:(NSString *)filename;
-(void)JWPlayerManageStartRecordWithPath:(NSString *)path;
/**
 *  @since 1.0.0
 *  视频停止录制
 */
- (void)JWPlayerManageStopRecord;

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
- (NSOperationQueue *)JWPlayerManageBeginPlayVideoWithVideoType:(JWVideoTypeStatus)videoType BIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsAP:(BOOL)bIsAp completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 *  @since 1.0.0
 *  根据播放管理者关闭播放接口
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageEndPlayVideoWithBIsStop:(BOOL)stop CompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock;


/**
 JWStream 取流并播放

 @param videoType 播放类型
 @param bIsEncrypt 是否加密
 @param key 加密的key
 @param bIsAp 是否ap模式
 @param completionBlock 回调
 @return 回调结构
 */
- (NSOperationQueue *)JWStreamPlayerManagePlayVideoWithVideoType:(JWVideoTypeStatus)videoType BIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key BIsAP:(BOOL)bIsAp completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 JWStream 关闭播放接口

 @param completionBlock 回调
 @return 成功或失败
 */
- (NSOperationQueue *)JWStreamPlayerManageEndPlayLiveVideoIsStop:(BOOL)stop CompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 调整码率

 @param videoType 码率类型
 @param completionBlock 回调
 @return 成功失败
 */
- (NSOperationQueue *)JWPlayerManageChangePlayVideoVideoType:(JWVideoTypeStatus)videoType completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;



// 【录像回放】播放接口
- (NSOperationQueue *)JWStreamPlayerManageBeginPlayRecVideoWithVideoType:(JWRecVideoTypeStatus)videoType
                                                               startTime:(NSDate *)startTime
                                                                 endTime:(NSDate *)endTime
                                                              BIsEncrypt:(BOOL)bIsEncrypt
                                                                     Key:(NSString *)key
                                                         completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 ap模式下 打开播放器

 @param bIsAp 是否是ap模式
 @param beginTime 开始时间
 @param completionBlock 完成回调
 @return operation
 */
- (NSOperationQueue *)searchRecordVideoBIsAp:(BOOL)bIsAp
                                         beginTime:(NSString *)beginTime
                             completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock;

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
- (NSOperationQueue *)JWPlayerManageBeginPlayVideoWithUrl:(NSString *)url VideoType:(JWVideoTypeStatus)videoType bIsEncrypt:(BOOL)encrypt completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 *  @since 1.0.0
 *  根据url打开播放接口 【直播】
 *   @param url 地址
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageBeginPlayLiveVideoWithUrl:(NSString *)url
                                                completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;
/**
 *  @since 1.0.0
 *  关闭播放接口 【直播】
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageEndPlayLiveVideoCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 *  @since 1.0.0
 *  根据播放管理者关闭播放接口
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageEndPlayVideoWithURLCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

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
                                   completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock;


/**
 报警事件查询录像接口

 @param deviceId 设备id
 @param recVideoType 回放类型
 @param beginTime 开始时间
 @param completionBlock 回调
 @return 错误码类型：110004、120002、120014、120018，具体参考JWConstants头文件中的JWErrorCode错误码注释
 */
- (NSOperationQueue *)search_Alarm_RecordVideoWithDevidId:(NSString *)deviceId
                                      recVideoType:(JWRecVideoTypeStatus)recVideoType
                                         beginTime:(NSDate *)beginTime
                                          completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock;

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
                                   completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 ap模式下视频回放接口

 @param startTime 开始时间
 @param endTime 结束时间
 @param completionBlock 回调
 @return operation
 */
- (NSOperationQueue *)JWPlayerManageBeginPlay_AP_RecVideoWithStartTime:(NSString *)startTime
                                                           endTime:(NSString *)endTime
                                                   completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;


/**
 *  修改后的【录像回放】关闭
 *
 *  @return operation
 */
- (NSOperationQueue *)JWStreamPlayerManageEndRecPlayVideoWithCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock;


/**
 *  @since 1.0.0
 *  开启语音对讲
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageStartAudioTalkWithCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 *  @since 1.0.0
 *  关闭语音对讲
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)JWPlayerManageEndAudioTalkWithCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock;


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
                                completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 清空视频播放缓存里的帧

 @param completionBlock 成功回调
 */
- (void)JWPlayerManageEmptyVideoDataCompletionBlock:(void (^)(JWErrorCode errorCode))completionBlock;


//捏合手势
- (void)pinch:(UIPinchGestureRecognizer *)recognizer;
//移动手势
- (void)handleSwipe:(UIPanGestureRecognizer *)gesture;



/**
 JWStream 取流并播放 根据"通道"进行播放的播放接口

 @param videoType 播放类型
 @param bIsEncrypt 是否加密
 @param key 加密的key
 @param completionBlock 回调
 @return 回调结构
 */
- (NSOperationQueue *)JWStreamPlayerManagePlayVideoWithVideoType:(JWVideoTypeStatus)videoType BIsEncrypt:(BOOL)bIsEncrypt Key:(NSString *)key completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;


/**
 *  @since 1.0.0 "通道"查询方式的时间列表查询
 *  根据通道查询录像播放接口
 *  @param recVideoType   录像视频类型
 *  @param beginTime   开始时间
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考JWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
- (NSOperationQueue *)searchChannelPlayBackVideoTimeListRecVideoType:(JWRecVideoTypeStatus)recVideoType                                   beginTime:(NSDate *)beginTime
                        completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock;

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
                                               completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;
@end
