//
//  AlarmNewCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/12.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushMsgModel.h"
@class AlarmNewCell;

@protocol AlarmCell_tDelegete <NSObject>
@optional
- (void)AlarmCell_tChooseBtnClick:(AlarmNewCell *)cell;
@optional
- (void)Alarmcell_tPictureImageClick:(AlarmNewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@interface AlarmNewCell : UITableViewCell

@property (nonatomic, strong) PushMsgModel *alermModel;

@property (nonatomic,assign) BOOL isEdit;

@property (nonatomic,weak) id<AlarmCell_tDelegete>delegete;

@property (nonatomic,assign) BOOL isDefaultSelect;

@property (nonatomic,strong) NSIndexPath *indexPath;

// 红点显示控制
- (void)configRedPointHidden:(BOOL)hidden;
// 选择按钮显示控制
- (void)configChooseBtnHidden:(BOOL)hidden;
// 全选控制
- (void)configChooseBtnSeleted:(BOOL)selected;

@end
