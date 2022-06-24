//
//  TXHRrettyRuler.h
//  PrettyRuler
//
//  Created by 张策 on 16/12/11.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXHRulerScrollView.h"
#import "TimeView.h"
@protocol TXHRrettyRulerDelegate <NSObject>

- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView;
//代理显示时间
- (void)txhTimeStr:(NSString *)timeStr MinValue:(CGFloat)minValue;
//代理播放指定日期
- (void)reloadTimePlay;
@end

@interface TXHRrettyRuler : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id <TXHRrettyRulerDelegate> rulerDeletate;
@property (nonatomic,strong)TimeView *timeViewnew;
@property (nonatomic,assign)NSInteger levelCount;

/*
*  count * average = 刻度最大值
*  @param count        10个小刻度为一个大刻度，大刻度的数量
*  @param average      每个小刻度的值，最小精度 0.1
*  @param currentValue 直尺初始化的刻度值
*  @param mode         是否最小模式
*/
- (void)showRulerScrollViewWithCount:(NSUInteger)count
                             average:(NSNumber *)average
                        currentValue:(CGFloat)currentValue
                           smallMode:(BOOL)mode LabCount:(NSInteger)labCount Minutes:(NSInteger)minutes LineCount:(NSInteger)lineCount;

- (void)setBeginTime:(CGFloat)beginTime EndTime:(CGFloat)endTime Minutes:(NSInteger)minutes;

@property (nonatomic,assign)CGFloat currentValue;
//开始结束时间
@property (nonatomic,assign)NSInteger beginTime;
@property (nonatomic,assign)NSInteger endTime;
@property (nonatomic,strong)NSArray *timeArr;
@end
