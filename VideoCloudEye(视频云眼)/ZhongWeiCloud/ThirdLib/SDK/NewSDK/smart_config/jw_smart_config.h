//
// Created by zhou rui on 2017/11/9.
//

#ifndef JW_SMART_CONFIG_H
#define JW_SMART_CONFIG_H

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif


int JWSmart_config(const char *wifiSsid, const char *wifiPwd, int64_t packetIntervalMillis,
                    int64_t waitIntervalMillis);

void JWSmart_stop();

#ifdef __cplusplus
}
#endif

#endif //VMSDKDEMO_ANDROID_SMART_CONFIG_H
