//
//  MyCloudStorageCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/25.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

/*代理协议*/
@protocol MyCloudStorageCellDelegate <NSObject>
//续费
- (void)MyCloudStorageCellExtendedUserClick;
@end

@interface MyCloudStorageCell : UITableViewCell
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
/*下一个套餐是否生效*/
@property (strong, nonatomic) IBOutlet UILabel *nextMealEffect_lb;
/*下一个套餐类型*/
@property (strong, nonatomic) IBOutlet UILabel *nextMealType_lb;
@property (strong, nonatomic) IBOutlet UIButton *extendedBtn;

/*代理协议*/
@property (nonatomic,weak)id<MyCloudStorageCellDelegate>cellDelegate;

@end
