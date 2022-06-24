/*
 * VmNet.h
 *
 *  Created on: 2016年10月14日
 *      Author: zhourui
 *      平台通信sdk，主要负责与uas服务端通信和向mrst取流，给上层回调数据
 */

#ifndef VMNET_H_
#define VMNET_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "VmType.h"

// sdk初始化。
// 入参       uMaxThreadCount：最大线程数量，以传入cpu最大线程数量为最佳，能够极大增强程序并发能力
// 返回值     true：初始话成功    false：初始化失败（若已经被初始化，则返回失败）
VMNET_API bool CALL_METHOD VmNet_Init(unsigned uMaxThreadCount);

// sdk反初始化，释放资源
VMNET_API void CALL_METHOD VmNet_UnInit();

// 开启对讲
VMNET_API bool CALL_METHOD VmNet_StartTalk(fStreamCallBackV3 streamCallback, void *pUser);

// 发送对讲数据
VMNET_API bool CALL_METHOD
VmNet_SendTalk(const char *sRemoteAddress, unsigned short usRemotePort, const char *oData,
               unsigned uDataLen);

// 关闭对讲
VMNET_API void CALL_METHOD VmNet_StopTalk();

// 开启心跳服务
VMNET_API bool CALL_METHOD VmNet_StartStreamHeartbeatServer();
// 发送心跳
VMNET_API bool CALL_METHOD
VmNet_SendHeartbeat(const char *sRemoteAddress, unsigned short usRemotePort,
                    unsigned uHeartbeatType,
                    const char *sMonitorId, const char *sSrcId);

// 关闭心跳服务
VMNET_API void CALL_METHOD VmNet_StopStreamHeartbeatServer();

// 连接服务器
// 入参      sServerAddr：服务器地址；uServerPort：服务器端口；cbUasConnectStatus：uas状态回调
VMNET_API unsigned CALL_METHOD VmNet_Connect(const char *sServerAddr,
                                             unsigned uServerPort,
                                             fUasConnectStatusCallBack cbUasConnectStatus);

// 断开服务器
VMNET_API void CALL_METHOD VmNet_Disconnect();

// 登录服务器
// 入参      sLoginName：登录用户名；sLoginPwd：登录密码
VMNET_API unsigned CALL_METHOD VmNet_Login(const char *sLoginName,
                                           const char *sLoginPwd);

// 登出
VMNET_API void CALL_METHOD VmNet_Logout();

// 获取行政树列表
// 入参       uPageNo：当前页数(当前版本入参无效，可以填写任意值); uPageSize：一页大小
// 出参       pDepTrees：行政树数组指针首地址; pSize：数组长度
// 返回值详见错误编码头：ErrorCode.h
VMNET_API unsigned CALL_METHOD VmNet_GetDepTrees(unsigned uPageNo,
                                                 unsigned uPageSize, VMNET_OUT
                                                 TVmDepTree *pDepTrees,
                                                 VMNET_OUT unsigned &uSize);

// 获取通道列表
// 入参       uPageNo：当前页数(当前版本入参无效，可以填写任意值); uPageSize：一页大小
// nDepId：若为0，获取所有通道；若不为0，则获取指定行政树下的通道
// 出参       pChannels：通道数组指针首地址; pSize：数组长度
// 返回值详见错误编码头：ErrorCode.h
VMNET_API unsigned CALL_METHOD VmNet_GetChannels(unsigned uPageNo,
                                                 unsigned uPageSize, int nDepId, VMNET_OUT
                                                 TVmChannel *pChannels,
                                                 VMNET_OUT unsigned &uSize);

// 获取录像列表
// 入参       uPageNo：当前页数(当前版本入参无效，可以填写任意值); uPageSize：一页大小
// sFdId：设备id； nChannelId：通道id； uBeginTime：起始时间，单位秒 uEndTime：截止时间，单位秒； bIsCenter：是否是中心录像
// 出参       pChannels：通道数组指针首地址    pSize：数组长度
// 返回值详见错误编码头：ErrorCode.h
VMNET_API unsigned CALL_METHOD VmNet_GetRecords(unsigned uPageNo,
                                                unsigned uPageSize, const char *sFdId,
                                                int nChannelId, unsigned uBeginTime,
                                                unsigned uEndTime, bool bIsCenter, VMNET_OUT
                                                TVmRecord *pRecords,
                                                VMNET_OUT unsigned &uSize);

// 获取历史报警列表
// 入参       uPageNo：当前页数(当前版本入参无效，可以填写任意值); uPageSize：一页大小
// sFdId：设备id； nChannelId：通道id； uChannelBigType：通道大类 1：视频输入 5:报警输入；
// sBeginTime：起始时间，格式 2000-03-04 00:00:00； sEndTime：截止时间，格式同前
// 出参       pChannels：通道数组指针首地址    pSize：数组长度
// 返回值详见错误编码头：ErrorCode.h
VMNET_API unsigned CALL_METHOD VmNet_GetAlarms(unsigned uPageNo,
                                               unsigned uPageSize, const char *sFdId,
                                               int nChannelId,
                                               unsigned uChannelBigType, const char *sBeginTime,
                                               const char *sEndTime,
                                               VMNET_OUT TVmAlarm *pAlarms, VMNET_OUT
                                               unsigned &uSize);

// 开始接收实时报警
// 入参    cbRealAlarm：实时报警回调函数
VMNET_API void CALL_METHOD VmNet_StartReceiveRealAlarm(
        fRealAlarmCallBack cbRealAlarm);

// 停止接收实时报警
VMNET_API void CALL_METHOD VmNet_StopReceiveRealAlarm();

// 打开实时码流，并获取播放地址
// 入参    sFdId：设备序列号 nChannelId：通道号； bIsSub：是否为子码流
// 出参    uMonitorId：监控id； sVideoAddr：视频取流地址； uVideoPort：视频取流端口；
//        sAudioAddr：音频取流地址； uAudioPort：音频取流端口
VMNET_API unsigned CALL_METHOD VmNet_OpenRealplayStream(const char *sFdId,
                                                        int nChannelId, bool bIsSub, VMNET_OUT
                                                        unsigned &uMonitorId, VMNET_OUT
                                                        char *sVideoAddr,
                                                        VMNET_OUT unsigned &uVideoPort, VMNET_OUT
                                                        char *sAudioAddr, VMNET_OUT
                                                        unsigned &uAudioPort);

// 关闭实时码流
// 入参    uMonitorId：监控id，打开实时码流时获得
VMNET_API void CALL_METHOD VmNet_CloseRealplayStream(unsigned uMonitorId);

// 打开回放流地址
// 入参    sFdId：设备序列号 nChannelId：通道号； bIsCenter：是否为中心录像； beginTime：起始时间； endTime：结束时间
// 出参    uMonitorId：监控id； sVideoAddr：视频取流地址； uVideoPort：视频取流端口；
//        sAudioAddr：音频取流地址； uAudioPort：音频取流端口
VMNET_API unsigned CALL_METHOD VmNet_OpenPlaybackStream(const char *sFdId,
                                                        int nChannelId, bool bIsCenter,
                                                        unsigned beginTime, unsigned endTime,
                                                        VMNET_OUT unsigned &uMonitorId, VMNET_OUT
                                                        char *sVideoAddr, VMNET_OUT
                                                        unsigned &uVideoPort,
                                                        VMNET_OUT char *sAudioAddr, VMNET_OUT
                                                        unsigned &uAudioPort);

// 停止回放流
// 入参    uMonitorId：监控id，打开回放码流时获得； bIsCenter：是否为中心录像
VMNET_API void CALL_METHOD VmNet_ClosePlaybackStream(unsigned uMonitorId);

// 控制回放
// 入参    uMonitorId：监控id，打开回放码流时获得； bIsCenter：是否为中心录像
//        uControlId：控制id； sAction：操作； sParam：参数
VMNET_API unsigned CALL_METHOD VmNet_ControlPlayback(unsigned uMonitorId, unsigned uControlId,
                                                     const char *sAction,
                                                     const char *sParam);

// 开始获取码流(获取实时流 或者 获取录像流)
// 入参    sAddr： uPort cbRealData：码流数据回调函数；cbConnectStatus ；pUser：用户参数
// 出参    uStreamId：码流id
VMNET_API unsigned CALL_METHOD VmNet_StartStream(const char *sAddr,
                                                 unsigned short uPort, fStreamCallBack cbRealData,
                                                 fStreamConnectStatusCallBack cbConnectStatus,
                                                 void *pUser, VMNET_OUT unsigned &uStreamId,
                                                 const char *sMonitorId = nullptr,
                                                 const char *sDeviceId = nullptr,
                                                 int playType = VMNET_PLAY_TYPE_REALPLAY,
                                                 int clientType = VMNET_CLIENT_TYPE_ANDROID);

VMNET_API unsigned CALL_METHOD VmNet_StartStreamExt(const char *sAddr,
                                                 unsigned short uPort, fStreamCallBackExt cbRealData,
                                                 fStreamConnectStatusCallBack cbConnectStatus,
                                                 void *pUser, VMNET_OUT unsigned &uStreamId,
                                                 const char *sMonitorId = nullptr,
                                                 const char *sDeviceId = nullptr,
                                                 int playType = VMNET_PLAY_TYPE_REALPLAY,
                                                 int clientType = VMNET_CLIENT_TYPE_ANDROID);

// 停止获取码流
// 入参    uStreamId：码流id（由开始获取码流时获得）
VMNET_API void CALL_METHOD VmNet_StopStream(unsigned uStreamId);

//VMNET_API bool CALL_METHOD
//VmNet_StartStreamByRtsp(const char *rtspUrl, fStreamCallBackV2 cbRealData,
//                        fStreamConnectStatusCallBackV2 cbStatus, void *pUser, VMNET_OUT
//                        long &rtspStreamHandle, bool encrypt = false);
//
//VMNET_API void CALL_METHOD VmNet_StopStreamByRtsp(long rtspStreamHandle);
//
//VMNET_API bool CALL_METHOD VmNet_PauseStreamByRtsp(long rtspStreamHandle);
//
//VMNET_API bool CALL_METHOD VmNet_PlayStreamByRtsp(long rtspStreamHandle);

VMNET_API unsigned CALL_METHOD
VmNet_StartStreamByRtsp(const char *rtspUrl, fStreamCallBackV2 cbRealData,
                        fStreamConnectStatusCallBackV2 cbStatus, void *pUser, VMNET_OUT
                        unsigned &rtspStreamId, bool encrypt = false);

VMNET_API void CALL_METHOD VmNet_StopStreamByRtsp(unsigned rtspStreamId);

VMNET_API unsigned CALL_METHOD VmNet_PauseStreamByRtsp(unsigned rtspStreamId);

VMNET_API unsigned CALL_METHOD VmNet_PlayStreamByRtsp(unsigned rtspStreamId);

VMNET_API unsigned CALL_METHOD VmNet_SpeedStreamByRtsp(unsigned rtspStreamId, float speed);

VMNET_API bool CALL_METHOD VmNet_StreamIsValid(unsigned streamId);

// 发送控制指令
// 入参    sFdId：设备序列号； nChannelId：通道号； uControlType：控制类型（详见VmType.h）； uParm1：参数1； uParm2：参数2
VMNET_API void CALL_METHOD VmNet_SendControl(const char *sFdId, int nChannelId,
                                             unsigned uControlType, unsigned uParm1,
                                             unsigned uParm2);

// 过滤rtp头
// 入参   inData：原始数据，包含rtp头；inLen：原始数据长度
// 出参   payload：rtp负载数据；payloadLen：rtp负载长度；payloadType：rtp负载类型，可根据该类型判断是视频或音频
VMNET_API bool CALL_METHOD VmNet_FilterRtpHeader(const char *inData, int inLen,
                                                 VMNET_OUT char *payloadData, VMNET_OUT
                                                 int &payloadLen, VMNET_OUT
                                                 int &payloadType, VMNET_OUT int &seqNumber,
                                                 VMNET_OUT int &timestamp, VMNET_OUT bool &isMark);


VMNET_API bool CALL_METHOD VmNet_FilterRtpHeader_EXT(const char *inData, int inLen,
                                                     VMNET_OUT char *payloadData, VMNET_OUT
                                                     int &payloadLen, VMNET_OUT
                                                     int &payloadType, VMNET_OUT int &seqNumber,
                                                     VMNET_OUT int &timestamp, VMNET_OUT
                                                     bool &isMark, VMNET_OUT bool &isJWHeader,
                                                     VMNET_OUT bool &isFirstFrame, VMNET_OUT
                                                     bool &isLastFrame, VMNET_OUT
                                                     uint64_t &utcTimeStamp);


#ifdef __cplusplus
}
#endif

#endif /* VMNET_H_ */
