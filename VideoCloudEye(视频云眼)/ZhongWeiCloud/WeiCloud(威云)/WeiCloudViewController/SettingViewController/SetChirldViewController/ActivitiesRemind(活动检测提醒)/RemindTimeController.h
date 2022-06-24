//
//  RemindTimeController.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/19.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"

@interface RemindTimeController : BaseViewController

/**
 设备模型列表
 */
@property (nonatomic,strong) dev_list* dev_mList;
/*灵敏度*/
@property (nonatomic,copy) NSString* sensibility;
/*开始时间*/
@property (nonatomic,copy) NSString* startTime;
/*结束时间*/
@property (nonatomic,copy) NSString* endTime;
/*周期*/
@property (nonatomic,copy) NSString* periodStr;
@end
