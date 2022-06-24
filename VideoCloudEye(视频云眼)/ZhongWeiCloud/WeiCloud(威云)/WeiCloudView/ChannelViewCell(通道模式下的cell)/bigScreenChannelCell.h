//
//  bigScreenChannelCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/14.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class bigScreenChannelCell;
/*代理协议*/
@protocol bigChannelCellDelegate <NSObject>

- (void)bigChannelCellSDVideoClick:(bigScreenChannelCell *)cell;
- (void)bigChannelCellCloudVideoClick:(bigScreenChannelCell *)cell;
- (void)bigChannelCellAlarmVideoClick:(bigScreenChannelCell *)cell;
@end
@class ChannelCodeListModel;
@interface bigScreenChannelCell : UITableViewCell
/*设备名*/
@property (strong, nonatomic) IBOutlet UILabel *deviceName_Lb;
/*显示的图片*/
@property (strong, nonatomic) IBOutlet UIImageView *ima_photo;

@property (strong, nonatomic) IBOutlet UIView *bgView;
/*设备信息model*/
@property (nonatomic,strong) ChannelCodeListModel *channelModel;
/*代理协议*/
@property (nonatomic,weak)id<bigChannelCellDelegate>cellDelegate;

@end
