//
//  ImageSetTempVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/2.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"
@interface ImageSetTempVC : BaseViewController

@property (nonatomic,strong) dev_list * listModel;
/*镜像设置的参数*/
@property (nonatomic,copy) NSString *mirror;
/*旋转设置类型*/
@property (nonatomic,copy) NSString *rotate;
/*是否打开开关*/
@property (nonatomic,assign) BOOL isWdr;
/*宽动态设置*/
@property (nonatomic,copy) NSNumber *wdr;

@end
