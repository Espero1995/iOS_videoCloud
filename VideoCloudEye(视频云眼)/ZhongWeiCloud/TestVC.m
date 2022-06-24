//
//  TestVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "TestVC.h"
#import "ZCTabBarController.h"
#import "controlViewInFullScreen.h"
@interface TestVC ()
<
    controlViewInFullScreenDelegate
>

@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"测试";
    [self cteateNavBtn];
    self.showView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

//delegate
#pragma mark ----- 滚轮按钮点击事件
- (void)showRockerBtnClick{
    [Toast showInfo:@"点击了滚轮按钮了"];
}
#pragma mark ----- 暂停按钮点击事件
- (void)suspendBtnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [Toast showInfo:@"视频播放"];
    }else{
        [Toast showInfo:@"视频暂停"];
    }
}
#pragma mark ----- 音量按钮点击事件
- (void)voiceBtnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [Toast showInfo:@"声音:开"];
    }else{
        [Toast showInfo:@"声音:关"];
    }

}
#pragma mark ----- 锁定滚轮按钮点击事件
- (void)lockRockerBtnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [Toast showInfo:@"滚轮已锁定"];
    }else{
        [Toast showInfo:@"滚轮已解锁"];
    }
}
#pragma mark ----- 麦克风按钮点击事件
- (void)talkBtnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [Toast showInfo:@"麦克风:开"];
    }else{
        [Toast showInfo:@"麦克风:关"];
    }
}
#pragma mark ----- 截图按钮点击事件
- (void)screenshotBtnClick:(id)sender{
    [Toast showInfo:@"已保存截图到我的文件"];
}
#pragma mark ----- 录屏按钮点击事件
- (void)videoBtnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [Toast showInfo:@"视频开始录制"];
    }else{
        [Toast showInfo:@"视频录制成功，已保存到我的文件"];
    }
}
#pragma mark ----- 高清切换按钮点击事件
- (void)hdBtnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [Toast showInfo:@"切换高清"];
    }else{
        [Toast showInfo:@"切换流畅"];
    }
}

@end
