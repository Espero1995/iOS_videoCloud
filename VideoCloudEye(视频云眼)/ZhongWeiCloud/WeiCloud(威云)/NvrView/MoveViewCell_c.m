//
//  MoveViewCell_c.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/11/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "MoveViewCell_c.h"

@interface MoveViewCell_c ()

@end
@implementation MoveViewCell_c
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setUpChildView];
}

- (void)setUpChildView
{
    //黑色背景
    UIView *ImaBank = [[UIView alloc]init];
    ImaBank.backgroundColor = [UIColor clearColor];
    [self.contentView insertSubview:ImaBank atIndex:0];
    [ImaBank mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(0);
        make.top.equalTo(self.contentView.mas_top).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
    }];
    self.imaBankView =ImaBank;
    //图片
    UIImageView *ima = [[UIImageView alloc]init];
    ima.contentMode = UIViewContentModeCenter;
    [self.imaBankView addSubview:ima];
    [ima mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(0);
        make.top.equalTo(self.contentView.mas_top).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
    }];
    self.ima_videoView = ima;
    //播放视图
    UIView *playView = [[UIView alloc]init];
    [self.contentView insertSubview:playView atIndex:1];
    [playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(0);
        make.top.equalTo(self.contentView.mas_top).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
    }];
    [self.videoManage JWPlayerManageSetPlayerView:playView];
    self.playView = playView;
    
    
   // [self.loadView showAnimated:YES];
    
    //选择通道按钮
    _addBtn_new.userInteractionEnabled = YES;
    _addBtn_new.hidden = NO;
    [_addBtn addTarget:self action:@selector(ChoosePassWaybtn:) forControlEvents:UIControlEventTouchDown];
   // [self.contentView addSubview:_addBtn];
    self.isPlay = NO;
    //播放视图初始化
    
    [self.contentView addSubview:self.reStartBtn];
    self.reStartBtn.hidden = YES;
    [self.reStartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.contentView addSubview:self.addBtn_new];
    
    [self.addBtn_new mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.contentView addSubview:self.closeBtn];
    self.closeBtn.hidden = YES;
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-7);
        make.top.mas_equalTo(self.contentView).offset(7);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}
#pragma mark - 第一次加号选择频道进行播放
- (void)ChoosePassWaybtn:(MoveViewCell_c *)cell{
    if (self.delegete && [self.delegete respondsToSelector:@selector(MoveViewCell_cAddBtnClick:)]) {
        [self.delegete MoveViewCell_cAddBtnClick:self];
    }
}
- (IBAction)closeBtnClick:(id)sender {
    NSLog(@"点击了关闭视频");
    if (self.delegete && [self.delegete respondsToSelector:@selector(MoveViewCell_deleteClick:)]) {
        [self.delegete MoveViewCell_deleteClick:self];
    }
}


#pragma mark - 播放失败之后变成视频播放按钮，不用选择，直接刚才的播放通道进行播放
- (void)reStartBtnClick:(MoveViewCell_c *)cell
{
    NSLog(@"点击到了重新播放按钮");
    if (self.delegete && [self.delegete respondsToSelector:@selector(MoveViewCell_cReStartBtnClick:)]) {
        [self.delegete MoveViewCell_cReStartBtnClick:self];
    }
}
#pragma mark - 删除掉当前的播放cell，后新创建
- (void)addBtn_new_Click:(MoveViewCell_c *)cell
{
    NSLog(@"点击到了删除过后，新的选择通道按钮");
    if (self.delegete && [self.delegete respondsToSelector:@selector(MoveViewCell_caddBtn_new_Click:)]) {
        [self.delegete MoveViewCell_caddBtn_new_Click:self];
    }
}

- (void)setVideoModel:(VideoModel *)videoModel
{
    _videoModel = videoModel;
}


- (void)startLodingAnimation
{
    [self.contentView addSubview:_loadView];
    [_loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(40, 10));
    }];
    _loadView.hudColor = UIColorFromRGB(0xF1F2F3);
}
- (void)removeLodingAnimation
{
    [self.loadView removeFromSuperview];
    self.loadView = nil;
}

#pragma mark - 懒加载
- (UIButton *)reStartBtn
{
    if (!_reStartBtn) {
        _reStartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reStartBtn.hidden = YES;
        [_reStartBtn setImage:[UIImage imageNamed:@"PlayViedo"] forState:UIControlStateNormal];
        [_reStartBtn addTarget:self action:@selector(reStartBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _reStartBtn;
}

- (UIButton *)addBtn_new
{
    if (!_addBtn_new) {
        _addBtn_new = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn_new.hidden = YES;
        [_addBtn_new setImage:[UIImage imageNamed:@"addup"] forState:UIControlStateNormal];
        [_addBtn_new addTarget:self action:@selector(addBtn_new_Click:) forControlEvents:UIControlEventTouchDown];
    }
    return _addBtn_new;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.hidden = YES;
        [_closeBtn setImage:[UIImage imageNamed:@"VideoClose"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _closeBtn;
}


- (LoadingHubView *)loadView
{
    if (!_loadView) {
        _loadView = [[LoadingHubView alloc]initWithFrame:CGRectMake(0, 0, 40, 10)];
        [self startLodingAnimation];
    }
    return _loadView;
}

@end
