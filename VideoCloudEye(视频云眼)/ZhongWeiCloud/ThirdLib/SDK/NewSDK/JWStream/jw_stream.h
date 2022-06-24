//
// Created by zhou rui on 2017/11/26.
//
/**
 * 说明:libJWStream.a 此库需要添加到桌面上，并修改Build Setting 目的减少包的体积
 */
#ifndef ZRDREAM_JWSP_JW_RTMP_H
#define ZRDREAM_JWSP_JW_RTMP_H

#include <stdint.h>
//#include "../util/jw_type.h"
#import "jw_type.h"
#ifdef __cplusplus
extern "C"
{
#endif

// >= 0
#define JWSPHandle int32_t

// 创建读取器上下文
JWSPHandle JWStream_Create();

// 释放读取器
void JWStream_Release(JWSPHandle handle);

// 通过url读取码流
int JWStream_Connect(JWSPHandle handle, const char *url, const char *encryptKey,
                   fJWResultCallBack resultCallBack, void *user, int linkTimeout);

void JWStream_Close(JWSPHandle handle);

int JWStream_IsConnected(JWSPHandle handle);

int JWStream_Play(JWSPHandle handle,
                  fJWConnectStreamCallBack connectStreamCallBack,
                  fJWVideoTagCallBack videoTagCallBack,
                  fJWAudioTagCallBack audioTagCallBack,
                  fJWFlowInfoCallBack flowInfoCallBack,
                  void *user, int seekTime);

int JWStream_Seek(JWSPHandle handle, int seekTime,
                fJWResultCallBack resultCallBack, void *user);

int JWStream_Pause(JWSPHandle handle, int doPause,
                 fJWResultCallBack resultCallBack, void *user);

#ifdef __cplusplus
}
#endif

#endif //RTMPLIB_JW_RTMP_H
