//
//  SharePermissionVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"

@interface SharePermissionVC : BaseViewController
@property (nonatomic,strong) dev_list* dev_mList;
@property (nonatomic,strong) NSMutableDictionary *modifyPermissionDic;//权限信息字典
@end
