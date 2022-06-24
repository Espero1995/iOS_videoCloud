//
//  SharePermissionVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"
//#import "ShareFeatureModel.h"
@interface SharePermissionDetailVC : BaseViewController
@property (nonatomic,strong) dev_list* dev_mList;
/*分享设备能力集model*/
@property (nonatomic,strong) shareFeature *shareModel;
/*被分享人的ID*/
@property (nonatomic,copy) NSString *sharedPersonID;
@end
