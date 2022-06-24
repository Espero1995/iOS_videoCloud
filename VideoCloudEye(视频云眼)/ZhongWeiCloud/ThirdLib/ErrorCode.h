/*
 * ErrorCode.h
 *
 *  Created on: 2016年9月28日
 *      Author: zhourui
 *      平台sdk返回错误码定义
 */

#ifndef ERRORCODE_H_
#define ERRORCODE_H_

// 错误码
const unsigned ERR_CODE_OK = 0;  // 成功
const unsigned ERR_CODE_SESSION_NOEXIST = 0x0004;  // session不存在
const unsigned ERR_CODE_SDK_UNINIT = 0xf001;  // sdk未初始化
const unsigned ERR_CODE_SDK_STARTUP_FAILED = 0xf002;  // sdk启动失败
const unsigned ERR_CODE_NO_CONNECT = 0xf003;  // 未连接服务器
const unsigned ERR_CODE_TIMEOUT_ERR = 0xf004;  // 超时
const unsigned ERR_CODE_SEND_FAILED = 0xf005;  // 发送失败
const unsigned ERR_CODE_CREATE_STREAM_THREAD_FAILED = 0xf006;  // 创建码流线程失败
const unsigned ERR_CODE_PARAM_ILLEGAL = 0xf009;  // 参数非法

// 登录错误
const unsigned ERR_CODE_ACCESS_DBMS_FAILED = 0x0226;  // 访问dbms错误
const unsigned ERR_CODE_UNKOWN_ERR = 0x0227;  // 未知错误
const unsigned ERR_CODE_USER_NO_EXIST = 0x0228;  // 用不存在
const unsigned ERR_CODE_NEED_USB = 0x0229;  // 需要usb
const unsigned ERR_CODE_NEED_SMS = 0x022a;  // 需要短信
const unsigned ERR_CODE_SMS_ERR = 0x022b;  // 短信错误
const unsigned ERR_CODE_ACCOUNT_OR_PWD_ERR = 0x022c;  // 用户名或密码错误
const unsigned ERR_CODE_DB_ERR = 0x022d;  // 数据库错误
const unsigned ERR_CODE_GEN_ERR = 0x00ff;  // 一般错误


#endif /* PACKETMSGTYPE_H_ */
