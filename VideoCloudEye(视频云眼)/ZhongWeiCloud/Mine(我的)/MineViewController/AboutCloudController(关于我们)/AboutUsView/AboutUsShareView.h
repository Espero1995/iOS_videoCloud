//
//  AboutUsShareView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/21.
//  Copyright © 2018 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AboutUsShareView : UIView
@property (nonatomic,strong) UIImage *shareImg;
/**
 返回这个View
 @param frame view的大小
 @return 返回这个View
 */
- (instancetype)initWithframe:(CGRect)frame;
//设置弹出框视图展示
- (void)setAboutUsShareViewShow;
@end
