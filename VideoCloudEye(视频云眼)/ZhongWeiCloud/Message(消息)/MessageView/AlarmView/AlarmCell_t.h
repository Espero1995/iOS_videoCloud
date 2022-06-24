//
//  AlarmCell_t.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/16.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushMsgModel.h"
@class AlarmCell_t;
@protocol AlarmCell_tDelegete <NSObject>

- (void)AlarmCell_tChooseBtnClick:(AlarmCell_t *)cell;

- (void)Alarmcell_tPictureImageClick:(AlarmCell_t *)cell;
@end

@interface AlarmCell_t : UITableViewCell

@property (nonatomic,strong) UIView * topView;//顶部视图

@property (nonatomic,strong) UILabel * timeLabel;//时间

@property (nonatomic,strong) UIButton * chooseBtn;//选择按钮

@property (nonatomic,strong) UIImageView * attentionView;//红点

@property (nonatomic,strong) UILabel * typeLabel;//类型

@property (nonatomic,strong) UILabel * messageLabel;//来源

@property (nonatomic,strong) UIImageView * pictureImage;//图片

@property (nonatomic,strong) UIView * lineView1;//线
@property (nonatomic,strong) UIView * lineView2;//线

@property (nonatomic,weak) id<AlarmCell_tDelegete>delegete;
@property (nonatomic,weak) id<AlarmCell_tDelegete>detaSore;

@property (nonatomic,strong) PushMsgModel * model;
@end
