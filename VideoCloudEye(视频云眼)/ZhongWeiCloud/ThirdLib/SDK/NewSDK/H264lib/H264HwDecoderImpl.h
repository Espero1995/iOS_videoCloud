//
//  H264HwDecoderImpl.h
//  ShiPinHuiYi
//
//  Created by 徐杨 on 16/3/31.
//  Copyright (c) 2016年 feiyuxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVSampleBufferDisplayLayer.h>


@protocol H264HwDecoderImplDelegate <NSObject>

- (void)displayDecodedFrame:(CVImageBufferRef)imageBuffer;


@end

@interface H264HwDecoderImpl : NSObject

@property (nonatomic,assign)BOOL bIsEncrypt;

@property (nonatomic, copy) NSString * key;     

@property (nonatomic,assign)BOOL DecoderNeedSpeedUp;

@property (weak, nonatomic) id<H264HwDecoderImplDelegate> delegate;

/*是否需要H265解码器*/
/**
 * @brief 是否需要H265解码器
 * @description 这个参数至关重要:因为此解码器已包含H264和265两部分解码功能 通过ZCVideoManager.mm类 中返回的数据包的回调方法
     JWStreamVideoTagCallBack(int32_t handle, const JWVideoTag *videoTag, void *user)方法中videoTag->codecId属性值来判断是H264还是H265
    codecId == 7 为H264 此BOOL置为NO / codecId == 8 为H265 此BOOL置为YES
    根据此BOOL值来做H264和H265的不同初始化
 *  H264与H265本质上没有太大的区别，其主要需处理 头部的信息 以及解码器的初始化，可参考此文章：https://www.jianshu.com/p/d1800fdd3935
 */
@property (nonatomic, assign)BOOL isNeedH265Decoder;



/**
 * @brief 外部调用传入H264数据帧以及大小
 * @param frame 数据帧
 * @param frameSize 帧长
 */
-(void)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize;
@end
