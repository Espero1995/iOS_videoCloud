//
//  SetTimeViewController.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
#import "BaseViewController.h"
@interface SetTimeViewController : BaseViewController

@property (nonatomic,strong) NSMutableArray * weekArray;

@property (nonatomic,strong) dev_list * listModel;

@property (nonatomic,assign) BOOL subing;

@end
