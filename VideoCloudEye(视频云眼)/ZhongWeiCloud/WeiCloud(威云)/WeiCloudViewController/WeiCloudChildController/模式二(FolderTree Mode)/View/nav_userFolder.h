//
//  nav_userFolder.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/16.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol nav_userFolder_delegate <NSObject>
/**
 * @brief 返回按钮点击事件
 */
- (void)backFolderTreeClick;
/**
 * @brief 模式切换按钮点击事件
 */
- (void)leftItemBtnClick;
/**
 * @brief 添加设备按钮点击事件
 */
- (void)rightItemBtnClick;

@end


@interface nav_userFolder : UIView
@property (nonatomic, strong) UIButton* leftItemBtn;/**< 左边itemBtn */
@property (nonatomic, strong) UIButton* backBtn;/**< 返回按钮*/
@property (nonatomic, copy) NSString *titleStr;/**< 标题*/

@property (nonatomic, assign) id<nav_userFolder_delegate>delegate;/**< 代理 */

@end

