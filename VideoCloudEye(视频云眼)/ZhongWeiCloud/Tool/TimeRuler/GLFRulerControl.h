//
//  GLFRulerControl.h
//  timeRuler
//
//  Created by 高凌峰 on 2018/6/21.
//  Copyright © 2018年 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLFRulerControlDelegate <NSObject>

//播放指定日期时间的录像
- (void)reloadTimePlay;
//在滑动时间轴的时候，先暂停当前播放的视频
- (IBAction)btnStartClick:(id)sender;
//在滑动时间轴的时候，先停止当前播放的视频
- (void)stopCurrentVideo;
//在滑动的时候，停止接收time的更新
- (void)stopReceiveRefreshTimeNoti;
@end

@interface GLFRulerControl : UIControl
@property (nonatomic, assign) CGFloat selectedValue;/**< 选中的数值，也就是默认指示的值，当前播放时间/当前时间 */
@property (nonatomic, assign) int indicatorCurrentTime;/**< 指示器指示需要显示的当前时间 时间戳时间*/
@property (nonatomic, copy)   NSString* showTime;/**< 显示的当前时间 */
@property (nonatomic, assign) NSInteger minValue;/**< 最小值 */
@property (nonatomic, assign) NSInteger maxValue;/**< 最大值 */
@property (nonatomic, assign) NSInteger valueStep;/**< 步长 */
@property (nonatomic, assign) CGFloat minorScaleSpacing;/**< 小刻度间距，默认值:8.0 */
@property (nonatomic, assign) CGFloat majorScaleLength;/**< 主刻度长，默认值：25 */
@property (nonatomic, assign) CGFloat middleScaleLength;/**< 中等刻度长度，默认值：15 */
@property (nonatomic, assign) CGFloat minorScaleLength;/**< 小刻度长度，默认值：10 */
@property (nonatomic, strong) UIColor* rulerBackgroundColor;/**< 刻度尺的背景颜色，默认：clearColor */
@property (nonatomic, strong) UIColor* scaleColor;/**< 刻度的颜色，默认：lightGrayColor */
@property (nonatomic, strong) UIColor* scaleFontColor;/**< 刻度字体的颜色，默认：darkGrayColor */
@property (nonatomic, assign) CGFloat scaleFontSize;/**< 刻度尺字体的颜色，默认：10 */
@property (nonatomic, strong) UIColor* indicatorColor;/**< 指示器的颜色，默认：redColor */
@property (nonatomic, assign) CGFloat indicatorLength;/**< 指示器长度，默认：40 */
@property (nonatomic, strong) UIColor* displayBackgroundColor;/**< 需要显示的视频的背景颜色，默认：orangeColor */
@property (nonatomic, assign) NSInteger stepPerHour;/**< 每小时60分钟计算，按照步长计算得出一小时2主刻度中有多少小格子 */

@property (nonatomic, assign) id <GLFRulerControlDelegate> GlfRulerDelegate;/**< 代理 */


/**
 通过传入的时间段，画出相应时间的背景颜色

 @param timeArr 需要画的时间段的数组
 */
- (void)drawVideoBgViewWithArray:(NSArray *)timeArr;

@end
