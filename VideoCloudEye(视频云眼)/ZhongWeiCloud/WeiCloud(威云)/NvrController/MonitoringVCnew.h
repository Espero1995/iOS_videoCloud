//
//  MonitoringViewController.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/13.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BaseViewController.h"
@class dev_list;
@class PushMsgModel;

@interface MonitoringVCnew : BaseViewController
/*设备列表模型*/
@property (nonatomic,strong)dev_list *listModel;

/*时间*/
@property (nonatomic,copy)NSString *timeStr;
/*标题视频设备名称*/
@property (nonatomic,copy)NSString *titleName;
@property (nonatomic,assign)BOOL isWarning;
/*通道数*/
@property (nonatomic,assign)int chan_size;
/*通道名称*/
@property (nonatomic,strong) NSDictionary * chan_alias;
/*选择的通道*/
@property (nonatomic,assign)int chan_way;
/*屏幕的数目，1:小全屏；4:分屏*/
@property (nonatomic,assign) int screenNum;

@property (nonatomic,copy)NSString *key;

@property (nonatomic,assign)BOOL bIsEncrypt;

@property (nonatomic,assign) NSIndexPath *selectedIndex;
/*能力集里面一个新的参数，包含了* 通道列表:(chan_id:<通道ID>、name:通道名称(设备上报名称)、alias:通道别名)*/
@property (nonatomic,strong) NSArray * chans;
@end
