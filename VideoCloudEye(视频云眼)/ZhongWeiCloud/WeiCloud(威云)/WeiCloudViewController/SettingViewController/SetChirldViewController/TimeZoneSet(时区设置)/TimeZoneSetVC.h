//
//  TimeZoneSetVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/12/28.
//  Copyright © 2018 张策. All rights reserved.
//

#import "TimeZoneModel.h"
@interface TimeZoneSetVC : BaseViewController
/**
 设备模型列表
 */
@property (nonatomic,strong) dev_list* dev_mList;
@property (nonatomic,strong) TimeZoneModel *model;
@end

