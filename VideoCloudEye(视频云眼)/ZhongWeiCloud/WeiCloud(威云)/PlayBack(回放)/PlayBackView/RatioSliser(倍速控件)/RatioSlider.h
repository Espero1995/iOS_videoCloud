//
//  CustomSlider.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/13.
//  Copyright © 2018年 张策. All rights reserved.
//
typedef void(^valueChangeBlock)(int index);

#import <UIKit/UIKit.h>

@interface RatioSlider : UIControl

/**
 *  回调
 */
@property (nonatomic,copy)valueChangeBlock block;

/**
 *  初始化方法
 *
 *  param  frame
 *  param  titleArray         必传，传入节点数组
 *  param  firstAndLastTitles 首，末位置的title
 *  param  defaultIndex       必传，范围（0到(array.count-1)）
 *  param  sliderImage        传入画块图片
 *
 *  return
 */
-(instancetype)initWithFrame:(CGRect)frame
                      titles:(NSArray *)titleArray
                defaultIndex:(CGFloat)defaultIndex
                 sliderImage:(UIImage *)sliderImage;

@end
