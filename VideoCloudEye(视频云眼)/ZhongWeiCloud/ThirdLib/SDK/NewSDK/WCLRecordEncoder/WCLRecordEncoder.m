//
//  WCLRecordEncoder.m
//  Youqun
//
//  Created by 王崇磊 on 16/5/17.
//  Copyright © 2016年 W_C__L. All rights reserved.
//

#import "WCLRecordEncoder.h"
#include <time.h>

@interface WCLRecordEncoder ()

@property (nonatomic, strong) AVAssetWriter *writer;//媒体写入对象
@property (nonatomic, strong) AVAssetWriterInput *videoInput;//视频写入
@property (nonatomic, strong) AVAssetWriterInput *audioInput;//音频写入
@property (nonatomic, strong) NSString *path;//写入路径
@property (nonatomic,strong)AVAssetWriterInputPixelBufferAdaptor *adaptor;//buffer写入
@end

@implementation WCLRecordEncoder

- (void)dealloc {
    _writer = nil;
    _videoInput = nil;
    _audioInput = nil;
    _path = nil;
    _adaptor = nil;
}

//WCLRecordEncoder遍历构造器的
+ (WCLRecordEncoder*)encoderForPath:(NSString*) path Height:(NSInteger) cy width:(NSInteger) cx channels: (int) ch samples:(Float64) rate {
    WCLRecordEncoder* enc = [WCLRecordEncoder alloc];
    return [enc initPath:path Height:cy width:cx channels:ch samples:rate];
}

//初始化方法
- (instancetype)initPath:(NSString*)path Height:(NSInteger)cy width:(NSInteger)cx channels:(int)ch samples:(Float64) rate {
    self = [super init];
    if (self) {
        self.path = path;
        //先把路径下的文件给删除掉，保证录制的文件是最新的
        [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
        NSURL* url = [NSURL fileURLWithPath:self.path];
        //初始化写入媒体类型为MP4类型
        _writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:nil];
        //使其更适合在网络上播放
        _writer.shouldOptimizeForNetworkUse = YES;
        //初始化视频输出
        [self initVideoInputHeight:cy width:cx];
        //确保采集到rate和ch
        if (rate != 0 && ch != 0) {
            //初始化音频输出
            [self initAudioInputChannels:ch samples:rate];
        }
    }
    return self;
}

//初始化视频输入
- (void)initVideoInputHeight:(NSInteger)cy width:(NSInteger)cx {
    //录制视频的一些配置，分辨率，编码方式等等
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              AVVideoCodecH264, AVVideoCodecKey,
                              [NSNumber numberWithInteger: cx], AVVideoWidthKey,
                              [NSNumber numberWithInteger: cy], AVVideoHeightKey,
                              nil];
        //初始化视频写入类
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        //表明输入是否应该调整其处理为实时数据源的数据
        _videoInput.expectsMediaDataInRealTime = YES;
        NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
        
        _adaptor = [AVAssetWriterInputPixelBufferAdaptor
                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        //将视频输入源加入
        [_writer addInput:_videoInput];
}

//初始化音频输入
- (void)initAudioInputChannels:(int)ch samples:(Float64)rate {
    
    
    //音频的一些配置包括音频各种这里为AAC,音频通道、采样率和音频的比特率
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [ NSNumber numberWithInt: ch], AVNumberOfChannelsKey,
                              [ NSNumber numberWithFloat: rate], AVSampleRateKey,
//                              [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                              nil];
    //初始化音频写入类
    _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
    //表明输入是否应该调整其处理为实时数据源的数据
//    _audioInput.expectsMediaDataInRealTime = YES;
    //将音频输入源加入
    [_writer addInput:_audioInput];
}

//完成视频录制时调用
- (void)finishWithCompletionHandler:(void (^)(void))handler {
    if (_writer.status == AVAssetWriterStatusWriting) {
        [_videoInput markAsFinished];
        [_audioInput markAsFinished];
        [_writer finishWritingWithCompletionHandler: handler];
    }
}

//通过这个方法写入数据
- (BOOL)encodeFrame:(CVPixelBufferRef)sampleBuffer isVideo:(BOOL)isVideo time:(CMTime)presertTime {

    //数据是否准备写入
//    if (CMSampleBufferDataIsReady(sampleBuffer)) {
    if (isVideo == NO) {
        return  NO;
    }
    
    if (sampleBuffer) {
        //写入状态为未知,保证视频先写入
        if (_writer.status == AVAssetWriterStatusUnknown && isVideo) {
            //获取开始写入的CMTime
//                        CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            
            
            //开始写入
            [_writer startWriting];
            //            [_writer startSessionAtSourceTime:startTime];
            [_writer startSessionAtSourceTime:kCMTimeZero];
        }
        //写入失败
        if (_writer.status == AVAssetWriterStatusFailed) {
            NSLog(@"writer error %@", _writer.error.localizedDescription);
            return NO;
        }
        //判断是否是视频
        if (isVideo) {
            //视频输入是否准备接受更多的媒体数据
            if (_videoInput.readyForMoreMediaData == YES) {
                //拼接数据
                //                [_videoInput appendSampleBuffer:sampleBuffer];
                    [_adaptor appendPixelBuffer:sampleBuffer withPresentationTime:presertTime];

                    return YES;
            }
        }
        else {
            //音频输入是否准备接受更多的媒体数据
            if (_audioInput.readyForMoreMediaData == YES) {
                //拼接数据
                [_audioInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }
    }
    return NO;
}


//
//-( unsigned long) _GetTickCount
//{
//    
//    struct timeval tv;
//   
//    if (gettimeofday(&tv, NULL) != 0)
//        return 0;
//    
//    return (tv.tv_sec*1000  + tv.tv_usec / 1000);
//}
#pragma mark ------最新
- (void)writeAudioBytesWithDataBuffer: (unsigned char *)dataBuffer withLength: (unsigned int)aLength time:(CMTime)presertTime
{
    CMSampleBufferRef sampleBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    CMFormatDescriptionRef formatDescription = NULL;
    CMItemCount numberOfSamples = 320;

    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = 8000;
    audioFormat.mFormatID   = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerFrame = (audioFormat.mBitsPerChannel/8) * audioFormat.mChannelsPerFrame;
    audioFormat.mBytesPerPacket=audioFormat.mBytesPerFrame;
    audioFormat.mReserved = 0;

    CMAudioFormatDescriptionCreate(kCFAllocatorDefault,&audioFormat,0,NULL,0, NULL,NULL,&formatDescription);
    
    OSStatus result = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, NULL,
                                                         aLength, kCFAllocatorDefault, NULL, 0, aLength,
                                                         kCMBlockBufferAssureMemoryNowFlag, &blockBuffer);
    if(result != noErr)
    {
        NSLog(@"Error creating CMBlockBuffer");
        return;
    }
    
    result = CMBlockBufferReplaceDataBytes(dataBuffer, blockBuffer, 0, aLength);
    if(result != noErr)
    {
        NSLog(@"Error filling CMBlockBuffer");
        return;
    }
    
//    currentAudioTimeStamp=[self _GetTickCount]-startTimeStamp;
//    
//    CMTime   frameTime = CMTimeMake(currentAudioTimeStamp, 1000);
    
    result=CMAudioSampleBufferCreateWithPacketDescriptions(kCFAllocatorDefault, blockBuffer, TRUE, 0, NULL, formatDescription, numberOfSamples, presertTime, NULL, &sampleBuffer);
    if(result != noErr)
    {
        NSLog(@"Error creating CMSampleBuffer");
    }
    if (sampleBuffer)
    {
            if(_audioInput.readyForMoreMediaData == YES)
            {
            if([_audioInput appendSampleBuffer:sampleBuffer])
            {
                CMSampleBufferInvalidate(sampleBuffer);
                CFRelease(sampleBuffer);
                sampleBuffer = NULL;
            }
            else{
                printf("failed to append Audio buffer\n");
            }
        }
        if(sampleBuffer)
        {
        }
    }
}

- (void)writeVideoBytesWithDataBuffer: (unsigned char *)dataBuffer withLength: (unsigned int)aLength time:(CMTime)presertTime
{
    CMSampleBufferRef sampleBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    CMFormatDescriptionRef formatDescription = NULL;
    CMItemCount numberOfSamples = 1;
    CMItemCount numberOfSampleTimeEntries=1;

    CMVideoFormatDescriptionRef videoFormat;
    
    CMVideoFormatDescriptionCreate(kCFAllocatorDefault, kCMVideoCodecType_H264, 320, 240, NULL, &videoFormat);
}
@end
