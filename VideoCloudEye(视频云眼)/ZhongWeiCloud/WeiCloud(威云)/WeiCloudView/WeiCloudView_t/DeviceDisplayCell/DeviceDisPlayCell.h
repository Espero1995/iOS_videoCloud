//
//  DeviceDisPlayCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/14.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
@class DeviceDisPlayCell;

/*代理协议*/
@protocol DeviceDisPlayCellDelegate <NSObject>
- (void)DeviceDisPlayCellSettingClick:(DeviceDisPlayCell *)cell andEvent:(UIEvent *)event;
- (void)DeviceDisPlayCellSDVideoClick:(DeviceDisPlayCell *)cell;
- (void)DeviceDisPlayCellCloudVideoClick:(DeviceDisPlayCell *)cell;
- (void)DeviceDisPlayCellAlarmVideoClick:(DeviceDisPlayCell *)cell;
@end

@class dev_list;

@interface DeviceDisPlayCell : UITableViewCell
/*设备名*/
@property (strong, nonatomic) IBOutlet UILabel *deviceName_Lb;
/*设置按钮*/
@property (strong, nonatomic) IBOutlet UIButton *btn_setting;
/*显示的图片*/
@property (strong, nonatomic) IBOutlet UIImageView *ima_photo;
/*是否在线   蓝色：在线；灰色：不在线*/
@property (strong, nonatomic) IBOutlet UIImageView *isOnline_img;
@property (strong, nonatomic) IBOutlet UIView *bgView;

/*设备信息model*/
@property (nonatomic,strong)dev_list *model;
/*图片名*/
@property (nonatomic,strong) NSMutableString * nameStr;
/*代理协议*/
@property (nonatomic,weak)id<DeviceDisPlayCellDelegate>cellDelegate;

@end
