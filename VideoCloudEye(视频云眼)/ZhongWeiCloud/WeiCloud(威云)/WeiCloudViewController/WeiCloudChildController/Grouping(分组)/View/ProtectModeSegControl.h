//
//  ProtectModeSegControl.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProtectModeSegControlDelegate <NSObject>
/**
 *  选中的segment的下标
 *
 *  @param index 0 是第一个 1 是第二个
 */
- (void)didSelectSegmentWithIndex:(NSInteger)index;
@end

@interface ProtectModeSegControl : UIView
@property (nonatomic, weak) id<ProtectModeSegControlDelegate>delegate;/*代理属性*/

/**
 *  需要传入标题数组
 *  圆角半径默认为4
 *  @param titleArs 标题数组
 *
 *  @return return value description
 */

+ (instancetype)creatSegmentedControlWithTitle:(NSArray *)titleArs ;

/**
 *  需要特殊的设置圆角半径 调用此方法
 *
 *  @param titleArs 标题数组
 *  @param radius   圆角半径
 *
 *  @return return value description
 */

+(instancetype)creatSegmentedControlWithTitle:(NSArray *)titleArs withRadius:(NSInteger)radius;

/**
 *  有些情况的特殊需要 比如 初始化的时候默认 第二个是选中状态
 */
- (void)updateSelectedWithIndex:(NSInteger)index;


@end
