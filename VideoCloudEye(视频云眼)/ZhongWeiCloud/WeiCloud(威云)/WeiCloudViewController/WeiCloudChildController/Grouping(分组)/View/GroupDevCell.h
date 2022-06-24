//
//  GroupDevCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/27.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupDevCell;
@protocol GroupDevCellDelegate <NSObject>
- (void)GroupSettingClick:(GroupDevCell *)cell;//对设备组别进行设置
@end
@interface GroupDevCell : UITableViewCell
@property (nonatomic,strong) UILabel *titleLb;
@property (nonatomic,strong) UIButton *setBtn;

@property (nonatomic,weak)id<GroupDevCellDelegate>delegate;
@end
