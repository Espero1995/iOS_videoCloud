//
//  AudioRecord.h
//  audioText
//
//  Created by 张策 on 17/5/4.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JWAudioAddressInfo;
@interface AudioRecord : NSObject
@property (nonatomic, assign) BOOL isRecording;


@property (atomic, assign) NSUInteger sampleRate;
@property (atomic, assign) double bufferDurationSeconds;

//通道地址
@property (nonatomic,strong)JWAudioAddressInfo *audioAddressModel;

@property (nonatomic,assign)BOOL isOpenAudio;
-(void)startRecording;
-(void)stopRecording;
@end
