//
//  SharePeriodVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/16.
//  Copyright © 2018年 张策. All rights reserved.
//


#import "WeiCloudListModel.h"
//#import "ShareFeatureModel.h"
@interface SharePeriodDetailVC : BaseViewController
@property (nonatomic,strong) dev_list* dev_mList;
/*开始时间*/
@property (nonatomic,copy) NSString* startTime;
/*结束时间*/
@property (nonatomic,copy) NSString* endTime;
/*被分享人的ID*/
@property (nonatomic,copy) NSString *sharedPersonID;
@property (nonatomic,strong) shareFeature *shareModel;

@end
