//
//  AdjustSensitivityController.h
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/21.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiCloudListModel.h"
#import "BaseViewController.h"

//灵敏度回调
typedef void (^sensitivityBlock)(NSString *str);

@interface AdjustSensitivityController : BaseViewController
//灵敏度
@property (nonatomic,copy) NSString * adjustDegree;
//开始时间
@property (nonatomic,copy) NSString *startTime;
//结束时间
@property (nonatomic,copy) NSString *endTime;
//周期
@property (nonatomic,copy) NSString *periodStr;
//生成一个block属性
@property(nonatomic,copy) sensitivityBlock block;

@property (nonatomic,strong) dev_list * listModel;

@property (nonatomic,assign) BOOL subing;

@end
