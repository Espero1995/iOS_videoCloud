//
//  nav_userDefine.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/18.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "definePageWidthRoundSc.h"

@protocol nav_userDefine_delegate <NSObject>
- (void)leftItemBtnClick;
- (void)rightItemBtnClick;
- (void)groupBtnClick;
- (void)searchItemBtnClick;
@end

@interface nav_userDefine : UIView
@property (nonatomic, strong) UIView* nav_userDefine_bgView;/**< 自定义导航条的背景view */
@property (nonatomic, strong) UIButton* leftItemBtn;/**< 左边itemBtn */
@property (nonatomic, strong) UIButton* rightItemBtn;/**< 右边itemBtn */
@property (nonatomic, strong) UIButton* searchBtn;/**< 右侧的搜索按钮*/

@property (nonatomic, strong) UIButton* centerBtn;/**< 中间的分组btn */
@property (nonatomic, strong) UILabel* centerBtnLabel;/**< 中间的分组btn名称，为了分别动画，单独用label实现 */
@property (nonatomic, strong) definePageWidthRoundSc* sc;/**< 自定义导航条的中间button的背景sc */

@property (nonatomic, strong) UIColor* nav_main_bgColor;/**< 此自定义导航条的背景颜色 */
@property (nonatomic, assign) id<nav_userDefine_delegate>delegate;/**< 代理 */

@property (nonatomic, strong) NSMutableArray* groupNameArr;/**< 存放组名称的数组 */
@property (nonatomic, strong) NSMutableArray* groupIDArr;/**< 存放组ID的数组 */
@property (nonatomic, strong) NSMutableArray* groupBtnArr;/**< 存放分组的btn */
@property (nonatomic, strong) NSMutableArray* groupBtnLabelArr;/**< 存放分组btn的名称label*/



- (instancetype)initWithFrame:(CGRect)frame GroupNameAndIDArr:(NSMutableArray *)groupNameAndIDArr;
- (void)changeNavFrameAnimation:(NSTimeInterval)duration IsUp:(BOOL)isUp compeleteBlock:(void (^)())compeleteBlock;
@end
