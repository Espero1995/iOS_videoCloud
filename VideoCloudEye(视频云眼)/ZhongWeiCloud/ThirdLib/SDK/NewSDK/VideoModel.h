//
//  VideoModel.h
//  FFmpeg_Test
//
//  Created by 张策 on 16/11/1.
//  Copyright © 2016年 xiayuanquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject<NSCoding>


@property (nonatomic,assign)int nDepId;
@property (nonatomic,assign)int nChannelId;
@property (nonatomic,assign)int uChannelType;
@property (nonatomic,assign)int uIsOnLine;
@property (nonatomic,assign)int uVideoState;
@property (nonatomic,assign)int uChannelState;
@property (nonatomic,assign)int uRecordState;
@property (nonatomic,copy)NSString *sFdId;
@property (nonatomic,copy)NSString *sChannelName;

@end
