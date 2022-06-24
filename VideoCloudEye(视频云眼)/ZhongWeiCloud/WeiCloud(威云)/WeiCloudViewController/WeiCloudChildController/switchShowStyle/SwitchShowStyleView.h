//
//  SwitchShowStyleView.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/19.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TAG_CLOSEBTN                  0x600
#define TAG_ADDGROUPBTN               0x601
#define TAG_LITTLEMODE                0x602
#define TAG_LARGEMODE                 0x603
#define TAG_FOURSCREENMODE            0x604

@protocol SwitchShowStyleViewDelegate<NSObject>
//切换组别
- (void)SwitchGroupClick:(NSInteger)index;
//对组别进行设置
- (void)GroupSettingClick:(NSInteger)index;
//视图展现
- (void)SwitchShowStyleBtnClick:(UIButton*)btn;

@end

@interface SwitchShowStyleView : UIView
@property (nonatomic, strong) UIView* switchShowStyle_bgView;/**< 选择不同分组类型的bgView */
@property (nonatomic, strong) UIView* switchShowBtn_bgView;/**< 最下面的切换不同分组的btn的bgView */
@property (nonatomic, strong) UIButton* closeBtn;/**< 关闭btn */
@property (nonatomic, strong) UIButton* addGroupBtn;/**< 添加分组功能按钮 */
@property (nonatomic, strong) UIButton* littleMode;/**< 小屏模式 */
@property (nonatomic, strong) UIButton* largeMode;/**< 大屏模式 */
@property (nonatomic, strong) UIButton* fourScreenMode;/**< 左右--四分屏模式 */
@property (nonatomic, strong) UIView* line1_vertical;/**< 竖线1 */
@property (nonatomic, strong) UIView* line2_vertical;/**< 竖线2 */
@property (nonatomic, strong) UIView* line1_horizontal;/**< 添加分组上面的横线1 */

@property (nonatomic, assign) id<SwitchShowStyleViewDelegate> delegate;/**< 代理指针 */


- (instancetype)initWithFrame:(CGRect)frame GroupData:(NSMutableArray *)data;
- (void)changeSwitchShowFrameandData:(NSArray *)dataArr;
- (void)updateUIAfterGroupCreatedGroupData:(NSMutableArray *)data;
@end
