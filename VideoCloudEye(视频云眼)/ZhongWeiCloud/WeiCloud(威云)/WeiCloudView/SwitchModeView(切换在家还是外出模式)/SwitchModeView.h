//
//  SwitchModeView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/31.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^isStatusBlock)(BOOL isStatus);
@interface SwitchModeView : UIView
@property (nonatomic,strong)isStatusBlock block;

/**
 返回这个View
 
 @param frame view的大小
 @return 返回这个View
 */
- (instancetype)initWithframe:(CGRect) frame;

//切换模式View展示
- (void)switchModeViewShow:(BOOL)isStatus andGroupID:(NSString *)groupID;
@end
