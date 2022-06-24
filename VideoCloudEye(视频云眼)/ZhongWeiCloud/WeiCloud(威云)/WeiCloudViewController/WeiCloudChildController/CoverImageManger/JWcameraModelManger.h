//
//  JWcameraModelManger.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDSingleton.h"

@interface JWcameraModelManger : NSObject
HDSingletonH(JWcameraModelManger)

typedef void (^ _Nullable Success)(id  responseObject);     // 成功Block
typedef void (^ _Nullable Failure)(NSError * _Nullable error);        // 失败Blcok
typedef void (^ _Nullable deviceCaptureReslult)(BOOL reslut);     // 设备抓图返回值
typedef deviceCaptureReslult (^ _Nullable deviceCaptureBlock)(NSMutableDictionary * _Nullable postDic, NSString * _Nullable bIsEncryptStr,NSString * _Nullable key);//设备抓图参数block
@property (nonatomic,assign)BOOL bIsEncrypt;/**<图片是否加密*/
@property (nonatomic, copy) NSString * _Nullable key;/**<加密的key*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;/**<解码器*/


/**
 为model设置封面的设备抓图的图片，只需要在刷新获取model的时候调用即可。
 */
- (void)setCameraDeviceConverImageSuccess:(Success)success Failure:(Failure)failure;

/**
 根据index来获取cameraModel里面的对应的设备抓图图片

 @param index index
 @return 图片
 */
- (UIImage *_Nullable)getCameraDeviceConverImageIndex:(NSInteger)index;
@end
