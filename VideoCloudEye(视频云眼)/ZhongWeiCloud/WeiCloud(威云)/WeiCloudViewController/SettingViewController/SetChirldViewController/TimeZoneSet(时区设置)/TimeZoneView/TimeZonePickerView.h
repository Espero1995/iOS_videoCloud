//
//  TimeZonePickerView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/1/2.
//  Copyright © 2019 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeZonePickerViewDelegate <NSObject>

/**
 保存按钮代理方法
 
 @param timer 选择的数据
 */
- (void)datePickerViewSaveBtnClickDelegate:(NSString *)timer;

@end

@interface TimeZonePickerView : UIView

@property (strong, nonatomic) UIPickerView *pickerView; // 选择器

@property (copy, nonatomic) NSString *title;
/// 是否自动滑动 默认YES
@property (assign, nonatomic) BOOL isSlide;

/// 选中的时间， 默认是当前时间 2017-02-12 13:35
@property (copy, nonatomic) NSString *date;

@property (weak, nonatomic) id <TimeZonePickerViewDelegate> delegate;

///是否正在显示
@property (nonatomic, getter = isShowing) BOOL show;
/**
 显示  必须调用
 */
- (void)show:(NSString *)month andDay:(NSString *)day;
@end

