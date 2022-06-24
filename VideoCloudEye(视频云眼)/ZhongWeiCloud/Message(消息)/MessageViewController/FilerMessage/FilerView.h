//
//  FilerView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilerViewDelegate <NSObject>
//tableView点击事件
- (void)SelectSectionofRowAtIndex:(NSIndexPath *)indexPath;
//关闭筛选视图
- (void)closeFilerView;
//重置点击按钮
- (void)resetAllinfoClick;
//确定点击按钮
- (void)submitFlierClick;
@end

@interface FilerView : UIView

/*代理方法*/
@property (nonatomic) id<FilerViewDelegate> delegate;

/**
 返回这个View

 @param dateArr 时间数组
 @param frame view的大小
 @return 返回这个View
 */
- (instancetype)initWithDateArr : (NSArray *)dateArr
                          frame : (CGRect) frame;

//获取设备名数组
- (void)getDeviceNameArr:(NSMutableArray *)arr;
//获取设备名数组并重置日期
- (void)resetDateandGetDeviceNameArr:(NSMutableArray *)arr;
@end
