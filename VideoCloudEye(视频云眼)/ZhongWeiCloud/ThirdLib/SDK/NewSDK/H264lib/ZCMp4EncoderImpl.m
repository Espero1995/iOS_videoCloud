//
//  ZCMp4EncoderImpl.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/11/23.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "ZCMp4EncoderImpl.h"
@import VideoToolbox;
@import AVFoundation;

@implementation ZCMp4EncoderImpl

static void compressionOutputCallback(void * CM_NULLABLE outputCallbackRefCon, void * CM_NULLABLE sourceFrameRefCon,
                                      OSStatus status,
                                      VTEncodeInfoFlags infoFlags,
                                      CM_NULLABLE CMSampleBufferRef sampleBuffer ) {
    if (status != noErr) {
        NSLog(@"%s with status(%d)", __FUNCTION__, status);
        return;
    }
    if (infoFlags == kVTEncodeInfo_FrameDropped) {
        NSLog(@"%s with frame dropped.", __FUNCTION__);
        return;
    }
    /* ------ 辅助调试 ------ */
    CMFormatDescriptionRef fmtDesc = CMSampleBufferGetFormatDescription(sampleBuffer);    CFDictionaryRef extensions = CMFormatDescriptionGetExtensions(fmtDesc);    NSLog(@"extensions = %@", extensions);
    CMItemCount count = CMSampleBufferGetNumSamples(sampleBuffer);    NSLog(@"samples count = %d", count);    /* ====== 辅助调试 ====== */
    // 推流或写入文件
}
- (void)mp4Encoder:(CVPixelBufferRef)buffer
{
    // 获取摄像头输出图像的宽高
    size_t width = CVPixelBufferGetWidth(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);
    static VTCompressionSessionRef compressionSession;
    OSStatus status =  VTCompressionSessionCreate(NULL,
                                                  width, height,
                                                  kCMVideoCodecType_MPEG4Video,
                                                  NULL,
                                                  NULL,
                                                  NULL, &compressionOutputCallback, NULL, &compressionSession);

}
@end
