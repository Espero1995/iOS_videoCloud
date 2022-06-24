//
//  OperationLog_t.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/9/26.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogModel.h"
@class opLogList;
@interface OperationLog_t : UITableViewCell
@property (nonatomic,strong) UILabel * dateLabel;//日期
@property (nonatomic,strong) UILabel * timeLabel;//时间
@property (nonatomic,strong) UIImageView * picView;//圆圈
@property (nonatomic,strong) UIView * lineView;//线
@property (nonatomic,strong) UILabel * conLabel;//操作名臣
@property (nonatomic,strong) UILabel * logLabel;//操作内容
@property (nonatomic,strong) UILabel * ipLabel;//操作ip
@property (nonatomic,strong) opLogList * model;
@end
