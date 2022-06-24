//
//  NoTimeShaftRulerView.h
//  TimelineDemo
//
//  Created by Espero on 2019/10/21.
//  Copyright © 2019 Joyware Electronic co., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoTimeShaftRulerViewDelegate <NSObject>
/**
 * 标尺滑动中偏移量
 */
- (void)timeShaftRulerViewScrollOffSet:(float)offset untilEnd:(BOOL)isComplete;

@end

@interface NoTimeShaftRulerView : UIView
/**
 * 时间标签
 */
@property (nonatomic, strong) UILabel *timeLb;

@property(nonatomic,weak) id<NoTimeShaftRulerViewDelegate>delegate;/**< 代理 */

/**
 * 滚动屏幕位置设置
 */
- (void)scrollFrameSetting:(float)value;

/**
 * 滑动轴是否横屏
 */
- (void)fullScreenSettingScrollView:(BOOL)isFull;

@end
