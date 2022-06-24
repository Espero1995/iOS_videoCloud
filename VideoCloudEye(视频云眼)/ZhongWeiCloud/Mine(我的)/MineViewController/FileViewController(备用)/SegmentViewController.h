//
//  SegmentViewController.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BaseViewController.h"
@class SegmentViewController;
@protocol SegmentControl_Delegete <NSObject>
- (void)SegmentControlDeleteBtnClick:(SegmentViewController *)segmentController;
- (void)SegmentControlChooseAllCell:(SegmentViewController *)segmentController;
- (BOOL)SegmentControlEditCollectCell:(SegmentViewController *)segmentController;
- (void)SegmentControlCancleEdit:(SegmentViewController *)segmentController;
@end



@interface SegmentViewController : BaseViewController
@property (nonatomic,strong) UIButton * allChoose;
@property (nonatomic,strong) UIButton * deleteBtn;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic,assign) BOOL bIsVideo;
@property (nonatomic,strong) id<SegmentControl_Delegete>delegete;
@property (nonatomic,strong) id<SegmentControl_Delegete>delegeSoure;

- (void)setDefaultNav;
@end
