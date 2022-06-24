//
//  OnlyPlayBackVC.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "BaseViewController.h"
@class dev_list;
@class PushMsgModel;
@interface OnlyPlayBackVC : BaseViewController
//设备列表模型
@property (nonatomic,strong)dev_list *listModel;
//消息模型
@property (nonatomic,strong)PushMsgModel *pushMsgModel;
//时间
@property (nonatomic,copy)NSString *timeStr;
//标题视频设备名称
@property (nonatomic,copy)NSString *titleName;
@property (nonatomic,assign)BOOL isWarning;

@property (nonatomic,copy)NSString *key;

@property (nonatomic,assign)BOOL bIsEncrypt;

@property (nonatomic,assign) NSInteger channel_NO_;

@property (nonatomic,assign) NSIndexPath *selectedIndex;
@property (nonatomic,assign) BOOL bIsAP;/**< 是否是设备ap播放模式 */
@property (nonatomic,assign) BOOL isDeviceVideo;/**< 云端录像还是设备录像 */

/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;

/*通道model*/
@property (nonatomic,strong) MultiChannelModel *channelModel;






@end
