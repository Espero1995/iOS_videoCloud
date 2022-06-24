//
//  ChannelPlayBackVC.h
//  ZhongWeiEyes
//
//  Created by Espero on 18/08/18.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "BaseViewController.h"
#import "ChannelCodeListModel.h"
@class dev_list;
@class PushMsgModel;
@interface ChannelPlayBackVC : BaseViewController
//设备列表模型
@property (nonatomic,strong)dev_list *listModel;
//消息模型
@property (nonatomic,strong)PushMsgModel *pushMsgModel;
//时间
@property (nonatomic,copy)NSString *timeStr;


@property (nonatomic,copy)NSString *key;

@property (nonatomic,assign)BOOL bIsEncrypt;

@property (nonatomic,assign) NSIndexPath *selectedIndex;
@property (nonatomic,assign) BOOL bIsAP;/**< 是否是设备ap播放模式 */
@property (nonatomic,assign) BOOL isDeviceVideo;/**< 云端录像还是设备录像 */
/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;

/*通道model*/
@property (nonatomic,strong) ChannelCodeListModel *channelModel;






@end
