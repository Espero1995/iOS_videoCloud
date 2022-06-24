//
//  PCMDataPlayer.h
//  PCMDataPlayerDemo
//
//  Created by Android88 on 15-2-10.
//  Copyright (c) 2015年 Android88. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define QUEUE_BUFFER_SIZE 6 //队列缓冲个数
#define MIN_SIZE_PER_FRAME 2000 //每帧最小数据长度

@interface PCMDataPlayer : NSObject 

/*!
 *  @author 15-02-10 16:02:27
 *
 *  @brief  重置播放器
 *
 *  @since v1.0
 */
- (void)reset;

/*!
 *  @author 15-02-10 17:02:52
 *
 *  @brief  停止播放
 *
 *  @since v1.0
 */
- (void)stop;

/*!
 *  @author 15-02-10 16:02:56
 *
 *  @brief  播放PCM数据
 *
 *  @param pcmData pcm字节数据
 *
 *  @since v1.0
 */
- (void)play:(void*)pcmData length:(unsigned int)length;

@end
