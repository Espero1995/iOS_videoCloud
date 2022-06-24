/*
* jw_cipher.h
*
*  Created on: 2017年7月17日
*      Author: zhourui
*/

#ifndef JW_CIPHER_H_
#define JW_CIPHER_H_

#define JW_CIPHER_CTX void*

#ifdef _WINDLL
#define API_DECL __declspec(dllexport)
#pragma message("dllexport")
#else
#define API_DECL
#if (defined _WIN32) && (!defined _STATIC)
#pragma comment(lib,"JWCipher.lib")
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

	/**
	* 创建加密器
	* key_str:唯一字符串 设备与后台协商的设备唯一字符串
	* key_len:字符串长度
	* 返回:加密器上下文
	*/
	API_DECL JW_CIPHER_CTX jw_cipher_create(const unsigned char* key_str, size_t key_len);

	/**
	* 释放加密器
	* ctx:加密器上下文
	*/
	API_DECL void jw_cipher_release(JW_CIPHER_CTX ctx);

	/**
	* 加密h264
	* ctx:加密器上下文
	* input_data:数据
	* input_data_len:数据长度
	* 加密后数据覆盖原有数据，长度不改变
	*/
	API_DECL void jw_cipher_encrypt_h264(JW_CIPHER_CTX ctx, unsigned char* input_data, size_t input_data_len);

	/**
	* 解密h264
	* ctx:加密器上下文
	* input_data:数据
	* input_data_len:数据长度
	* 解密后数据覆盖原有数据，长度不改变
	*/
	API_DECL void jw_cipher_decrypt_h264(JW_CIPHER_CTX ctx, unsigned char* input_data, size_t input_data_len);




	/**
	* 提前得知加密完整数据后的数据长度，可用作判断已分配的内存大小是否足够，可不调用
	* input_data_len:加密前长度
	* 返回值:加密后数据长度
	*/
	API_DECL size_t jw_cipher_encrypt_output_len(size_t input_data_len);

	/**
	* 加密完整数据
	* ctx:加密器上下文
	* input_data:输入数据
	* input_data_len:输入数据长度
	* output_data:输出数据缓存
	* output_data_len:输出数据缓存大小，调用后会赋值为实际加密后长度
	* 返回值:1 成功  0 失败
	* 注意:需传入足够大小的输出数据缓存，需要内存大小可调用 jw_cipher_encrypt_byte_output_len(input_data_len) 获得
	*/
	API_DECL int jw_cipher_encrypt(JW_CIPHER_CTX ctx, const unsigned char* input_data, size_t input_data_len, unsigned char* output_data, size_t* output_data_len);

	/**
	* 解密完整数据
	* ctx:加密器上下文
	* input_data:输入数据
	* input_data_len:输入数据长度，被加密后的长度必为16的倍数，若输入数据长度不是16倍数则解密失败
	* output_data:输出数据缓存
	* output_data_len:输出数据缓存大小，调用后会赋值为实际解密后长度
	* 返回值:1 成功  0 失败
	* 注意:需传入足够大小的输出数据缓存，需要的内存大小等于数据数据大小
	*/
	API_DECL int jw_cipher_decrypt(JW_CIPHER_CTX ctx, const unsigned char* input_data, size_t input_data_len, unsigned char* output_data, size_t* output_data_len);



	/**
	 * 视云密码转换 一般将密码转换后传输 防止原密码明文被暴露
	 * input_pass:输入字符串
	 * input_pass_len:输入字符串长度
	 * output_pass:输出字符串
	 * output_pass_len:输出字符串长度，当前版本必为22
	 * 返回值:1 成功  0 失败
	 */
	API_DECL int jw_cipher_cloud_pass(const char* input_pass, size_t input_pass_len, char* output_pass, size_t* output_pass_len);

#ifdef __cplusplus
}
#endif

#endif /* JW_CIPHER_H_ */
