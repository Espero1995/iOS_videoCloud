//
//  GroupNoDevBGView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GroupNoDevBGViewDelegate <NSObject>
- (void)shopBtnClick;//点击商城按钮
@end
@interface GroupNoDevBGView : UIView
@property (nonatomic,weak)id<GroupNoDevBGViewDelegate>delegate;
/*
 *  description: 数据源 弹出位置 宽度 单个cell高度
 */
- (instancetype)initWithFrame : (CGRect) frame
                      bgColor : (UIColor *) bgColor
                        bgImg : (UIImage *) bgImg
                        bgTip : (NSString *)tipStr;
@end
