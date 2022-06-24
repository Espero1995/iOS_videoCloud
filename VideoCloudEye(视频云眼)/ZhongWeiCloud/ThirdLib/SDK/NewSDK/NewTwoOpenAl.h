//
//  NewTwoOpenAl.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/11/30.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewTwoOpenAl : NSObject
+(id)sharePalyer;

/**
 *  播放
 *
 *  @param data       数据
 *  @param dataSize   长度
 *  @param samplerate 采样率
 *  @param channels   通道
 *  @param bit        位数
 */
-(void)openAudioFromQueue:(uint8_t *)data dataSize:(size_t)dataSize samplerate:(int)samplerate channels:(int)channels bit:(int)bit;
- (void)playSound;
/**
 *  停止播放
 */
-(void)stopSound;
//释放
-(void)stopDealloc;
@end

