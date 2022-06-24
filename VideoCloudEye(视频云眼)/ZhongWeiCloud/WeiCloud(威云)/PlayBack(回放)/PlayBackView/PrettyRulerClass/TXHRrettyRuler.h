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
//因为要下面时间轴要走动，所以在拉动的时候，则单独先停止视频播放。松开就在重新播放新的时间的视频。【新增】
- (void)endPlaying;
//根据服务器来的时间，每秒更新时间轴上的显示时间，以及在时间轴上的位置【新增】
- (void)refreshTimeViewLabeltext:(NSData *)currentTime;
- (void)netWorkAlert;
@end

@interface TXHRrettyRuler : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id <TXHRrettyRulerDelegate> rulerDeletate;
@property (nonatomic,strong)TimeView *timeViewnew;
@property (nonatomic,assign)float levelCount;
//时间戳的秒
@property (nonatomic,assign)int timeMiao;
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
- (void)drawArrayBackView:(NSInteger)minutes;

@property (nonatomic,assign)CGFloat currentValue;
//开始结束时间
@property (nonatomic,assign)NSInteger beginTime;
@property (nonatomic,assign)NSInteger endTime;
@property (nonatomic,strong)NSArray *timeArr;
@end
