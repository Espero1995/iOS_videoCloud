//
//  RealTimeVideoVC.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/13.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BaseViewController.h"
@class dev_list;
@class PushMsgModel;

/**
 * 播放类型
 */
typedef NS_ENUM(NSUInteger, VideoMode) {
    VideoMode_AP = 1,
    VideoMode_Normal,
};

@interface OldRealVideoVC : BaseViewController
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
/**
 * device_id
 */
@property (nonatomic, copy) NSString* dev_id;

@property (nonatomic, assign) VideoMode videoMode;/**< 播放的视频模式的类型 */


@end
