//
//  SharePeriodVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/16.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"

@interface SharePeriodVC : BaseViewController
@property (nonatomic,strong) dev_list* dev_mList;
/*开始时间*/
@property (nonatomic,copy) NSString* startTime;
/*结束时间*/
@property (nonatomic,copy) NSString* endTime;
@property (nonatomic,strong) NSMutableDictionary *modifyPermissionDic;//权限信息字典
@end
