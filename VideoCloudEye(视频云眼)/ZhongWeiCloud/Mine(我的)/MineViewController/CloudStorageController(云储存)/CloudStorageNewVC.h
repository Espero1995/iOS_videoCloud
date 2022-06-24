//
//  CloudStorageNewVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/5.
//  Copyright © 2018年 张策. All rights reserved.
//


@interface CloudStorageNewVC : BaseViewController
//云存储购买的ID
@property (nonatomic,copy) NSString *deviceID;
//云存储购买记录数据
@property (nonatomic,strong) NSMutableArray *orderRecordArr;
@end
