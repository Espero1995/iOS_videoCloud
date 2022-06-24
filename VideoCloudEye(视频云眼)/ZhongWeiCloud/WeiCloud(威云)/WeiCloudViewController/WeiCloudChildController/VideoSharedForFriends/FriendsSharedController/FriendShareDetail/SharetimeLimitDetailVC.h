//
//  SharetimeLimitVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/16.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"
//#import "ShareFeatureModel.h"
@interface SharetimeLimitDetailVC : BaseViewController
@property (nonatomic,strong) dev_list* dev_mList;
@property (nonatomic,strong) shareFeature *shareModel;
/*被分享人的ID*/
@property (nonatomic,copy) NSString *sharedPersonID;
@end
