//
//  GroupnoDevCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GroupnoDevCellDelegate <NSObject>
/*
 * (无设备时添加)添加设备
 */
- (void)noDevAddClick;
@end

@interface GroupnoDevCell : UITableViewCell
@property (nonatomic,strong) UIButton *addorDeleteBtn;
@property (nonatomic,strong) UILabel *tipLb;
@property (nonatomic,assign) BOOL isMydevGroup;
@property (nonatomic, weak) id<GroupnoDevCellDelegate> delegate;
@end
