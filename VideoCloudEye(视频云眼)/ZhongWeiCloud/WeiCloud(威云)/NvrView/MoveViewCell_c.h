//
//  MoveViewCell_c.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/11/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "JWOpenSdk.h"
#import "JWPlayerManage.h"
#import "JWDeviceRecordFile.h"
#import "LoadingHubView.h"
#import "controlViewInFullScreen.h"

@class MoveViewCell_c;
@class dev_list;
@class ChannelCodeListModel;
@protocol MoveViewCell_cDelegete <NSObject>

- (void) MoveViewCell_cAddBtnClick:(MoveViewCell_c *)cell;

- (void) MoveViewCell_cReStartBtnClick:(MoveViewCell_c *)cell;

- (void) MoveViewCell_caddBtn_new_Click:(MoveViewCell_c *)cell;

- (void) MoveViewCell_deleteClick:(MoveViewCell_c *)cell;
@end
@interface MoveViewCell_c : UICollectionViewCell

//视频管理者
@property (nonatomic,strong)JWPlayerManage *videoManage;
//背景图片
@property (nonatomic,assign)  JWVideoTypeStatus videoTypeStatus;
@property (nonatomic,assign)  BOOL isPlay;
@property (nonatomic,assign)  int cellTag;
@property (nonatomic,assign)  int chan_id;
@property (nonatomic,weak)    UIView * imaBankView;
@property (nonatomic,weak)    UIView *playView;
@property (nonatomic,strong)  VideoModel * videoModel;
@property (weak, nonatomic)   IBOutlet UIButton * addBtn;
@property (weak, nonatomic)   IBOutlet UIImageView *ima_videoView;
@property (nonatomic,weak)    id<MoveViewCell_cDelegete>delegete;
@property (nonatomic, strong) UIButton *reStartBtn;
@property (nonatomic,strong)  LoadingHubView * loadView;
@property (nonatomic,strong)  UIButton * addBtn_new;
@property (nonatomic,strong)  UIButton * closeBtn;

@property (nonatomic,assign)  int chan_way; //选择的通道和cell挂钩

@property (nonatomic,strong) dev_list *listModel;

/**
 * @brief 通道model
 */
@property (nonatomic,strong) MultiChannelModel *channelModel;
/**
 * @brief 单通道channel
 */
@property (nonatomic,strong) ChannelCodeListModel *channelDevModel;
//添加视图
- (void)setUpChildView;

- (void)startLodingAnimation;

- (void)removeLodingAnimation;

@end
