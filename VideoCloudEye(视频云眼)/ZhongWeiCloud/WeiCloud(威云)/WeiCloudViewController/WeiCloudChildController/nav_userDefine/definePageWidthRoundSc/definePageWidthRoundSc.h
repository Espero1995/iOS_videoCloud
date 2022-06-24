//
//  definePageWidthRoundSc.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/9/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol definePageWidthRoundScDelegate <NSObject>
- (void)groupBtnClick:(UIButton *)btn;

@end

@interface definePageWidthRoundSc : UIView
@property (nonatomic, strong) UIScrollView* sc;/**< 自定义滚动page大小的sc */
@property (nonatomic, assign) CGFloat navCurrentHeight;/**< 获取到的自定义nav的height */
@property (nonatomic, assign) id<definePageWidthRoundScDelegate>delegate;/**< 代理 */

@property (nonatomic, strong) NSMutableArray* groupNameArr;/**< 存放组名称的数组 */
@property (nonatomic, strong) NSMutableArray* groupIDArr;/**< 存放组ID的数组 */
@property (nonatomic, strong) NSMutableArray* groupBtnArr;/**< 存放分组的btn */
@property (nonatomic, strong) NSMutableArray* groupBtnLabelArr;/**< 存放分组btn的名称label*/

-(instancetype)initWithFrame:(CGRect)frame
                GroupNameArr:(NSMutableArray *)groupNameArr
                  GroupIDArr:(NSMutableArray *)groupIDArr
            GroupBtnLabelArr:(NSMutableArray *)groupBtnLabelArr
                 GroupBtnArr:(NSMutableArray *)groupBtnArr;

- (void)setScContentSize:(CGSize)scContentSize;
- (void)setScContentOffset:(CGPoint)scContentOffset;
- (void)CreateGroupSuccess;
- (void)changeBtnAndTitleFrameAnimationIsUp:(BOOL)isUp;
@end
