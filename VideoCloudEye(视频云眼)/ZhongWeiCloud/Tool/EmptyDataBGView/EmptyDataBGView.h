//
//  EmptyDataBGView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyDataBGView : UIView

/*
 *  description: 数据源 弹出位置 宽度 单个cell高度
 */
- (instancetype)initWithFrame : (CGRect) frame
                      bgColor : (UIColor *) bgColor
                        bgImg : (UIImage *) bgImg
                        bgTip : (NSString *)tipStr;

@end
