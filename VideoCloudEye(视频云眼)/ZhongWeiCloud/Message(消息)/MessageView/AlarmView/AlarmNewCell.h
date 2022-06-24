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
- (void)Alarmcell_tPictureImageClick:(AlarmNewCell *)cell;
@end

@interface AlarmNewCell : UITableViewCell
/*正文视图*/
@property (nonatomic,strong) UIView * mainbodyView;
/*几号+星期*/
@property (nonatomic,strong) UILabel * weekLabel;
/*时间*/
@property (nonatomic,strong) UILabel * timeLabel;
/*选择按钮*/
@property (nonatomic,strong) UIButton * chooseBtn;
/*红点*/
@property (nonatomic,strong) UIImageView * attentionView;
/*类型*/
@property (nonatomic,strong) UILabel * typeLabel;
/*来源*/
@property (nonatomic,strong) UILabel * messageLabel;
/*图片*/
@property (nonatomic,strong) UIImageView * pictureImage;

@property (nonatomic,assign) BOOL isEdit;

@property (nonatomic,weak) id<AlarmCell_tDelegete>delegete;

@property (nonatomic,assign) BOOL isDefaultSelect;


@end
