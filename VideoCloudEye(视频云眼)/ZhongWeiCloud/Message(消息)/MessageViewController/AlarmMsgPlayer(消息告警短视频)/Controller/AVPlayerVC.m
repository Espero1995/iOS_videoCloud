//
//  AVPlayerVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2020/2/20.
//  Copyright © 2020 苏旋律. All rights reserved.
//

#import "AVPlayerVC.h"

@interface AVPlayerVC ()
<
    LXAVPlayViewDelegate
>
@property (nonatomic,strong) LXAVPlayView *playerview;
@property (nonatomic,strong) UIView *playFatherView;
@end

@implementation AVPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self.playerview destroyPlayer];
}


- (void)setUpUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playFatherView =[[UIView alloc]init];
    [self.view addSubview:self.playFatherView];
    [self.playFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(-50);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 300));
    }];
    
    LXPlayModel *model =[[LXPlayModel alloc]init];
    model.playUrl = self.videoUrl;
    if ([NSString isNull:self.videoTitle]) {
         model.videoTitle = NSLocalizedString(@"详情", nil);
    }else{
         model.videoTitle = self.videoTitle;
    }
   
    model.fatherView = self.playFatherView;
    self.playerview =[[LXAVPlayView alloc]init];
                         
    self.playerview.isLandScape = YES;
       
    self.playerview.isAutoReplay = NO;
                         
    self.playerview.currentModel = model;
    self.playerview.delegate = self;
    LXWS(weakSelf);
    self.playerview.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}

- (void)fullScreenOrNormalSizeWithFlag:(BOOL)flag
{
    if (flag) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.playFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view.mas_centerX);
                make.centerY.equalTo(self.view.mas_centerY).offset(-70);
                make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 300));
            }];
            float arch = 0;
            //对navigationController.view 进行强制旋转
            self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
            self.navigationController.view.bounds = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            [self.playFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_left).offset(0);
                make.right.equalTo(self.view.mas_right).offset(0);
                make.top.equalTo(self.view.mas_top).offset(0);
                make.bottom.equalTo(self.view.mas_bottom).offset(0);
            }];
            float arch = M_PI_2;
            //对navigationController.view 进行强制旋转
            self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
            self.navigationController.view.bounds = CGRectMake(0, 0, iPhoneHeight, iPhoneWidth);
        }];
    }
}



-(void)dealloc{
    NSLog(@"%@销毁了",self.class);
}


@end
