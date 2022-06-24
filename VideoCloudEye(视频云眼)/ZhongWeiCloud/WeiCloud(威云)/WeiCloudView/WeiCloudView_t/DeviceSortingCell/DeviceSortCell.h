//
//  DeviceSortCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
@interface DeviceSortCell : UITableViewCell
@property (nonatomic,strong)dev_list *model;
@property (strong, nonatomic) IBOutlet UILabel *lab_name;
@property (weak, nonatomic) IBOutlet UIImageView *ima_photo;
@property (weak, nonatomic) IBOutlet UIView *bankView;
@property (strong, nonatomic) IBOutlet UILabel *lab_fromName;

@end
