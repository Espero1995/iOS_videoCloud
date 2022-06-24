//
//  CloudStorageController.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2017/11/24.
//  Copyright © 2017年 张策. All rights reserved.
//


//注释：从【设置】界面过来的云存
@interface CloudStorageController : BaseViewController
//云存储购买的ID
@property (nonatomic,copy) NSString *deviceID;
//云存储购买记录数据
@property (nonatomic,strong) NSMutableArray *orderRecordArr;
@end
