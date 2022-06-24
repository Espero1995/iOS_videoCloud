//
//  FriendsSharedVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/27.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"

@interface FriendsSharedVC : BaseViewController
@property (nonatomic,strong) dev_list* dev_mList;
@property (nonatomic,strong) NSMutableArray *modifyPermissionArr;
@property (nonatomic,strong) NSMutableDictionary *modifyPermissionDic;
@end
