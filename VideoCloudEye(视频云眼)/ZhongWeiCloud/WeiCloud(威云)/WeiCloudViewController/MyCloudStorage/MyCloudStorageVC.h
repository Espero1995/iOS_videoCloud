//
//  MyCloudStorageVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/25.
//  Copyright © 2018年 张策. All rights reserved.
//


@interface MyCloudStorageVC : BaseViewController
/*设备的id*/
@property (nonatomic,copy)NSString *deviceId;
/*设备名字*/
@property (nonatomic,copy)NSString *deviceName;
/*设备图片url*/
@property (nonatomic,copy)NSString *deviceImgUrl;
//判断是否需要刷新
@property (nonatomic,assign) BOOL isRefresh;

@end
