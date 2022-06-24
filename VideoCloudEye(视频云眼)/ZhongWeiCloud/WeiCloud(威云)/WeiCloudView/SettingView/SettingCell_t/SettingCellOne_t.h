//
//  SettingCellOne_t.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetTimeModel.h"

@interface SettingCellOne_t : UITableViewCell
@property (nonatomic,strong) UILabel * typeLabel;//类型

@property (nonatomic,strong) UILabel * titleLabel;//标题

@property (nonatomic,strong) UIImageView * pushImage;//箭头

@property (nonatomic,strong) guardConfigList * model;

@property (nonatomic,strong) UIImageView *redDotImg;//红点

@end
