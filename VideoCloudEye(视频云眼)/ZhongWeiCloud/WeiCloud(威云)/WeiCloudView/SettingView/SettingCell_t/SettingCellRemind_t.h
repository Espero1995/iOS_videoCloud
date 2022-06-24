//
//  SettingCellRemind_t.h
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetTimeModel.h"

@interface SettingCellRemind_t : UITableViewCell
@property (nonatomic,strong) UILabel * typeLabel;//类型

@property (nonatomic,strong) UILabel * titleLabel;//标题

@property (nonatomic,strong) UILabel * scopeLabel;//时间范围

@property (nonatomic,strong) UIImageView * pushImage;//箭头

@property (nonatomic,strong) guardConfigList * model;
@end
