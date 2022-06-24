//
//  GroupChoosingVC.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/22.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "groupModel.h"
@interface GroupChoosingVC : BaseViewController

/**
 * description：      1：表示通过新添加组进入添加设备；
                      2：表示通过已有组时进入添加设备；
                      3：表示通过已有组时进入删除设备；
 */
@property (nonatomic,assign) int chooseWay;
@property (nonatomic, strong) NSArray* deviceArr;/**< tableview的数据源 */
@property (nonatomic,strong) groupModel *groupModel;//组model
@property (nonatomic, assign) NSInteger groupIndex;/**< 当前的组index */
@end
