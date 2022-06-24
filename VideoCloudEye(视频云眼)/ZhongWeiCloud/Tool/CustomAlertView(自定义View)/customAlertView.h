//
//  customAlertView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/8.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol customAlertViewDelegate <NSObject>
- (void)downOutViewSelectRowAtIndex:(NSInteger)index;
@end

@interface customAlertView : UIView
/*代理方法*/
@property (nonatomic) id<customAlertViewDelegate> delegate;

/*
 *  description: 数据源 弹出位置 宽度 单个cell高度
 */
- (instancetype)initWithDataArr : (NSArray *)dataArr
                                    origin : (CGPoint)point
                                    width : (CGFloat)width
                           Singleheight : (CGFloat)height
                                       title : (NSString *)title
                                message : (NSString *)message
                                 isRolling : (BOOL)isRolling
                       headTitleHeight : (CGFloat)titleHeight;

//警告框显示
- (void)customAlertViewShow;
//警告框消失
- (void)customAlertViewDismiss;

@end
