//
// Created by zhou rui on 2017/11/26.
//

#ifndef ZRDREAM_ZRTMP_JW_RTMP_H
#define ZRDREAM_ZRTMP_JW_RTMP_H

#include <stdint.h>

#include "../util/jw_type.h"

#ifdef __cplusplus
extern "C"
{
#endif

// rtmp读取器句柄 >= 0
#define JWRTMPReaderHandle int32_t

void JWRTMP_LogEnable(int enable);

// 创建读取器上下文
JWRTMPReaderHandle JWRTMPReader_Create();

// 释放读取器
void JWRTMPReader_Release(JWRTMPReaderHandle rtmpReaderHandle);

// 通过url建立连接 linkTimeout 连接超时时间（秒）
int JWRTMPReader_Connect(JWRTMPReaderHandle rtmpReaderHandle, const char *url,
                         fJWResultCallBack resultCallBack, void *user, int linkTimeout);

// 关闭码流
void JWRTMPReader_Close(JWRTMPReaderHandle rtmpReaderHandle);

// 是否连接
int JWRTMPReader_IsConnected(JWRTMPReaderHandle rtmpReaderHandle);

// 取流 seekTime 播放开始时间 实时流：-1000 文件流：0开始
int JWRTMPReader_Play(JWRTMPReaderHandle rtmpReaderHandle,
                      fJWConnectStreamCallBack connectStreamCallBack,
                      fJWVideoTagCallBack videoTagCallBack,
                      fJWAudioTagCallBack audioTagCallBack,
                      fJWFlowInfoCallBack flowInfoCallBack,
                      void *user, int seekTime);

// 定位（暂不支持）
int JWRTMPReader_Seek(JWRTMPReaderHandle rtmpReaderHandle, int seekTime,
                      fJWResultCallBack resultCallBack, void *user);

// 暂停或继续 doPause  1:暂停  0:继续
int JWRTMPReader_Pause(JWRTMPReaderHandle rtmpReaderHandle, int doPause,
                       fJWResultCallBack resultCallBack, void *user);

#ifdef __cplusplus
}
#endif

#endif //RTMPLIB_JW_RTMP_H
