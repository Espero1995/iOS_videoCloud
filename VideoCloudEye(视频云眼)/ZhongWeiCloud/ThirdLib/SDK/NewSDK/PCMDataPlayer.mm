//
//  PCMDataPlayer.m
//  PCMDataPlayerDemo
//
//  Created by Android88 on 15-2-10.
//  Copyright (c) 2015年 Android88. All rights reserved.
//

#import "PCMDataPlayer.h"
static NSString *lockStrr = @"lock";
@interface PCMDataPlayer (){
AudioStreamBasicDescription audioDescription; ///音频参数
AudioQueueRef audioQueue; //音频播放队列
AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE]; //音频缓存
BOOL audioQueueUsed[QUEUE_BUFFER_SIZE];



    NSLock* sysnLock;}
//音频耗时播放线程
@property (nonatomic,strong)dispatch_queue_t myAudioQueue;

@end

@implementation PCMDataPlayer

//音频数据数组

- (dispatch_queue_t)myAudioQueue
{
    if (!_myAudioQueue) {
//        _myAudioQueue = dispatch_queue_create("audioQueue", NULL);
        _myAudioQueue = dispatch_get_global_queue(0, 0);

    }
    return _myAudioQueue;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)dealloc
{
    if (audioQueue != nil) {
        AudioQueueStop(audioQueue, true);
    }
    audioQueue = nil;
    NSLog(@"PCMDataPlayer dealloc...");
}

static void AudioPlayerAQInputCallback(void* inUserData, AudioQueueRef outQ, AudioQueueBufferRef outQB)
{
    PCMDataPlayer* player = (__bridge PCMDataPlayer*)inUserData;
    [player playerCallback:outQB];
}

- (void)reset
{
    [self stop];
    ///设置音频参数
    audioDescription.mSampleRate = 8000; //采样率
    audioDescription.mFormatID = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioDescription.mChannelsPerFrame = 1; ///单声道
    audioDescription.mFramesPerPacket = 1; //每一个packet一侦数据
    audioDescription.mBitsPerChannel = 16; //每个采样点16bit量化
    audioDescription.mBytesPerFrame = (audioDescription.mBitsPerChannel / 8) * audioDescription.mChannelsPerFrame;
    audioDescription.mBytesPerPacket = audioDescription.mBytesPerFrame;

    AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, (__bridge void*)self, nil, nil, 0, &audioQueue); //使用player的内部线程播放

    //初始化音频缓冲区
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        int result = AudioQueueAllocateBuffer(audioQueue, MIN_SIZE_PER_FRAME, &audioQueueBuffers[i]); ///创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的最大的一次还大
//        NSLog(@"AudioQueueAllocateBuffer i = %d,result = %d", i, result);
    }

    NSLog(@"PCMDataPlayer reset");
}

- (void)stop
{
    if (audioQueue != nil) {
        AudioQueueStop(audioQueue, true);
        AudioQueueReset(audioQueue);
//        AudioQueueDispose(audioQueue,true);

       
    }
    audioQueue = nil;
}

- (void)play:(void*)pcmData length:(unsigned int)length
{
            if (audioQueue == nil || ![self checkBufferHasUsed]) {
                [self reset];
                AudioQueueStart(audioQueue, NULL);
            }
                    AudioQueueBufferRef audioQueueBuffer = NULL;
                    while (true) {
                        audioQueueBuffer = [self getNotUsedBuffer];
                        if (audioQueueBuffer != NULL) {
                            break;
                        }
                    }
                    audioQueueBuffer->mAudioDataByteSize = length;
                    Byte* audiodata = (Byte*)audioQueueBuffer->mAudioData;
                    for (int i = 0; i < length; i++) {
                        audiodata[i] = ((Byte*)pcmData)[i];
                    }
                    
                    AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffer, 0, NULL);
                    NSLog(@"PCMDataPlayer play dataSize:%d", length);
}

- (BOOL)checkBufferHasUsed
{
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        if (audioQueueUsed[i] == YES ) {
            return YES;
        }
    }
    NSLog(@"PCMDataPlayer 播放中断............");
    return NO;
}

- (AudioQueueBufferRef)getNotUsedBuffer
{
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        if ( audioQueueUsed[i] == NO) {
            audioQueueUsed[i] = YES;
            return audioQueueBuffers[i];
        }
    }
    return NULL;
}

- (void)playerCallback:(AudioQueueBufferRef)outQB
{
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        if (audioQueueBuffers[i] == outQB) {
            audioQueueUsed[i] = NO;
        }
    }
}

@end
