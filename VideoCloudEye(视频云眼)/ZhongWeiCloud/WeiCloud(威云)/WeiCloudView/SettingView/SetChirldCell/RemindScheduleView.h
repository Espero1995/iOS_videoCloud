//
//  RemindScheduleView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/31.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemindScheduleView : UIView
/**
 *  Pie
 *  @param frame      frame
 */
- (id)initWithFrame:(CGRect)frame;
/**
 *  绘制时间段
 *
 *  @param startTime  开始时间
 *  @param endTime  结束时间
 */
//绘制扇形
- (void)drawSectorStartTime:(NSString *)startTime andEndTime:(NSString *)endTime;

- (void)stroke;
@end
