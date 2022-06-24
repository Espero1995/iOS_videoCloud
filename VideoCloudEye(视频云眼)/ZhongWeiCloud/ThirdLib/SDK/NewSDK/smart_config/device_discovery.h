//
// Created by zhou rui on 2017/11/10.
//

#ifndef DREAM_DEVICE_DISCOVERY_H
#define DREAM_DEVICE_DISCOVERY_H

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

typedef struct JW_DEVICE_INFO {
    uint8_t product[4];  // 产品标识
    char macId[8];  // 前两字节为0，后6个mac地址
    char obcpVersion;  // 支持的obcp版本号，为10
    char obcpCrypt;  // 支持的obcp密钥编号，缺省为1
    uint16_t obcpPort;  // obcp监听端口
    uint32_t obcpAddr;  // ip地址
    uint32_t netMask;  // 子网掩码
    uint32_t gateWay;  // 缺省网关
    char module[32];  // 设备型号
    char version[32];  // 设备版本
    char serial[32];  // 产品序列号
    char hardware[32];  // 硬件版本
    // 上方有156字节

    // 2017-10-26新增
    char dspVersion[32];  // dsp版本号
    uint32_t bootTime;  // 系统启动时间
    uint8_t support[8];  // 能力集  bit1: 是否支持应答机制; bit2: 是否支持密码重置; bit3: 是否支持http端口; bit4: 是否支持激活
    uint16_t httpPort;  // http端口
    uint8_t activated;  // 是否激活 0-无效, 1-已激活, 2-未激活
    uint8_t resv1;  // 预留
    uint8_t resv2[52];  // 预留
} JWDeviceInfo;

typedef void (*fJWDeviceFindCallBack)(const JWDeviceInfo& deviceInfo);

bool JWDeviceDiscovery_init();

void JWDeviceDiscovery_uninit();

bool JWDeviceDiscovery_start(fJWDeviceFindCallBack deviceFindCallBack);

void JWDeviceDiscovery_stop();

void JWDeviceDiscovery_clearup();

// 设置请求间隔，必须再start前设置才生效
void JWDeviceDiscovery_setAutoRequestInterval(int32_t intervalSec);

#ifdef __cplusplus
}
#endif

#endif //VMSDKDEMO_ANDROID_DEVICE_DISCOVERY_H
