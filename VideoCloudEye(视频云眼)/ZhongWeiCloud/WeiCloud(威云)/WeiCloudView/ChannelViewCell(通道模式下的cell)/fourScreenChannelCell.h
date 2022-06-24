//
//  fourScreenChannelCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class fourScreenChannelCell;
@protocol fourChannelCellDelegate <NSObject>
- (void)fourChannelCellSDVideoClick:(fourScreenChannelCell *)cell;
- (void)fourChannelCellCloudVideoClick:(fourScreenChannelCell *)cell;

- (void)fourChannelCellAlarmVideoClick:(fourScreenChannelCell *)cell;

@end
@class ChannelCodeListModel;
@interface fourScreenChannelCell : UICollectionViewCell
//设备名称
@property (strong, nonatomic) IBOutlet UILabel *deviceName_Lb;
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

/*设备信息model*/
@property (nonatomic,strong) ChannelCodeListModel *channelModel;

@property (nonatomic,weak)id<fourChannelCellDelegate> delegate;
@end
