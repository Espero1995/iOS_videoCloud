//
//  CancelShareSettingVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/13.
//  Copyright © 2018年 张策. All rights reserved.
//
#import "WeiCloudListModel.h"

@interface CancelShareSettingVC : BaseViewController
/**
 设备模型列表
 */
@property (nonatomic,strong) dev_list* dev_mList;
/**
 * 要分享的当前视频的截图
 */
@property (nonatomic, strong) UIImage* currentVideo_CutImage;
@end
