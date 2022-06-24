//
//  GroupSettingVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/27.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "groupModel.h"
@interface GroupSettingVC : BaseViewController
@property (nonatomic,strong) groupModel *groupModel;//组
@property (nonatomic, strong) NSMutableArray *devModelArr;//该组下的设备
@property (nonatomic, assign) NSInteger groupIndex;/**< 当前的组index */

@end
