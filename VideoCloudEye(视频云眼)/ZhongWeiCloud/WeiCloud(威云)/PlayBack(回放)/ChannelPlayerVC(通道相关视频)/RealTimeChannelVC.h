//
//  RealTimeChannelVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2020/8/15.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BaseViewController.h"
#import "ChannelCodeListModel.h"

/**
 * 播放类型
 */
typedef NS_ENUM(NSUInteger, VideoMode) {
    VideoMode_AP = 1,
    VideoMode_Normal,
};

@interface RealTimeChannelVC : BaseViewController

/**
 * @brief 通道Model
 */
@property (nonatomic, strong) ChannelCodeListModel *channelModel;

/*屏幕的数目，1:小全屏；4:分屏*/
@property (nonatomic,assign) int screenNum;

/*selectIndexPath这个是在播放器里面，标记的是cell的index，selectIndex，标记的是这个在视频列表进来的时候index，用于截图*/
@property (nonatomic,assign) NSIndexPath *selectedIndex;

@property (nonatomic, assign) VideoMode videoMode;/**< 播放的视频模式的类型 */
@property (nonatomic, copy) NSArray *postDataSources;//传过来的设备列表数据源



@end
