//
//  SettingViewController.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
#import "BaseViewController.h"
@interface SettingViewController : BaseViewController
@property (nonatomic,strong) NSMutableString * hourTime;

@property (nonatomic,strong) NSMutableString * minTime;

@property (nonatomic,strong) NSMutableString * nameString;

@property (nonatomic,copy) NSMutableString * weekString;

@property (nonatomic,assign) BOOL subing;

@property (nonatomic,strong) dev_list * listModel;

@property (nonatomic,assign) int chan_size;

@property (nonatomic,assign) NSInteger status;

@property (nonatomic,strong) NSIndexPath *currentIndex;

/*是否支持云存*/
@property (nonatomic,assign) int isCloudStorage;
@end
