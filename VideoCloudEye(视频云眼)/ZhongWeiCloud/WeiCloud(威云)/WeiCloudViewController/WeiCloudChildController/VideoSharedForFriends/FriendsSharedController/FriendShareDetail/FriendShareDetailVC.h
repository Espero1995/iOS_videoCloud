//
//  FriendShareDetailVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
//#import "ShareFeatureModel.h"
@interface FriendShareDetailVC : BaseViewController
/*被分享人的ID*/
@property (nonatomic,copy) NSString *sharedPersonID;
@property (nonatomic,strong) dev_list* dev_mList;
/*分享设备能力集model*/
@property (nonatomic,strong) shareFeature *shareModel;
@end
