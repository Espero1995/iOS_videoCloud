//
//  UpdataViewController.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WeiCloudListModel.h"
@interface UpdataViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UILabel *lab_deveName;
@property (weak, nonatomic) IBOutlet UILabel *lab_versionNow;
@property (weak, nonatomic) IBOutlet UILabel *lab_versionUp;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) dev_list * listModel;
@property (nonatomic,copy) NSString * dev_name;//设备名
//停止定时器
- (void)stopTimer;
@end
