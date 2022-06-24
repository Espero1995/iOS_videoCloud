//
//  WeiCloudCell_t.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
@class WeiCloudCell_t;
@protocol WeiCloudCelltDelegate <NSObject>
@optional
- (void)WeiCloudCellBtnSettingClick:(WeiCloudCell_t *)cell andEvent:(UIEvent *)event;
- (void)stayHomeBtnClick:(UIButton *)sender WithCell:(WeiCloudCell_t *)cell;
- (void)WeiCloudCellSDVideoClick:(WeiCloudCell_t *)cell;
- (void)WeiCloudCellCloudVideoClick:(WeiCloudCell_t *)cell;
- (void)WeiCloudCellAlarmVideoClick:(WeiCloudCell_t *)cell;
@end
@class dev_list;
@interface WeiCloudCell_t : UITableViewCell
@property (nonatomic,weak)id<WeiCloudCelltDelegate>cellDelegate;
@property (nonatomic,strong)dev_list *model;
@property (nonatomic,strong) NSMutableString * nameStr;
@property (strong, nonatomic) IBOutlet UILabel *lab_name;
@property (weak, nonatomic) IBOutlet UIImageView *ima_photo;
@property (weak, nonatomic) IBOutlet UIView *bankView;
@property (weak, nonatomic) IBOutlet UIButton *btn_setting;
@property (strong, nonatomic) IBOutlet UIButton *alarmBtn;
@property (strong, nonatomic) IBOutlet UIButton *sdBtn;
@property (strong, nonatomic) IBOutlet UIButton *cloudBtn;
/*是否在线   蓝色：在线；灰色：不在线*/
@property (strong, nonatomic) IBOutlet UIImageView *isOnline_img;
@property (strong, nonatomic) IBOutlet UIView *bgView;

@end
