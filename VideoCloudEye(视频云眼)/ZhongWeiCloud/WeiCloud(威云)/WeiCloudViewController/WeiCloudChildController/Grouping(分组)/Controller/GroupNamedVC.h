//
//  GroupNamedVC.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupNamedVC : UIViewController
@property (nonatomic, strong) NSMutableArray* deviceIdsArr;/**< 创建分组的时候，添加的设备id */
@property (nonatomic, strong) NSMutableArray* chansArr;/**< 创建分组的时候，添加设备中有net4设备的时候，的通道id */

@end
