//
//  NoNetworkBGView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/31.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NoNetworkBGViewDelegate <NSObject>
- (void)refreshBtnClick;//点击刷新按钮
@end
@interface NoNetworkBGView : UIView
@property (nonatomic,weak)id<NoNetworkBGViewDelegate>delegate;
/*
 *  description: 数据源 弹出位置 宽度 单个cell高度
 */
- (instancetype)initWithFrame : (CGRect) frame
                      bgColor : (UIColor *) bgColor
                        bgImg : (UIImage *) bgImg
                        bgTip : (NSString *)tipStr;
@end
