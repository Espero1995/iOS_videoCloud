//
//  DeviceNameController.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/3/1.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
#import "BaseViewController.h"
@interface DeviceNameController : BaseViewController
@property (nonatomic,strong) NSMutableString * deviceName;

@property (nonatomic,strong) dev_list * listModel;

@property (nonatomic,strong) NSIndexPath *currentIndex;
@end
