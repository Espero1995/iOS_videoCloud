//
//  H264HwDecoderImpl.m
//  ShiPinHuiYi
//
//  Created by 徐杨 on 16/3/31.
//  Copyright (c) 2016年 feiyuxing. All rights reserved.
//



#import "H264HwDecoderImpl.h"
#import "config.h"
@interface H264HwDecoderImpl()
{
    uint8_t *_sps;/** sps数据 */
    NSInteger _spsSize;/** sps数据长度 */
    uint8_t *_pps;/** pps数据 */
    NSInteger _ppsSize;/** pps数据长度 */
    
    /*这两个参数只有在H265时才需要*/
    uint8_t *_vps;/** vps数据 */
    NSInteger _vpsSize;/** vps数据长度 */
    
    
//    uint8_t *_sei;
//    NSInteger _seiSize;
    VTDecompressionSessionRef _deocderSession;/** 解码器句柄 */
    CMVideoFormatDescriptionRef _decoderFormatDescription;/** 视频解码信息句柄 */
    BOOL ALLSEI_NoIFrame;
    BOOL StartIFrameEncode;
}
@end

@implementation H264HwDecoderImpl


#pragma mark - 外部调用此方法
/**
 * @brief 外部调用传入H264数据帧以及大小
 * @param frame 数据帧
 * @param frameSize 帧长
 */
//- (void)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize
//{
////    int nalu_type = (frame[4] & 0x1F);
//    NSLog(@"naluType:%d",nalu_type);
//    NSString * nalu_typeStr;
//    switch (nalu_type) {
//        case 0x01:nalu_typeStr = @"B/P";
//            break;
//        case 0x05:nalu_typeStr = @"I";
//            break;
//        case 0x06:nalu_typeStr = @"SEI";
//            break;
//        case 0x07:nalu_typeStr = @"SPS";
//            break;
//        case 0x08:nalu_typeStr = @"PPS";
//            break;
//        default:nalu_typeStr = @"B/P";
//            break;
//    }
//    NSLog(@">>>>>>>>>>开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
//    /*
//     if (frameSize < 4) {
//     NSLog(@"frameSize[%d] < 4", frameSize);
//     return;
//     }
//     */
//    // NSLog(@"decodeNalu current Thread:%@",[NSThread currentThread]);
//    // if (nalu_type == 0x00) {
//    // NSLog(@"zrtest【0x00】: 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x", frame[0], frame[1], frame[2], frame[3], frame[4],frame[5], frame[6], frame[7], frame[8], frame[9]);//其他帧
//    // }
//
//    //[unitl writeFrameToH264File:frame FrameSize:frameSize];
//
//    /*
//     CVPixelBufferRef pixelBuffer = NULL;
//     uint32_t nalSize = (uint32_t)(frameSize - 4);
//     uint8_t *pNalSize = (uint8_t*)(&nalSize);
//     frame[0] = *(pNalSize + 3);
//     frame[1] = *(pNalSize + 2);
//     frame[2] = *(pNalSize + 1);
//     frame[3] = *(pNalSize);
//     */
//    //以上写法和下面写法一样可以正常播放。下面一种是调用api，做大端序变化的。
//    uint32_t nalSize = (uint32_t)(frameSize - 4);
//    uint32_t *pNalSize = (uint32_t *)frame;
//    *pNalSize = CFSwapInt32HostToBig(nalSize);
//    // 在buffer的前面填入代表长度的int
//    CVPixelBufferRef pixelBuffer = NULL;
//
//    //传输的时候。关键帧不能丢数据 否则绿屏   B/P可以丢  这样会卡顿
//    switch (nalu_type)
//    {
//        case 0x01:
//        {
//            //  NSLog(@"Nal type is B/P frame");//其他帧
//            // pixelBuffer = [self decode:frame withSize:frameSize];
//            if (!self.DecoderNeedSpeedUp) {
//                //if([self initH264Decoder])
//                {
//                    pixelBuffer = [self decode:frame withSize:frameSize];
//                    //                    NSLog(@"【未】加速播放，丢弃p帧:%s",frame);
//                }
//            }else
//            {
//                NSLog(@"【】加速播放，丢弃p帧");
//            }
//            break;
//        }
//        case 0x05:
//            // NSLog(@"nalu_type:%d Nal type is IDR frame",nalu_type);  //关键帧
//            if([self initH264Decoder])
//            {
//                if (!StartIFrameEncode) {
//                    [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
//                    StartIFrameEncode = YES;
//                    NSLog(@"开始解码i帧，关闭加载动画");
//                }
//                // NSLog(@"解码当前线程2：%@",[NSThread currentThread]);
//                ALLSEI_NoIFrame = NO;
//                //self.DecoderNeedSpeedUp = FALSE;
//                pixelBuffer = [self decode:frame withSize:frameSize];
//            }
//            break;
//        case 0x06:
//
//            // NSLog(@"nalu_type:6,type is SEI");
//            //if([self initH264Decoder])
//            //            {
//            //                ALLSEI_NoIFrame = YES;
//            //                pixelBuffer = [self decode:frame withSize:frameSize];
//            //            }
//            break;
//
//        case 0x07://sps
//            // NSLog(@"nalu_type:%d Nal type is SPS",nalu_type);
//            _spsSize = frameSize - 4;
//            if (!_sps) _sps = malloc(128);//sps 和 pps 最大不会超过128
//            if (_spsSize <= 128)
//            {
//                memcpy(_sps, frame + 4, _spsSize);
//                //pixelBuffer = [self decode:frame withSize:frameSize];
//                //判断是否接受新的sps
//                BOOL isReset  =  VTDecompressionSessionCanAcceptFormatDescription(_deocderSession, _decoderFormatDescription);
//                if (isReset) {
//                    //[self EndVideoToolBox];
//                }
//            }
//            break;
//        case 0x08: //pps
//            // NSLog(@"nalu_type:%d Nal type is PPS",nalu_type);
//            _ppsSize = frameSize - 4;
//            if (!_pps) _pps = malloc(128);
//            if (_ppsSize <= 128)
//            {
//                memcpy(_pps, frame + 4, _ppsSize);
//                //pixelBuffer = [self decode:frame withSize:frameSize];
//                BOOL isReset1  =  VTDecompressionSessionCanAcceptFormatDescription(_deocderSession, _decoderFormatDescription);
//                if (isReset1) {
//                    [self EndVideoToolBox];
//                }
//            }
//            break;
//        default:
//            // NSLog(@"Nal type is B/P frame === nalu_type:%d ",nalu_type);//其他帧
//
//            //            if([self initH264Decoder])
//            //            {
//            //                pixelBuffer = [self decode:frame withSize:frameSize];
//            //            }
//            break;
//    }
//    //    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//    //        if (pixelBuffer) {
//    //            H264HwDecoderImpl *decoder = self;
//    //            if (decoder.delegate && [decoder.delegate respondsToSelector:@selector(displayDecodedFrame:)])
//    //            {
//    //                NSLog(@"解码当前线程3：%@",[NSThread currentThread]);
//    //                [decoder.delegate displayDecodedFrame:pixelBuffer];
//    //                CVPixelBufferRelease(pixelBuffer);
//    //            }
//    //        }
//    //    }];
//}


//H265播放器
- (void)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize
{
    //H265解码
    if (self.isNeedH265Decoder) {
        NSLog(@"我这里需要知道是H265");
        int nalu_type = (frame[4] & 0x7E)>>1;
//        NSLog(@"naluType:%d",nalu_type);
        NSString * nalu_typeStr;
        switch (nalu_type) {
            case 1:nalu_typeStr = @"B/P";
                break;
            case 19:nalu_typeStr = @"I";
                break;
            case 32:nalu_typeStr = @"VPS";
            case 33:nalu_typeStr = @"SPS";
                break;
            case 34:nalu_typeStr = @"PPS";
                break;
            case 39:nalu_typeStr = @"SEI";
                break;
            default:nalu_typeStr = @"B/P";
                break;
        }
        
        
        //以上写法和下面写法一样可以正常播放。下面一种是调用api，做大端序变化的。
        uint32_t nalSize = (uint32_t)(frameSize - 4);
        uint32_t *pNalSize = (uint32_t *)frame;
        *pNalSize = CFSwapInt32HostToBig(nalSize);
        // 在buffer的前面填入代表长度的int
        CVPixelBufferRef pixelBuffer = NULL;
        
        //传输的时候。关键帧不能丢数据 否则绿屏   B/P可以丢  这样会卡顿
        switch (nalu_type)
        {
            case 1:
            {
//                NSLog(@"【B/P帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                
                if (!self.DecoderNeedSpeedUp) {
                    {
                        pixelBuffer = [self decode:frame withSize:frameSize];
                    }
                }else
                {
//                    NSLog(@"【】加速播放，丢弃p帧");
                }
                break;
            }
            case 19:
//                NSLog(@"【I帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                if([self initH264Decoder])
                {
                    if (!StartIFrameEncode) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
                        StartIFrameEncode = YES;
                        NSLog(@"开始解码i帧，H265处这里可以加个通知关闭动画");
                    }
                    // NSLog(@"解码当前线程2：%@",[NSThread currentThread]);
                    ALLSEI_NoIFrame = NO;
                    //self.DecoderNeedSpeedUp = FALSE;
                    pixelBuffer = [self decode:frame withSize:frameSize];
                }
                break;
                
            case 32: //vps
//                NSLog(@"【VPS帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                _vpsSize = frameSize - 4;
                if (!_vps) _vps = malloc(128);//_vps、sps 和 pps 最大不会超过128
                if (_vpsSize <= 128)
                {
                    memcpy(_vps, frame + 4, _vpsSize);
                    //pixelBuffer = [self decode:frame withSize:frameSize];
                    //判断是否接受新的sps
                    BOOL isReset  =  VTDecompressionSessionCanAcceptFormatDescription(_deocderSession, _decoderFormatDescription);
                    if (isReset) {
                        //[self EndVideoToolBox];
                    }
                }
                
                break;
                
            case 33://sps
//                NSLog(@"【SPS帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                _spsSize = frameSize - 4;
                if (!_sps) _sps = malloc(128);//sps 和 pps 最大不会超过128
                if (_spsSize <= 128)
                {
                    memcpy(_sps, frame + 4, _spsSize);
                    //pixelBuffer = [self decode:frame withSize:frameSize];
                    //判断是否接受新的sps
                    BOOL isReset  =  VTDecompressionSessionCanAcceptFormatDescription(_deocderSession, _decoderFormatDescription);
                    if (isReset) {
                        //[self EndVideoToolBox];
                    }
                }
                break;
            case 34: //pps
//                NSLog(@"【PPS帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                _ppsSize = frameSize - 4;
                if (!_pps) _pps = malloc(128);
                if (_ppsSize <= 128)
                {
                    memcpy(_pps, frame + 4, _ppsSize);
                    //pixelBuffer = [self decode:frame withSize:frameSize];
                    BOOL isReset1  =  VTDecompressionSessionCanAcceptFormatDescription(_deocderSession, _decoderFormatDescription);
                    if (isReset1) {
                        //[self EndVideoToolBox];
                    }
                }
                break;
                
            case 39:
//                NSLog(@"我是SEI帧不需要处理！");
                break;
                
                
            default:
                
                break;
        }
        
        
        
    }else{ //H264解码
//            NSLog(@"我这里需要知道是H264");
            int nalu_type = (frame[4] & 0x1F);
//            NSLog(@"naluType:%d",nalu_type);
            NSString * nalu_typeStr;
            switch (nalu_type) {
                case 0x01:nalu_typeStr = @"B/P";
                    break;
                case 0x05:nalu_typeStr = @"I";
                    break;
                case 0x06:nalu_typeStr = @"SEI";
                    break;
                case 0x07:nalu_typeStr = @"SPS";
                    break;
                case 0x08:nalu_typeStr = @"PPS";
                    break;
                default:nalu_typeStr = @"B/P";
                    break;
            }
//            NSLog(@">>>>>>>>>>开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
            //以上写法和下面写法一样可以正常播放。下面一种是调用api，做大端序变化的。
            uint32_t nalSize = (uint32_t)(frameSize - 4);
            uint32_t *pNalSize = (uint32_t *)frame;
            *pNalSize = CFSwapInt32HostToBig(nalSize);
            // 在buffer的前面填入代表长度的int
            CVPixelBufferRef pixelBuffer = NULL;
        
            //传输的时候。关键帧不能丢数据 否则绿屏   B/P可以丢  这样会卡顿
            switch (nalu_type)
            {
                case 0x01:
                {
//                    NSLog(@"【B/P帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                    if (!self.DecoderNeedSpeedUp) {
                        {
                            pixelBuffer = [self decode:frame withSize:frameSize];
                        }
                    }else
                    {
//                        NSLog(@"【】加速播放，丢弃p帧");
                    }
                    break;
                    
                }
                case 0x05:
                    if([self initH264Decoder])
                    {
//                        NSLog(@"【I帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                        if (!StartIFrameEncode) {
                            [[NSNotificationCenter defaultCenter]postNotificationName:HIDELOADVIEW object:nil];
                            StartIFrameEncode = YES;
                            NSLog(@"开始解码i帧，H264处这里可以加个通知关闭动画");
                        }
                        // NSLog(@"解码当前线程2：%@",[NSThread currentThread]);
                        ALLSEI_NoIFrame = NO;
                        //self.DecoderNeedSpeedUp = FALSE;
                        pixelBuffer = [self decode:frame withSize:frameSize];
                    }
                    break;
                case 0x06:
//                    NSLog(@"我是SEI帧不需要处理！");
                    break;
        
                case 0x07://sps
                    // NSLog(@"nalu_type:%d Nal type is SPS",nalu_type);
//                    NSLog(@"【SPS帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                    _spsSize = frameSize - 4;
                    if (!_sps) _sps = malloc(128);//sps 和 pps 最大不会超过128
                    if (_spsSize <= 128)
                    {
                        memcpy(_sps, frame + 4, _spsSize);
                        //pixelBuffer = [self decode:frame withSize:frameSize];
                        //判断是否接受新的sps
                        BOOL isReset  =  VTDecompressionSessionCanAcceptFormatDescription(_deocderSession, _decoderFormatDescription);
                        if (isReset) {
                            //[self EndVideoToolBox];
                        }
                    }
                    break;
                case 0x08: //pps
//                    NSLog(@"【PPS帧进入】开始解码frameSize[%d] nalu_type:[%d][%@]", frameSize,nalu_type,nalu_typeStr);
                    _ppsSize = frameSize - 4;
                    if (!_pps) _pps = malloc(128);
                    if (_ppsSize <= 128)
                    {
                        memcpy(_pps, frame + 4, _ppsSize);
                        BOOL isReset1  =  VTDecompressionSessionCanAcceptFormatDescription(_deocderSession, _decoderFormatDescription);
                        if (isReset1) {
                            [self EndVideoToolBox];
                        }
                    }
                    break;
                default:
                    break;
            }
        
        
    }
    
    
}



#pragma mark - 初始化解码器
-(BOOL)initH264Decoder {
    if(_deocderSession) {
        return YES;
    }
//    NSLog(@"initH264Decoder== sps: %s pps :%s==== _deocderSession：%p",_sps,_pps,&_deocderSession);
    
    OSStatus status = 0;
    
    if (self.isNeedH265Decoder) {
        //H265解码器初始化配置
        const uint8_t* const parameterSetPointers[3] = { _vps, _sps, _pps };
        const size_t parameterSetSizes[3] = {_vpsSize, _spsSize, _ppsSize };
        if (@available(iOS 11.0, *)) {
            status = CMVideoFormatDescriptionCreateFromHEVCParameterSets(kCFAllocatorDefault,
                                                                         3,
                                                                         parameterSetPointers,
                                                                         parameterSetSizes,
                                                                         4,
                                                                         NULL,
                                                                         &_decoderFormatDescription);
        } else {
            // Fallback on earlier versions
            NSLog(@"不支持H265解码！");
        }
    
    
    }else{
        //H264解码器初始化配置
        const uint8_t* const parameterSetPointers[2] = {_sps, _pps };
        const size_t parameterSetSizes[2] = {_spsSize, _ppsSize };
        status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                     2, //param count
                                                                     parameterSetPointers,
                                                                     parameterSetSizes,
                                                                     4, //nal start code size
                                                                     &_decoderFormatDescription);
    
    }
    
    
    /*
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, //param count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4, //nal start code size
                                                                          &_decoderFormatDescription);
    */
    
    
        
        if(status == noErr) {
            NSDictionary* destinationPixelBufferAttributes = @{
                                                               (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],
                                                               //硬解必须是 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
                                                               //                                                           或者是kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                                                               //因为iOS是  nv12  其他是nv21
                                                               (id)kCVPixelBufferWidthKey : [NSNumber numberWithInt:h264outputHeight*2],
                                                               (id)kCVPixelBufferHeightKey : [NSNumber numberWithInt:h264outputWidth*2],
                                                               //这里款高和编码反的
                                                               (id)kCVPixelBufferOpenGLCompatibilityKey : [NSNumber numberWithBool:YES]
                                                               };
            // 设置解码输出数据回调
            VTDecompressionOutputCallbackRecord callBackRecord;
            callBackRecord.decompressionOutputCallback = didDecompress;
            callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
            // 创建解码器
            status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                                  _decoderFormatDescription,
                                                  NULL,
                                                  (__bridge CFDictionaryRef)destinationPixelBufferAttributes,
                                                  &callBackRecord,
                                                  &_deocderSession);
            // 解码线程数量
            VTSessionSetProperty(_deocderSession, kVTDecompressionPropertyKey_ThreadCount, (__bridge CFTypeRef)[NSNumber numberWithInt:1]);
            // 是否实时解码
            VTSessionSetProperty(_deocderSession, kVTDecompressionPropertyKey_RealTime, kCFBooleanTrue);
        }
        else {//status == err
            NSLog(@"IO: reset decoder session failed status=%d", status);
        }
    
        
    return YES;
}


/**
 @return 解码数据
 @param frame 数据
 @param frameSize 数据长度
 */
- (CVPixelBufferRef)decode:(uint8_t *)frame withSize:(uint32_t)frameSize
{
    CVPixelBufferRef outputPixelBuffer = NULL;
    
    CMBlockBufferRef blockBuffer = NULL;
    // 创建 CMBlockBufferRef
    OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                          (void *)frame,
                                                          frameSize,
                                                          kCFAllocatorNull,
                                                          NULL,
                                                          0,
                                                          frameSize,
                                                          FALSE,
                                                          &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {frameSize};
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           _decoderFormatDescription ,
                                           1, 0, NULL, 1, sampleSizeArray,
                                           &sampleBuffer);
        if (status == kCMBlockBufferNoErr && sampleBuffer) {
            // VTDecodeFrameFlags 0为允许多线程解码
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            if (_deocderSession) {
                // 解码 这里第四个参数会传到解码的callback里的sourceFrameRefCon，可为空
                OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                                          sampleBuffer,
                                                                          flags,
                                                                          &outputPixelBuffer,
                                                                          &flagOut);
                if(decodeStatus == kVTInvalidSessionErr) {
                   // [self EndVideoToolBox];
                    NSLog(@"IOS8VT: Invalid session, reset decoder session");
                    
                } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                   // [self EndVideoToolBox];
                    NSLog(@"IOS8VT: decodekVTVideoDecoderBadDataErr failed status=%d(Bad data)", decodeStatus);
                } else if(decodeStatus != noErr) {
                    //[self EndVideoToolBox];
                    NSLog(@"IOS8VT %@: decodenoErr failed status=%d",self, decodeStatus);
                }
                CFRelease(sampleBuffer);
            }
        }
        CFRelease(blockBuffer);
    }
    return outputPixelBuffer;
}



#pragma mark - 解码回调delegate
//解码回调函数
static void didDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
    H264HwDecoderImpl *decoder = (__bridge H264HwDecoderImpl *)decompressionOutputRefCon;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        if (decoder.delegate && [decoder.delegate respondsToSelector:@selector(displayDecodedFrame:)])
        {
            //            NSLog(@"解码当前线程2：%@",[NSThread currentThread]);
            
            [decoder.delegate displayDecodedFrame:pixelBuffer];
            CVPixelBufferRelease(pixelBuffer);
        }
    }];
    // CVPixelBufferRelease(*outputPixelBuffer);
}



#pragma mark - 结束硬解码
- (void)EndVideoToolBox
{
    NSLog(@"EndVideoToolBox:%p",&_deocderSession);
    if(_deocderSession != NULL) {
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = NULL;
    }
    
    if(_decoderFormatDescription) {
        CFRelease(_decoderFormatDescription);
        _decoderFormatDescription = NULL;
    }
    //这里不应该要释放sps和pps,否则解码器会报错，然后固定有3秒不能播放成功
    //free(_sps);
    //f_sps = NULL;
    //free(_pps);
    //_pps = NULL;
    //_spsSize = _ppsSize = 0;
}

#pragma mark - 销毁
- (void)dealloc
{
    if (_sps) {
        free(_sps);
        _sps = NULL;
    }
    if (_pps) {
        free(_pps);
        _pps = NULL;
    }
    if (_vps){
        free(_vps);
        _pps = NULL;
    }
    [self EndVideoToolBox];
    NSLog(@"==============硬解码解码释放==============");
}
@end
