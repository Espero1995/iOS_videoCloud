//
//  SpecialDeviceSettingVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/9.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"

@interface SpecialDeviceSettingVC : BaseViewController
/**
 设备模型列表
 */
@property (nonatomic,strong) dev_list* dev_mList;

/*该设备处于设备列表的第几个*/
@property (nonatomic,strong) NSIndexPath *currentIndex;
@end
