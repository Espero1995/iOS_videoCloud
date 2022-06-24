//
//  ZWConstants.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
/* JWOpenSDK的错误定义 */
typedef NS_ENUM(NSInteger, JWErrorCode) {
    JW_SUCCESS = 0,//视频成功
    JW_FAILD = -1,//视频播放失败
    JW_SUCCESS_SEARCH_VIDEO_LIST = 560001,//查询视频列表成功
    JW_FAILD_SEARCH_VIDEO_LIST = 560002,//查询视频列表失败
    
    JW_PLAY_NO_PERMISSION = 460001,                   //实时录像无权限
    JW_PLAYBACK_NO_PERMISSION = 460002,               //回放录像无权限
    JW_SEARCH_PLAYBACK_NO_PERMISSION = 460003,        //查询录像无权限
    JW_DEVICE_TTS_TALKING_TIMEOUT = 360002,           //对讲发起超时
    JW_DEVICE_TTS_TALKING = 360010,                   //设备正在对讲中
    JW_DEVICE_IS_PRIVACY_PROTECTING = 380011,         //设备隐私保护中
    JW_DEVICE_CONNECT_COUNT_LIMIT = 380045,           //设备直连取流连接数量过大
    JW_DEVICE_COMMAND_NOT_SUPPORT = 380047,           //设备不支持该命令
    JW_DEVICE_CAS_TALKING = 380077,                   //设备正在对讲中
    JW_DEVICE_CAS_PARSE_ERROR = 380205,               //设备检测入参异常
    JW_PLAY_TIMEOUT = 380209,                         //网络连接超时
    JW_DEVICE_TIMEOUT = 380212,                       //设备端网络连接超时
    JW_STREAM_CLIENT_TIMEOUT = 390038,                //同时`390037`手机网络引起的取流超时
    JW_STREAM_CLIENT_OFFLINE = 395404,                //设备不在线
    JW_STREAM_CLIENT_DEVICE_COUNT_LIMIT = 395410,     //设备连接数过大
    JW_STREAM_CLIENT_NOT_FIND_FILE = 395402,          //回放找不到录像文件，检查传入的回放文件是否正确
    JW_STREAM_CLIENT_TOKEN_INVALID = 395406,          //取流token验证失效
    JW_STREAM_CLIENT_CAMERANO_ERROR = 395415,         //设备通道错
    JW_STREAM_CLIENT_LIMIT = 395546,                  //设备取流受到限制
    /**
     *  HTTP 错误码
     */
    JW_HTTPS_PARAM_ERROR = 110001,                    //请求参数错误
    JW_HTTPS_ACCESS_TOKEN_INVALID = 110002,           //AccessToken无效
    JW_HTTPS_REGIST_USER_NOT_EXSIT = 110004,          //注册用户不存在
    JW_HTTPS_USER_BINDED = 110012,                    //第三方账户与萤石账号已经绑定
    JW_HTTPS_APPKEY_IS_NULL = 110017,                 //AppKey不存在
    JW_HTTPS_APPKEY_NOT_MATCHED = 110018,             //AppKey不匹配，请检查服务端设置的appKey是否和SDK使用的appKey一致
    JW_HTTPS_CAMERA_NOT_EXISTS = 120001,              //通道不存在，请检查摄像头设备是否重新添加过
    JW_HTTPS_DEVICE_NOT_EXISTS = 120002,              //设备不存在
    JW_HTTPS_DEVICE_NETWORK_ANOMALY = 120006,         //网络异常
    JW_HTTPS_DEVICE_OFFLINE = 120007,                 //设备不在线
    JW_HTTPS_DEIVCE_RESPONSE_TIMEOUT = 120008,        //设备请求响应超时异常
    JW_HTTPS_ILLEGAL_DEVICE_SERIAL = 120014,          //不合法的序列号
    JW_HTTPS_DEVICE_STORAGE_FORMATTING = 120016,      //设备正在格式化磁盘
    JW_HTTPS_DEVICE_ADDED_MYSELF = 120017,            //同时`120020`设备已经被自己添加
    JW_HTTPS_USER_NOT_OWN_THIS_DEVICE = 120018,       //该用户不拥有该设备
    JW_HTTPS_DEVICE_ONLINE_NOT_ADDED = 120021,        //设备在线，未被用户添加
    JW_HTTPS_DEVICE_ONLINE_IS_ADDED = 120022,         //设备在线，已经被别的用户添加
    JW_HTTPS_DEVICE_OFFLINE_NOT_ADDED = 120023,       //设备不在线，未被用户添加
    JW_HTTPS_DEVICE_OFFLINE_IS_ADDED = 120024,        //设备不在线，已经被别的用户添加
    JW_HTTPS_DEVICE_OFFLINE_IS_ADDED_MYSELF = 120029, //设备不在线，但是已经被自己添加
    JW_HTTPS_OPERATE_LEAVE_MSG_FAIL = 120202,         //操作留言消息失败
    JW_HTTPS_DEVICE_BUNDEL_STATUS_ON = 120031,        //同时`106002`错误码也是，设备开启了终端绑定，请到萤石云客户端关闭终端绑定
    JW_HTTPS_SERVER_DATA_ERROR = 149999,              //数据异常
    JW_HTTPS_SERVER_ERROR = 150000,                   //服务器异常
    JW_HTTPS_DEVICE_PTZ_NOT_SUPPORT = 160000,         //设备不支持云台控制
    JW_HTTPS_DEVICE_PTZ_NO_PERMISSION = 160001,       //用户没有权限操作云台控制
    JW_HTTPS_DEVICE_PTZ_UPPER_LIMIT = 160002,         //云台达到上限位（顶部）
    JW_HTTPS_DEVICE_PTZ_FLOOR_LIMIT = 160003,         //云台达到下限位（底部）
    JW_HTTPS_DEVICE_PTZ_LEFT_LIMIT = 160004,          //云台达到左限位（最左边）
    JW_HTTPS_DEVICE_PTZ_RIGHT_LIMIT = 160005,         //云台达到右限位（最右边）
    JW_HTTPS_DEVICE_PTZ_FAILED = 160006,              //云台操作失败
    JW_HTTPS_DEVICE_PTZ_RESETING = 160009,            //云台正在调用预置点
    JW_HTTPS_DEVICE_COMMAND_NOT_SUPPORT = 160020,     //设备不支持该命令
    
    /**
     *  接口 错误码(SDK本地校验)
     */
    JW_SDK_PARAM_ERROR = 400002,                      //接口参数错误
    JW_SDK_NOT_SUPPORT_TALK = 400025,                 //设备不支持对讲
    JW_SDK_TIMEOUT = 400034,                          //无播放token，请stop再start播放器
    JW_SDK_NEED_VALIDATECODE = 400035,                //需要设备验证码
    JW_SDK_VALIDATECODE_NOT_MATCH = 400036,           //设备验证码不匹配
    JW_SDK_DECODE_TIMEOUT = 400041,                   //解码超时，可能是验证码错误
    JW_SDK_STREAM_TIMEOUT = 400015,                   //取流超时,请检查手机网络
    JW_SDK_PLAYBACK_STREAM_TIMEOUT = 400409,          //回放取流超时,请检查手机网络
};

/* WiFi配置设备状态 */
typedef NS_ENUM(NSInteger, JWifiConfigStatus) {
    DEVICE_WIFI_CONNECTING = 1,   //设备正在连接WiFi
    DEVICE_WIFI_CONNECTED = 2,    //设备连接WiFi成功
    DEVICE_PLATFORM_REGISTED = 3, //设备注册平台成功
    DEVICE_ACCOUNT_BINDED = 4     //设备已经绑定账户
};

/* 设备告警状态枚举类型 */
typedef NS_ENUM(NSInteger, JWAlarmTypesStatus){
    JWAlarmTypesStatusOn = 1,//活动检测
};
/* 设备布防状态枚举类型 */
typedef NS_ENUM(NSInteger, JWDefenceStatus) {
    JWDefenceStatusOffOrSleep     = 0,  //撤防状态
    JWDefenceStatusOn             = 1,  //布防状态
};
/* 设备升级状态状态 */
typedef NS_ENUM(NSInteger, JWDeviceUpdateStatus) {
    JWDeviceUpdateStatusLoading = 0,   //设备升级中
    JWDeviceUpdateStatusRestart = 1, //设备重启
    JWDeviceUpdateStatusSuccess = 2,//设备升级成功
    JWDeviceUpdateStatusFaild = 3,//升级失败
};
/* 实时播放视频状态枚举类型 */
typedef NS_ENUM(NSInteger,JWVideoTypeStatus){
    JWVideoTypeStatusHd = 0,//高清
    JWVideoTypeStatusNomal = 1,//标清
    JWVideoTypeStatusFluency = 2,//流畅
};

/* 回放播放视频状态枚举类型 */
typedef NS_ENUM(NSInteger,JWRecVideoTypeStatus){
    JWRecVideoTypeStatusCenter = 0,//云存录像
    JWRecVideoTypeStatusLeading = 1,//设备【SD卡】录像
};

/* 开始。停止录像状态枚举类型 */
typedef NS_ENUM(NSInteger,JWRecVideoEnableTypeStatus){
    JWRecVideoEnableTypeStatusEnd = 0,//停止
    JWRecVideoEnableTypeStatusBegin = 1,//开始
};
///常量类
@interface JWConstants : NSObject

@end
