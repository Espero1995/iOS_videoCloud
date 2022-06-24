//
//  DeviceCollectionCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
@class DeviceCollectionCell;
@protocol DeviceCollectionDelegate <NSObject>
- (void)DeviceCollectionSettingClick:(DeviceCollectionCell *)cell andEvent:(UIEvent *)event;
- (void)DeviceCollectionSDVideoClick:(DeviceCollectionCell *)cell;
- (void)DeviceCollectionCloudVideoClick:(DeviceCollectionCell *)cell;

- (void)DeviceCollectionAlarmVideoClick:(DeviceCollectionCell *)cell;

@end
@class dev_list;
@interface DeviceCollectionCell : UICollectionViewCell
//设备名称
@property (strong, nonatomic) IBOutlet UILabel *deviceName_Lb;
//设置按钮
@property (strong, nonatomic) IBOutlet UIButton *btn_setting;
//图片
@property (strong, nonatomic) IBOutlet UIImageView *ima_photo;
//SD卡按钮
@property (strong, nonatomic) IBOutlet UIButton *sdBtn;
//云端按钮
@property (strong, nonatomic) IBOutlet UIButton *cloudBtn;
//告警按钮
@property (strong, nonatomic) IBOutlet UIButton *alarmBtn;
//不在线时的背景图
@property (strong, nonatomic) IBOutlet UIView *backView;
//不在线
@property (strong, nonatomic) IBOutlet UILabel *lab_unLine;
//是否在线   蓝色：在线；灰色：不在线
@property (strong, nonatomic) IBOutlet UIImageView *isOnline_img;

/*设备信息model*/
@property (nonatomic,strong)dev_list *model;

@property (nonatomic,strong) NSMutableString * nameStr;
@property (nonatomic,weak)id<DeviceCollectionDelegate> delegate;
@end
