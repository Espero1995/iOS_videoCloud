//
//  CloudStorageCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CloudStorageCell;

/*代理协议*/
@protocol CloudStorageCellDelegate <NSObject>
//续费或者开通的按钮
- (void)CloudStorageCellOpenCloudClick:(CloudStorageCell *)cell;
@end

@interface CloudStorageCell : UITableViewCell
/*设备图片*/
@property (strong, nonatomic) IBOutlet UIImageView *device_Img;
/*设备名*/
@property (strong, nonatomic) IBOutlet UILabel *deviceName_lb;
/*当前提示*/
@property (strong, nonatomic) IBOutlet UILabel *currentStausTip_lb;
/*套餐类型*/
@property (strong, nonatomic) IBOutlet UILabel *mealType_lb;
/*到期/推荐 提示*/
@property (strong, nonatomic) IBOutlet UILabel *toDateTip_lb;
/*套餐到期时间*/
@property (strong, nonatomic) IBOutlet UILabel *mealTime_lb;
/*续费或者开通的按钮*/
@property (strong, nonatomic) IBOutlet UIButton *openCloud_btn;
/*代理协议*/
@property (nonatomic,weak)id<CloudStorageCellDelegate>cellDelegate;
@end
