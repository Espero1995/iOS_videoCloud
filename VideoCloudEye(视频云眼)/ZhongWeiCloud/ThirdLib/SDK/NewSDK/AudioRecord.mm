//
//  AudioRecord.m
//  audioText
//
//  Created by 张策 on 17/5/4.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "AudioRecord.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NewTwoOpenAl.h"
#import "VmNet.h"
#import "JWAudioAddressInfo.h"
#import "TBMALaw2PCMConverter.h"
#define kNumberAudioQueueBuffers 3  //定义了三个缓冲区
#define kDefaultBufferDurationSeconds 0.019  //调整这个值使得录音的缓冲区大小为2048bytes
#define kDefaultSampleRate 8000   //定义采样率为8000

@interface AudioRecord ()
//openal
@property (nonatomic,strong)NewTwoOpenAl *openAl;




@end

@implementation AudioRecord
{
    //音频输入队列
    AudioQueueRef _audioQueue;
    //音频输入数据format
    AudioStreamBasicDescription _recordFormat;
    
    //音频输入缓冲区
    AudioQueueBufferRef _audioBuffers[kNumberAudioQueueBuffers];
    
    char audioBuf[320];
    
    size_t audioSize;
}
- (id)init
{
    self = [super init];
    if (self) {
        
        self.sampleRate = kDefaultSampleRate;
        self.bufferDurationSeconds = kDefaultBufferDurationSeconds;
        //设置录音的format数据
        [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:(int)self.sampleRate];
       
        self.openAl = [NewTwoOpenAl sharePalyer];
        audioSize = 0;

    }
    return self;
}
- (void)setIsOpenAudio:(BOOL)isOpenAudio
{
    _isOpenAudio = isOpenAudio;
//    [_openAl playSound];
}


// 设置录音格式
- (void)setupAudioFormat:(UInt32) inFormatID SampleRate:(int)sampeleRate
{
    //重置下
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    
    //设置采样率，这里先获取系统默认的测试下 //TODO:
    //采样率的意思是每秒需要采集的帧数
    _recordFormat.mSampleRate = sampeleRate;//[[AVAudioSession sharedInstance] sampleRate];
    
    //设置通道数,这里先使用系统的测试下 //TODO:
    _recordFormat.mChannelsPerFrame = 1;//(UInt32)[[AVAudioSession sharedInstance] inputNumberOfChannels];
    
    //    NSLog(@"sampleRate:%f,通道数:%d",_recordFormat.mSampleRate,_recordFormat.mChannelsPerFrame);
    
    //设置format，怎么称呼不知道。
    _recordFormat.mFormatID = inFormatID;
    
    if (inFormatID == kAudioFormatLinearPCM){
        //这个屌属性不知道干啥的。，//要看看是不是这里属性设置问题
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        //每个通道里，一帧采集的bit数目
        _recordFormat.mBitsPerChannel = 16;
        //结果分析: 8bit为1byte，即为1个通道里1帧需要采集2byte数据，再*通道数，即为所有通道采集的byte数目。
        //所以这里结果赋值给每帧需要采集的byte数目，然后这里的packet也等于一帧的数据。
        //至于为什么要这样。。。不知道。。。
        _recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
        _recordFormat.mFramesPerPacket = 1;
    }
}
//回调函数
void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    NSLog(@"we are in the 回调函数\n");
    AudioRecord *recorder = (__bridge AudioRecord*)inUserData;
    
    if (inNumPackets > 0) {
        
//        NSLog(@"in the callback the current thread is %@\n",[NSThread currentThread]);
        [recorder processAudioBuffer:inBuffer withQueue:inAQ];    //在这个函数你可以用录音录到得PCM数据：inBuffer，去进行处理了
        
    }
    
    if (recorder.isRecording) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}
//处理pcm
- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
    NSLog(@"processAudioData====================== :%ld", buffer->mAudioDataByteSize);
    //处理data：忘记oc怎么copy内存了，于是采用的C++代码，记得把类后缀改为.mm。同Play
//    memcpy(audioByte+audioDataIndex, buffer->mAudioData, buffer->mAudioDataByteSize);
//    audioDataIndex +=buffer->mAudioDataByteSize;
//    audioDataLength = audioDataIndex;
    talk_addr*model = self.audioAddressModel.talk_addr;
    if (model.t_ip.length>0) {
        UInt32 audioLen = buffer->mAudioDataByteSize;
        for (int i = audioSize; i < audioLen; ++i) {
            audioBuf[audioSize++] = ((char*)buffer->mAudioData)[i];
            if (audioSize == 320) {
                //pcm转g711
                NSData *bufData = [NSData dataWithBytes:audioBuf length:audioSize];
                NSData *audioData = [TBMALaw2PCMConverter encodeWithData:bufData];
                NSLog(@"audioData.length:%d",(int)audioData.length);
                
                BOOL isPlayTalk = VmNet_SendTalk([model.t_ip UTF8String], model.t_port, (const char *)audioData.bytes, (int)audioData.length);
                if (isPlayTalk) {
                    NSLog(@"正在对讲成功");
                }else{
                    NSLog(@"正在对讲失败VmNet_SendTalk");
                }
                audioSize = 0;
            }
        }
    }
}

#pragma mark ------sdk回调
void audioStreamCallBackV3(const char *sRemoteAddr,
                   unsigned short usRemotePort, const char *pStreamData,
                           unsigned uStreamLen, void *pUser)
{
    AudioRecord *userSelf = (__bridge AudioRecord *)pUser;
    
    char payloadData[uStreamLen];
    int payloadLen = uStreamLen;
    int payloadType;
    int seqNumber;
    int timestamp;
    bool isMark;

    BOOL FilterRtpHeaderSuccess = VmNet_FilterRtpHeader(pStreamData, uStreamLen, payloadData, payloadLen, payloadType, seqNumber, timestamp, isMark);
    //NSLog(@"FilterRtpHeaderSuccess:%@",FilterRtpHeaderSuccess?@"YES":@"NO");
    if (FilterRtpHeaderSuccess) {
        if (userSelf.isOpenAudio) {
            NSData *StreamData = [[NSData alloc]initWithBytes:payloadData length:payloadLen];
            NSData *audioData = [TBMALaw2PCMConverter decodeWithData:StreamData];
           // NSLog(@"单独对讲==audioData.length:%lu===audioData:%@",(unsigned long)audioData.length,audioData);
            dispatch_async(dispatch_queue_create("openAl", DISPATCH_QUEUE_SERIAL), ^{
                [userSelf.openAl openAudioFromQueue:(uint8_t *)audioData.bytes dataSize:audioData.length samplerate:8000 channels:1 bit:16];
            });
        }
    }
}
//开始录音
-(void)startRecording
{
    talk_addr*model = self.audioAddressModel.talk_addr;
    if (model.t_ip.length>0) {
        void *puser = (__bridge void *)self;

        BOOL isOpenTalk = VmNet_StartTalk(audioStreamCallBackV3, puser);
        if (isOpenTalk) {
            NSLog(@"开启对讲成功");
        }else{
            NSLog(@"开启对讲失败VmNet_StartTalk");
        }
    }
    
    NSError *error = nil;
    //设置audio session的category
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];//注意，这里选的是AVAudioSessionCategoryPlayAndRecord参数，如果只需要录音，就选择Record就可以了，如果需要录音和播放，则选择PlayAndRecord，这个很重要
    if (!ret) {
        NSLog(@"设置声音环境失败");
        return;
    }
    //启用audio session
//    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
//    if (!ret)
//    {
//        NSLog(@"启动失败");
//        return;
//    }
   
    _recordFormat.mSampleRate = self.sampleRate;//设置采样率，8000hz
    
    //初始化音频输入队列
    AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);//inputBufferHandler这个是回调函数名
    
    //计算估算的缓存区大小
//    int frames = (int)ceil(self.bufferDurationSeconds * _recordFormat.mSampleRate);//返回大于或者等于指定表达式的最小整数
   // int bufferByteSize = frames * _recordFormat.mBytesPerFrame;//缓冲区大小在这里设置，这个很重要，在这里设置的缓冲区有多大，那么在回调函数的时候得到的inbuffer的大小就是多大。
     int bufferByteSize = 320;
//    NSLog(@"缓冲区大小:%d",bufferByteSize);
    
    //创建缓冲器
    for (int i = 0; i < kNumberAudioQueueBuffers; i++){
        AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
        AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);//将 _audioBuffers[i]添加到队列中
    }
    
    // 开始录音
    AudioQueueStart(_audioQueue, NULL);
    
    self.isRecording = YES;
}
//关闭对讲
-(void)stopRecording
{
    NSLog(@"stop recording out\n");//为什么没有显示
    
    if (self.isRecording)
    {
        self.isRecording = NO;
        //关闭对讲
        VmNet_StopTalk();
        //停止录音队列和移除缓冲区,以及关闭session，这里无需考虑成功与否
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);//移除缓冲区,true代表立即结束录制，false代表将缓冲区处理完再结束
//        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];//注意，这里选的是AVAudioSessionCategoryPlayAndRecord参数，如果只需要录音，就选择Record就可以了，如果需要录音和播放，则选择PlayAndRecord，这个很重要
        [_openAl stopSound];
        [_openAl stopDealloc];
    }
}

- (void)dealloc
{
    [self stopRecording];
}
@end
