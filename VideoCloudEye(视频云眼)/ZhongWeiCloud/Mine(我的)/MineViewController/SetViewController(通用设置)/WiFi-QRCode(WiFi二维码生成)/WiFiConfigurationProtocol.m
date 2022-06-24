//
//  WiFiConfigurationProtocol.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WiFiConfigurationProtocol.h"

@implementation WiFiConfigurationProtocol


+ (NSString *)base64WifiCalculate:(NSString *)ssidStr andPwd:(NSString *)pwdStr;
{
    /*
    NSString *ssidStr111 = @"Xiaomi_zr";
    NSString *passwordStr111 = @"123456789";
    */
//
   unsigned char* ssid = [ssidStr cStringUsingEncoding:NSUTF8StringEncoding];
   unsigned char* password = [pwdStr cStringUsingEncoding:NSUTF8StringEncoding];


     unsigned char temp[256] = {0};

    long len = 0;
    long ssidLen = strlen(ssid);
    long pwdLen = strlen(password);
   // NSLog(@"ssidLen:%ld===pwdLen:%ld",ssidLen,pwdLen);
    // 1.ssid 字符的长度
    temp[0] = ssidLen;
    // 2.密码的长度
    temp[1] = pwdLen;
    
   // NSLog(@"temp0:%hhd;temp1:%hhd",temp[0],temp[1]);
    
    // 3.计算ssid的累加和
    temp[2] = 0;
    for (int i = 0; i < ssidLen; i++) {
        temp[2] += ssid[i];
        //NSLog(@"temp[2]:%c===ssid[i]:%c",temp[2],ssid[i]);
    }
     //NSLog(@"temp[2]=====%c",temp[2]);
    
    // 4.计算password的累加和
    temp[3] = 0;
    for (int i = 0; i < pwdLen; i++) {
        temp[3] += password[i];
        //NSLog(@"temp[3]:%d==password[i]:%d",temp[3],password[i]);
    }
      //NSLog(@"temp[3]=====%d",temp[3]);
    
    
    // 5.把 ssid 和 password 高 4 字节和低 4 字节进行颠倒后拷贝
    for (int i = 0; i<strlen(ssid); i++)
    {
        temp[4 + i] += (((unsigned char)ssid[i] & 0xF )<< 4) | (((unsigned char)ssid[i] & 0xF0 )>> 4);
    }
    //    NSLog(@"temp[4]=====%d",temp[4]);

    for (int i = 0; i<strlen(password); i++)
    {
        temp[4 + strlen(ssid) + i] += (((unsigned char)password[i] & 0xF) << 4) | (((unsigned char)password[i] & 0xF0) >> 4);
    }
    //    NSLog(@"temp[4]=====%d",temp[4]);

    
   // size_t str_len = strlen(temp);
    for (int i = 0; i < 256; ++i) {
       // NSLog(@"tmp[%d] : %d %x %c",i,temp[i], temp[i], temp[i]);
    }
    
    len = ssidLen+pwdLen+4;
   // NSLog(@"temp:%s",temp);

    NSData *adata = [[NSData alloc] initWithBytes:temp length:len];
    
    NSData *base64Data = [adata base64EncodedDataWithOptions:0];
    
    NSString *baseString = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];

    NSLog(@"base64String:%@",baseString);

    return baseString;
}

@end
