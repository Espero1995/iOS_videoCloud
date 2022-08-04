//
//  RealTimeVideoVC.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/13.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BaseViewController.h"
#import "RealTimePlayEnum.h"

@class dev_list;
@class PushMsgModel;


@interface RealTimeVideoVC : BaseViewController
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

@property (nonatomic,assign) NSIndexPath *selectedIndex;//selectIndexPath这个是在播放器里面，标记的是cell的index，selectIndex，标记的是这个在视频列表进来的时候index

@property (nonatomic, copy) NSString* dev_id;

@property (nonatomic, assign) VideoMode videoMode;/**< 播放的视频模式的类型 */

/**
 * @brief 是否是多通道
 */
@property (nonatomic, assign) BOOL isMultiChannel;

@end
