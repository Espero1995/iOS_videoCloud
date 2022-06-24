//
//  ShareFeatureModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/5.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareFeatureModel : NSObject
/*1.视频预览*/
@property (nonatomic,assign) int rtv;
/*2.声音*/
@property (nonatomic,assign) int volice;
/*3.录像回放*/
@property (nonatomic,assign) int hp;
/*4.视频对讲*/
@property (nonatomic,assign) int talk;
/*5.云台控制*/
@property (nonatomic,assign) int ptz;
/*6.报警推送*/
@property (nonatomic,assign) int alarm;
/*7.时间限制*/
@property (nonatomic,assign) int timeLimit;
/*8. 时段的开始时间和结束时间*/
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *endTime;
@end
