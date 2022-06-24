//
//  controlViewInFullScreen.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/1/22.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol controlViewInFullScreenDelegate<NSObject>
- (void)suspendBtnClick:(id)sender;//暂停按钮点击事件
- (void)voiceBtnClick:(id)sender;//音量按钮点击事件
- (void)lockRockerBtnClick:(id)sender;//锁定滚轮按钮点击事件
- (void)LongPress_full_target:(UILongPressGestureRecognizer *)longPress;//麦克风按钮点击事件
- (void)screenshotBtnClick:(id)sender;//截图按钮点击事件
- (void)videoBtnClick:(id)sender;//录屏按钮点击事件
- (void)hdBtnClick:(id)sender;//高清切换按钮点击事件
@end

@interface controlViewInFullScreen : UIView



/*
 * description: 容纳以下控件的View
 */
@property (nonatomic,strong)UIView * functionView;

/*1.暂停按钮*/
@property (nonatomic,strong)UIButton * suspendBtn;
/*2.音量*/
@property (nonatomic,strong)UIButton * voiceBtn;
/*3.锁定滚轮按钮*/
@property (nonatomic,strong)UIButton * lockRockerBtn;
/*4.麦克风*/
@property (nonatomic,strong)UIButton * talkBtn;
/*5.截图*/
@property (nonatomic,strong)UIButton * screenshotBtn;
/*6.录屏*/
@property (nonatomic,strong)UIButton * videoBtn;
/*7.高清*/
@property (nonatomic,strong)UIButton * hdBtn;

@property (nonatomic,assign) id <controlViewInFullScreenDelegate>delegate;
//因为能力集而重新修改布局
- (void)changeLayoutOfFeature:(int)isTalk andCloudDeck:(int)isCloudDeck;
- (id)initLayoutOfFeature:(int)isTalk andCloudDeck:(int)isCloudDeck;
@end
