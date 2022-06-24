//
//  PlayBackViewController.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "BaseViewController.h"
@class dev_list;
@interface PlayBackViewController : BaseViewController
@property (nonatomic,strong)dev_list *listModel;
//标题视频设备名称
@property (nonatomic,copy)NSString *titleName;
@end
