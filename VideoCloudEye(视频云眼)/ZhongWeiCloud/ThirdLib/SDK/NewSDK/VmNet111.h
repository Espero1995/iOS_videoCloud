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
  
  // 连接服务器
  // 入参      sServerAddr：服务器地址；uServerPort：服务器端口；cbUasConnectStatus：uas状态回调
  VMNET_API unsigned CALL_METHOD VmNet_Connect(const char* sServerAddr,
                                               unsigned uServerPort, fUasConnectStatusCallBack cbUasConnectStatus);
  
  // 断开服务器
  VMNET_API void CALL_METHOD VmNet_Disconnect();
  
  // 登录服务器
  // 入参      sLoginName：登录用户名；sLoginPwd：登录密码
  VMNET_API unsigned CALL_METHOD VmNet_Login(const char* sLoginName,
                                             const char* sLoginPwd);
  
  // 登出
  VMNET_API void CALL_METHOD VmNet_Logout();
  
  // 获取行政树列表
  // 入参       uPageNo：当前页数(当前版本入参无效，可以填写任意值); uPageSize：一页大小
  // 出参       pDepTrees：行政树数组指针首地址; pSize：数组长度
  // 返回值详见错误编码头：ErrorCode.h
  VMNET_API unsigned CALL_METHOD VmNet_GetDepTrees(unsigned uPageNo,
                                                   unsigned uPageSize, out TVmDepTree* pDepTrees, out unsigned& uSize);
  
  // 获取通道列表
  // 入参       uPageNo：当前页数(当前版本入参无效，可以填写任意值); uPageSize：一页大小
  // nDepId：若为0，获取所有通道；若不为0，则获取指定行政树下的通道
  // 出参       pChannels：通道数组指针首地址; pSize：数组长度
  // 返回值详见错误编码头：ErrorCode.h
  VMNET_API unsigned CALL_METHOD VmNet_GetChannels(unsigned uPageNo,
                                                   unsigned uPageSize, int nDepId, out TVmChannel* pChannels,
                                                   out unsigned& uSize);
  
  // 获取录像列表
  // 入参       uPageNo：当前页数(当前版本入参无效，可以填写任意值); uPageSize：一页大小
  // sFdId：设备id； nChannelId：通道id； uBeginTime：起始时间，单位秒 uEndTime：截止时间，单位秒； bIsCenter：是否是中心录像
  // 出参       pChannels：通道数组指针首地址    pSize：数组长度
  // 返回值详见错误编码头：ErrorCode.h
  VMNET_API unsigned CALL_METHOD VmNet_GetRecords(unsigned uPageNo,
                                                  unsigned uPageSize, const char* sFdId, int nChannelId, unsigned uBeginTime,
                                                  unsigned uEndTime, bool bIsCenter, out TVmRecord* pRecords,
                                                  out unsigned& uSize);
  
  // 获取历史报警列表
  // 入参       uPageNo：当前页数(当前版本入参无效，可以填写任意值); uPageSize：一页大小
  // sFdId：设备id； nChannelId：通道id； uChannelBigType：通道大类 1：视频输入 5:报警输入；
  // sBeginTime：起始时间，格式 2000-03-04 00:00:00； sEndTime：截止时间，格式同前
  // 出参       pChannels：通道数组指针首地址    pSize：数组长度
  // 返回值详见错误编码头：ErrorCode.h
  VMNET_API unsigned CALL_METHOD VmNet_GetAlarms(unsigned uPageNo,
                                                 unsigned uPageSize, const char* sFdId, int nChannelId,
                                                 unsigned uChannelBigType, const char* sBeginTime, const char* sEndTime,
                                                 out TVmAlarm* pAlarms, out unsigned& uSize);
  
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
  VMNET_API unsigned CALL_METHOD VmNet_OpenRealplayStream(const char* sFdId,
                                                          int nChannelId, bool bIsSub, out unsigned& uMonitorId, out char* sVideoAddr,
                                                          out unsigned& uVideoPort, out char* sAudioAddr, out unsigned& uAudioPort);
  
  // 关闭实时码流
  // 入参    uMonitorId：监控id，打开实时码流时获得
  VMNET_API void CALL_METHOD VmNet_CloseRealplayStream(unsigned uMonitorId);
  
  // 打开回放流地址
  // 入参    sFdId：设备序列号 nChannelId：通道号； bIsCenter：是否为中心录像； beginTime：起始时间； endTime：结束时间
  // 出参    uMonitorId：监控id； sVideoAddr：视频取流地址； uVideoPort：视频取流端口；
  //        sAudioAddr：音频取流地址； uAudioPort：音频取流端口
  VMNET_API unsigned CALL_METHOD VmNet_OpenPlaybackStream(const char* sFdId,
                                                          int nChannelId, bool bIsCenter, unsigned beginTime, unsigned endTime,
                                                          out unsigned& uMonitorId, out char* sVideoAddr, out unsigned& uVideoPort,
                                                          out char* sAudioAddr, out unsigned& uAudioPort);
  
  // 停止回放流
  // 入参    uMonitorId：监控id，打开回放码流时获得； bIsCenter：是否为中心录像
  VMNET_API void CALL_METHOD VmNet_ClosePlaybackStream(unsigned uMonitorId);
  
  // 控制回放
  // 入参    uMonitorId：监控id，打开回放码流时获得； bIsCenter：是否为中心录像
  //        uControlId：控制id； sAction：操作； sParam：参数
  VMNET_API unsigned CALL_METHOD VmNet_ControlPlayback(unsigned uMonitorId, unsigned uControlId, const char* sAction,
                                                       const char* sParam);
  
  // 开始获取码流(获取实时流 或者 获取录像流)
  // 入参    sAddr： uPort cbRealData：码流数据回调函数；cbConnectStatus ；pUser：用户参数
  // 出参    uStreamId：码流id
  VMNET_API unsigned CALL_METHOD VmNet_StartStream(const char* sAddr,
                                                   unsigned uPort, fStreamCallBack cbRealData,
                                                   fStreamConnectStatusCallBack cbConnectStatus, void* pUser,
                                                   out unsigned& uStreamId);
  
  // 停止获取码流
  // 入参    uStreamId：码流id（由开始获取码流时获得）
  VMNET_API void CALL_METHOD VmNet_StopStream(unsigned uStreamId);
  
  // 发送控制指令
  // 入参    sFdId：设备序列号； nChannelId：通道号； uControlType：控制类型（详见VmType.h）； uParm1：参数1； uParm2：参数2
  VMNET_API void CALL_METHOD VmNet_SendControl(const char* sFdId, int nChannelId,
                                               unsigned uControlType, unsigned uParm1, unsigned uParm2);
  
#ifdef __cplusplus
}
#endif

#endif /* VMNET_H_ */
