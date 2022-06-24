//
//  DeviceNameCell_t.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/3/1.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeviceNameCell_t;
@protocol DeviceNameCell_tDelegete <NSObject>

-(void)DeviceNameCell_tChooseBtnClick:(DeviceNameCell_t *)cell;

@end

@interface DeviceNameCell_t : UITableViewCell

@property (nonatomic,strong) UITextField * nameText;

@property (nonatomic,strong) UIButton * deleteBtn;

@property (nonatomic,weak) id <DeviceNameCell_tDelegete>delegete;

@end
