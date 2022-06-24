//
//  WeiCloudCell_t.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class smallScreenChannelCell;
@protocol smallScreenChannelCellDelegate <NSObject>
@optional
- (void)smallChannelCellSDVideoClick:(smallScreenChannelCell *)cell;
- (void)smallChannelCellCloudVideoClick:(smallScreenChannelCell *)cell;
- (void)smallChannelCellAlarmVideoClick:(smallScreenChannelCell *)cell;
@end
@class ChannelCodeListModel;
@interface smallScreenChannelCell : UITableViewCell
@property (nonatomic,weak)id<smallScreenChannelCellDelegate>cellDelegate;
@property (nonatomic,strong) ChannelCodeListModel *channelModel;
@property (strong, nonatomic) IBOutlet UILabel *lab_name;
@property (weak, nonatomic) IBOutlet UIImageView *ima_photo;
@property (weak, nonatomic) IBOutlet UIView *bankView;
@property (strong, nonatomic) IBOutlet UIButton *alarmBtn;
@property (strong, nonatomic) IBOutlet UIButton *sdBtn;
@property (strong, nonatomic) IBOutlet UIButton *cloudBtn;

@property (strong, nonatomic) IBOutlet UIView *bgView;

@end
