//
//  NewTwoOpenAl.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/11/30.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "NewTwoOpenAl.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <OpenAL/oalMacOSX_OALExtensions.h>

@interface NewTwoOpenAl ()

    {
        ALCcontext *mContext;
        ALCdevice *mDevice;
        ALuint outSourceId;
        ALuint buff;
    }


@end
@implementation NewTwoOpenAl

static NewTwoOpenAl *_player;
static dispatch_once_t onceToken;

+ (id)sharePalyer {
    dispatch_once(&onceToken, ^{
        if (_player == nil) {
            _player = [[NewTwoOpenAl alloc] init];
            [_player initOpenAL];
        }
    });
    return _player;
}
-(void)stopDealloc{
    [self clearOpenALaaa];
    onceToken = 0; // 只有置成0,GCD才会认为它从未执行过.它默认为0.这样才能保证下次再次调用shareInstance的时候,再次创建对象.
    _player = nil;
}
// 初始化openAL
- (void)initOpenAL {
    mDevice=alcOpenDevice(NULL);
    if (mDevice) {
        mContext = alcCreateContext(mDevice, NULL);
        alcMakeContextCurrent(mContext);
    }
    
    alGenSources(1, &outSourceId);
    alSpeedOfSound(1.0);
    alDopplerVelocity(1.0);
    alDopplerFactor(1.0);
    alSourcef(outSourceId, AL_PITCH, 1.0f);
    alSourcef(outSourceId, AL_GAIN, 1.0f);
    alSourcei(outSourceId, AL_LOOPING, AL_FALSE);
    alSourcef(outSourceId, AL_SOURCE_TYPE, AL_STREAMING);
}

// 播放回调
- (void)openAudioFromQueue:(uint8_t *)data dataSize:(size_t)dataSize samplerate:(int)samplerate channels:(int)channels bit:(int)bit {
    NSCondition* ticketCondition= [[NSCondition alloc] init];
    [ticketCondition lock];
   // NSLog(@"我是打印");
    if (!mContext) {
        [self initOpenAL];
    }
    
    ALuint bufferID = 0;
    alGenBuffers(1, &bufferID);
    NSData * tmpData = [NSData dataWithBytes:data length:dataSize];
    int aSampleRate,aBit,aChannel;
    aSampleRate = samplerate;
    aBit = bit;
    aChannel = channels;
    ALenum format = 0;
    if (aBit == 8) {
        if (aChannel == 1)
            format = AL_FORMAT_MONO8;
        else if(aChannel == 2)
            format = AL_FORMAT_STEREO8;
        else if( alIsExtensionPresent( "AL_EXT_MCFORMATS" ) )
        {
            if( aChannel == 4 )
            {
                format = alGetEnumValue( "AL_FORMAT_QUAD8" );
            }
            if( aChannel == 6 )
            {
                format = alGetEnumValue( "AL_FORMAT_51CHN8" );
            }
        }
    }else if( aBit == 16 ){
        if( aChannel == 1 )
        {
            format = AL_FORMAT_MONO16;
        }
        if( aChannel == 2 )
        {
            format = AL_FORMAT_STEREO16;
        }
        if( alIsExtensionPresent( "AL_EXT_MCFORMATS" ) )
        {
            if( aChannel == 4 )
            {
                format = alGetEnumValue( "AL_FORMAT_QUAD16" );
            }
            if( aChannel == 6 )
            {
                format = alGetEnumValue( "AL_FORMAT_51CHN16" );
            }
        }
    }
    alBufferData(bufferID, format, (char*)[tmpData bytes], (ALsizei)[tmpData length],aSampleRate);
    alSourceQueueBuffers(outSourceId, 1, &bufferID);
    [self updataQueueBuffer];
    
    ALint stateVaue;
    alGetSourcei(outSourceId, AL_SOURCE_STATE, &stateVaue);
    
    [ticketCondition unlock];
    ticketCondition = nil;
}

- (BOOL)updataQueueBuffer {
    ALint stateVaue;
    int processed, queued;
    
    alGetSourcei(outSourceId, AL_BUFFERS_PROCESSED, &processed);
    alGetSourcei(outSourceId, AL_BUFFERS_QUEUED, &queued);
    
    alGetSourcei(outSourceId, AL_SOURCE_STATE, &stateVaue);
    
    if (stateVaue == AL_STOPPED ||
        stateVaue == AL_PAUSED ||
        stateVaue == AL_INITIAL) {
        [self playSound];
    } else if (stateVaue == AL_PLAYING && queued < 1){
        [self pauseSound];
    } else if(stateVaue == 4116){
        return NO;
    }
    while(processed--) {
        alSourceUnqueueBuffers(outSourceId, 1, &buff);
        alDeleteBuffers(1, &buff);
    }
    return YES;
}

- (void)playSound {
    alSourcePlay(outSourceId);
}

- (void)pauseSound {
    ALint  state;
    alGetSourcei(outSourceId, AL_SOURCE_STATE, &state);
    if (state == AL_PLAYING) {
        alSourcePause(outSourceId);
    }
}

- (void)stopSound {
//    alSourcePause(outSourceId);
    alSourceStop(outSourceId);
//    [self clearOpenALaaa];
}

- (void)cleanUpOpenAL {
    int processed;
    
    alGetSourcei(outSourceId, AL_BUFFERS_PROCESSED, &processed);
    while(processed--) {
        alDeleteBuffers(1, &buff);
//        alDeleteSources(1, &outSourceId);
        alcDestroyContext(mContext);
//        alcCloseDevice(mDevice);
    }
}


-(void)clearOpenALaaa
{
    alDeleteSources(1, &outSourceId);
    if (mContext != nil)
    {
        alcDestroyContext(mContext);
        mContext=nil;
    }
    if (mDevice !=nil)
    {
        alcCloseDevice(mDevice);
        mDevice=nil;
    }
}
- (void)dealloc
{
    NSLog(@"dealloc openAl");
}
@end
