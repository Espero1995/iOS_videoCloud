//
//  AdvertiseVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/1.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "AdvertiseVC.h"
#import "UIImageView+WebCache.h"
@interface AdvertiseVC ()
///广告图
@property (nonatomic,strong) UIImageView *advertisementImageView;
///倒计时
@property (nonatomic,strong) UIButton *skipButton;
///定时器
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation AdvertiseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    //背景图
    NSString *imageName = [NSString stringWithFormat:@"%@ADBG",[unitl getDeviceScreenSize]];
    UIImage *image = [UIImage imageNamed:imageName];
    self.view.layer.contents = (id) image.CGImage;
    
    [self.advertisementImageView addSubview:self.skipButton];
    [self.skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.right.equalTo(self.advertisementImageView).offset(-20);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}



#pragma mark -- 懒加载
- (UIImageView *)advertisementImageView {
    if (_advertisementImageView == nil) {
        _advertisementImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];//self.view.bounds
        [self.view addSubview:_advertisementImageView];
//        NSLog(@"图片的url1111：%@",self.imageUrl);
        NSString *imageName = [NSString stringWithFormat:@"%@ADBG",[unitl getDeviceScreenSize]];
        [_advertisementImageView sd_setImageWithURL:[NSURL URLWithString:self.adModel.imageUrl] placeholderImage:[UIImage imageNamed:imageName] options:SDWebImageRefreshCached];
        //图片点击无效
        _advertisementImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClickBlock:)];
        [_advertisementImageView addGestureRecognizer:tap];
    }

    return _advertisementImageView;
}

- (UIButton *)skipButton {
    if (_skipButton == nil) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.layer.shouldRasterize = YES;
        _skipButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [_skipButton setTitle:[NSString stringWithFormat:@"%@%zds",NSLocalizedString(@"跳过", nil),self.duration] forState:UIControlStateNormal];
        _skipButton.backgroundColor = [UIColor clearColor];
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _skipButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _skipButton.backgroundColor = [UIColor colorWithRed:38 /255.0 green:38 /255.0 blue:38 /255.0 alpha:0.6];
        _skipButton.layer.cornerRadius = 4;
//        NSLog(@"_skipButton:%d",_skipButton.userInteractionEnabled);
        _skipButton.userInteractionEnabled = YES;
        [_skipButton addTarget:self action:@selector(countButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _skipButton;
}

#pragma mark -- Action
//点击图片跳转webview
-(void)imageClickBlock:(UITapGestureRecognizer *)tap {
    [self invalidatedTimer];
    if (self.imageClickBlock) {
        self.imageClickBlock();
    }
}

///点击跳过按钮
- (void)countButtonClick {
    if (self.skipButtonClickBlock) {
        self.skipButtonClickBlock();
        [self invalidatedTimer];//防止点击了跳过按钮后，倒计时仍在进行
    }
}

///定时器方法
- (void)countTime {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.duration --;
    [self.skipButton setTitle:[NSString stringWithFormat:@"%@%zds",NSLocalizedString(@"跳过", nil),self.duration] forState:UIControlStateNormal];
    if (self.duration <= 0) {
        [self invalidatedTimer];
        //切换根控制器
        if (self.skipButtonClickBlock) {
            self.skipButtonClickBlock();
        }
        return;
    }
}
///销毁定时器
- (void)invalidatedTimer {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark -- 下载图片到本地
- (void)downloadImage {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagePath = [path stringByAppendingPathComponent:@"currentImage.png"];
    [UIImagePNGRepresentation(self.advertisementImageView.image) writeToFile:imagePath atomically:YES];
}
///获取沙盒中图片
- (UIImage *)getDocumentImage {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagePath = [path stringByAppendingPathComponent:@"currentImage.png"];
    return [UIImage imageWithContentsOfFile:imagePath];
}


@end
