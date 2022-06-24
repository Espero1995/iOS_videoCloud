//
//  TXHRulerScrollView.h
//  PrettyRuler
//
//  Created by 张策 on 16/12/11.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DISTANCELEFTANDRIGHT 8.f // 标尺左右距离
#define DISTANCEVALUE 15.f // 每隔刻度实际长度个点
#define DISTANCETOPANDBOTTOM 30.f // 标尺上下距离
#define DISBASE 35.f   //基本长度

@interface TXHRulerScrollView : UIScrollView

@property (nonatomic) NSUInteger rulerCount;

@property (nonatomic) NSNumber * rulerAverage;

@property (nonatomic) NSUInteger rulerHeight;

@property (nonatomic) NSUInteger rulerWidth;

@property (nonatomic) CGFloat rulerValue;

@property (nonatomic) BOOL mode;
//移动值
@property (nonatomic,assign)CGFloat moveValue;
//间隔
@property (nonatomic,assign)CGFloat distanceValue;

//划线
- (void)drawRuler:(NSInteger)lineCount;
//时间lab 分度
- (void)drawLable:(NSInteger)labCount Minutes:(NSInteger)minutes;
//背景View
- (void)drawBackViewStartCount:(CGFloat)startCount EndCount:(CGFloat)endCount;
@end
