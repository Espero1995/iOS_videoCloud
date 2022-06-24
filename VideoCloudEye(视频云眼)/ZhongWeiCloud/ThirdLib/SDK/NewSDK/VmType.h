/*
 * VmType.h
 *
 *  Created on: 2016年10月18日
 *      Author: zhourui
 */

#ifndef VMTYPE_H_
#define VMTYPE_H_

#define VMNET_API
#define CALL_METHOD
#define CALLBACK
#define VMNET_OUT

// 实时报警回调  报警类型
#define VMNET_ALARM_TYPE_EXTERNEL 1  // 外部告警
#define VMNET_ALARM_TYPE_DETECTION 2  // 移动侦测
#define VMNET_ALARM_TYPE_LOST 3  // 视频丢失
#define VMNET_ALARM_TYPE_MASKING 4  // 视频遮盖

// 码流回调  码流数据类型
#define VMNET_STREAM_TYPE_FIX 0  // 混合流
#define VMNET_STREAM_TYPE_VIDEO 1  // 视频流
#define VMNET_STREAM_TYPE_AUDIO 2  // 音频流

// 录像回放控制
#define VMNET_CONTROLID_DEFAULT 0  // 默认控制id
#define VMNET_ACTION_PLAY "PLAY"  // 播放／继续  param:""
#define VMNET_ACTION_PAUSE "PAUSE"  // 暂停 param:""
#define VMNET_ACTION_POS "POS"  // 定位到某个时间 param:起止时间内的时间点，单位秒
#define VMNET_ACTION_SPEED "SPEED"  // 播放速度 param:播放倍率，支持 0.125, 0.25, 0.5, 1, 2, 4, 8

// 控制指令
#define VMNET_CONTROL_TYPE_PTZ_STOP 0  // 停止云台。参数1、2保留
#define VMNET_CONTROL_TYPE_PTZ_UP 1  // 云台向上转动。参数1为速度值，速度值范围：0-10；参数2为自动停止时间，单位秒
#define VMNET_CONTROL_TYPE_PTZ_DOWN 2  // 向下
#define VMNET_CONTROL_TYPE_PTZ_LEFT 3  // 向左
#define VMNET_CONTROL_TYPE_PTZ_RIGHT 4  // 向右
#define VMNET_CONTROL_TYPE_PTZ_LEFT_UP 5  // 向左上
#define VMNET_CONTROL_TYPE_PTZ_RIGHT_UP 6  // 向右上
#define VMNET_CONTROL_TYPE_PTZ_LEFT_DOWN 7  // 向左下
#define VMNET_CONTROL_TYPE_PTZ_RIGHT_DOWN 8  // 向右下
#define VMNET_CONTROL_TYPE_IRIS_OPEN 20  // 增加光圈。参数1为速度值，速度值范围：0-10；参数2为自动停止时间，单位秒
#define VMNET_CONTROL_TYPE_IRIS_CLOSE 21  // 减少光圈
#define VMNET_CONTROL_TYPE_ZOOM_WIDE 30  // 缩镜头。参数1为速度值，速度值范围：0-10；参数2为自动停止时间，单位秒
#define VMNET_CONTROL_TYPE_ZOOM_IN 31  // 伸镜头
#define VMNET_CONTROL_TYPE_FOCUS_FAR 40  // 增加焦距。参数1为速度值，速度值范围：0-10；参数2为自动停止时间，单位秒
#define VMNET_CONTROL_TYPE_FOCUS_NEAR 41  // 减少焦距
#define VMNET_CONTROL_TYPE_PRE_POINT_ADD 50  // 增加预置点。参数1为预置点号，从1开始编号。
#define VMNET_CONTROL_TYPE_PRE_POINT_DEL 51  // 删除预置点
#define VMNET_CONTROL_TYPE_PRE_POINT_GOTO 52  // 转到预置点
#define VMNET_CONTROL_TYPE_PRE_POINT_AUTO_SCAN_START    82  // 开始自动扫描
#define VMNET_CONTROL_TYPE_PRE_POINT_AUTO_SCAN_STOP 83  // 结束自动扫描
#define VMNET_CONTROL_TYPE_SYN_TIME 0x2000  // 同步时间
#define VMNET_CONTROL_TYPE_IMAGE_BRIGHTNESS 0X1000  // 设置图像亮度。参数1为亮度值，参数2保留
#define VMNET_CONTROL_TYPE_IMAGE_SATURATION 0X1001  // 设置图像饱和度。参数1为饱和度值，参数2保留
#define VMNET_CONTROL_TYPE_IMAGE_CONTRAST 0X1002  // 设置图像对比度。参数1为对比度值，参数2保留
#define VMNET_CONTROL_TYPE_IMAGE_HUE 0X1003  // 设置图像色度。参数1为色度值，参数2保留

// 心跳类型
#define VMNET_HEARTBEAT_TYPE_REALPLAY 0  // 实时流心跳
#define VMNET_HEARTBEAT_TYPE_PLAYBACK 1  // 录像回放心跳
#define VMNET_HEARTBEAT_TYPE_TALK 2  // 语音对讲心跳

// 播放类型
#define VMNET_PLAY_TYPE_REALPLAY 1  // 实时
#define VMNET_PLAY_TYPE_PLAYBACK 2  // 回放

// 客户端类型
#define VMNET_CLIENT_TYPE_ANDROID 100  // android
#define VMNET_CLIENT_TYPE_IOS 200  // ios
#define VMNET_CLIENT_TYPE_PC 300  // pc

// 回调函数定义开始---------------------------------------------------------
// 实时报警回调函数
// pFdId：设备id； nChannel：通道号； uAlarmType：报警类型； uParam1：参数1； uParam2：参数2
typedef void (CALLBACK *fRealAlarmCallBack)(const char *pFdId, int nChannelId,
                                            unsigned uAlarmType, unsigned uParam1,
                                            unsigned uParam2);

// uas连接状态回调函数
// bIsConnected：true 已连接  false 断开
typedef void (CALLBACK *fUasConnectStatusCallBack)(bool bIsConnected);

// 码流回调函数
// uStreamId：码流id； uStreamType：数据类型； payloadType：码流承载类型；pBuffer：数据指针；
// nLen：数据长度； uTimeStamp：时间戳； pUser：用户参数；sequenceNumber：序列号；isMark：是否是结束
typedef void (CALLBACK *fStreamCallBack)(unsigned uStreamId,
                                         unsigned uStreamType, char payloadType, char *pBuffer,
                                         int nLen,
                                         unsigned uTimeStamp, unsigned short sequenceNumber,
                                         bool isMark, void *pUser);

typedef void (CALLBACK *fStreamCallBackExt)(unsigned uStreamId, unsigned uStreamType, char payloadType,
                                         char *pBuffer, int nLen, unsigned uTimeStamp,
                                         unsigned short sequenceNumber, bool isMark, bool isJWHeader,
                                         bool isFirstFrame, bool isLastFrame, unsigned long long utcTimeStamp, void *pUser);

// stream码流连接状态回调
// uStreamId：码流id； bIsConnected：true 已连接 false 断开； pUser：用户参数
typedef void (CALLBACK *fStreamConnectStatusCallBack)(unsigned uStreamId,
                                                      bool bIsConnected, void *pUser);

// 原始码流回调函数
// pStreamData：数据指针；uStreamLen：数据长度;pUser：用户参数
typedef void (CALLBACK *fStreamCallBackV2)(const char *pStreamData, unsigned uStreamLen,
                                           void *pUser);

// 原始码流回调函数
// pStreamData：数据指针；uStreamLen：数据长度;pUser：用户参数
typedef void (CALLBACK *fStreamCallBackV3)(const char *sRemoteAddr,
                                           unsigned short usRemotePort, const char *pStreamData,
                                           unsigned uStreamLen, void *pUser);

// stream码流连接状态回调
// uStreamId：码流id； bIsConnected：true 已连接 false 断开； pUser：用户参数
typedef void (CALLBACK *fStreamConnectStatusCallBackV2)(bool bIsConnected, void *pUser);
// 回调函数定义结束---------------------------------------------------------

// 数据结构定义开始---------------------------------------------------------
// 行政树
typedef struct VmDepTree {
    int nDepId;
    char sDepName[64];
    int nParentId;
    unsigned uOnlineChannelCounts;
    unsigned uOfflineChannelCounts;
} TVmDepTree;

// 视频通道
typedef struct VmChannel {
    int nDepId;
    char sFdId[32];
    int nChannelId;
    unsigned uChannelType;
    char sChannelName[64];
    unsigned uIsOnLine;
    unsigned uVideoState;
    unsigned uChannelState;
    unsigned uRecordState;
} TVmChannel;

// 录像文件
typedef struct VmRecord {
    unsigned uBeginTime;
    unsigned uEndTime;
    char sPlaybackUrl[256];
    char sDownloadUrl[256];
} TVmRecord;

// 历史报警
typedef struct VmAlarm {
    char sAlarmId[40];
    char sFdId[32];
    char sFdName[64];
    int nChannelId;
    char sChannelName[64];
    unsigned uChannelBigType;
    char sAlarmTime[40];
    unsigned uAlarmCode;
    char sAlarmName[64];
    char sAlarmSubName[64];
    unsigned uAlarmType;
    char sPhotoUrl[256];
} TVmAlarm;
// 数据结构定义结束---------------------------------------------------------

#endif /* VMTYPE_H_ */
