//
//  CmsFeatureModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/5.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CmsFeatureModel : NSObject
//0 不支持  1 支持
/*1.ap模式*/
@property (nonatomic,assign)int amp;
/*2.云存储*/
@property (nonatomic,assign)int cloud;
/*3.图像翻转*/
@property (nonatomic,assign)int imf;
/*4.局域网模式*/
@property (nonatomic,assign)int lm;
/*5.移动侦测*/
@property (nonatomic,assign)int mdt;
/*6.P2P*/
@property (nonatomic,assign)int p2p;
/*7.云台控制*/
@property (nonatomic,assign)int ptz;
/*8.smartConfig配置*/
@property (nonatomic,assign)int scm;
/*9.在家模式*/
@property (nonatomic,assign)int sm;
/*10.对讲*/
@property (nonatomic,assign)int talk;
/*11.二维码配置*/
@property (nonatomic,assign)int tdccm;
/*12.宽动态*/
@property (nonatomic,assign)int wdy;
/*13.是否支持wifi*/
@property (nonatomic,assign)int wifi;

@end
