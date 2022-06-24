//
//  ApLoginView.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/5/7.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"
@protocol AploginViewDelegate <NSObject>
- (void)closeBtnClick:(UIButton *)btn;
- (void)startBtnClick:(UIButton *)btn;
@end
@interface ApLoginView : UIView
/**
 * 代理指针
 */
@property (nonatomic, assign) id<AploginViewDelegate>delegate;

/**
 * 自定义的tf
 */
@property (nonatomic, strong) CustomTextField* customTF;
/**
 * 账户框
 */
@property (nonatomic, strong) UITextField* accountTF;
/**
 * 密码框
 */
@property (nonatomic, strong) UITextField* psdTF;

- (void)disappear;

@end
