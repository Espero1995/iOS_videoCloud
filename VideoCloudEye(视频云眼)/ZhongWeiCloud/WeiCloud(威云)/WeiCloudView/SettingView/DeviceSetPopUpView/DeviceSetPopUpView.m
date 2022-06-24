//
//  DeviceSetPopUpView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/25.
//  Copyright © 2018年 张策. All rights reserved.
//
#define setpopViewWidth 0.8*iPhoneWidth
#define setpopViewHeight 0.5*iPhoneWidth
#import "DeviceSetPopUpView.h"

@interface DeviceSetPopUpView ()
@property (nonatomic,strong) UIView *setpopView;//弹出框
@property (nonatomic,strong) UIView *verticalLine1;//竖线1
@property (nonatomic,strong) UIView *verticalLine2;//竖线2
@property (nonatomic,strong) UIView *horizontallyLine;//水平线
@end

@implementation DeviceSetPopUpView

- (instancetype)initWithframe:(CGRect) frame
{
    self = [super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.setpopView];
        //竖线
        [self addSubview:self.verticalLine1];
        [self addSubview:self.verticalLine2];
        //水平线
        [self addSubview:self.horizontallyLine];

        //刷新按钮
        [self.setpopView addSubview:self.refreshCoverBtnView];
        [self.refreshCoverBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.setpopView.mas_top).offset(0);
            make.left.equalTo(self.setpopView.mas_left).offset(0);
            make.size.mas_equalTo(CGSizeMake(setpopViewWidth/3, setpopViewHeight/2));
        }];
        //时光相册
        [self.setpopView addSubview:self.timeAlbumView];
        [self.timeAlbumView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.setpopView.mas_top).offset(0);
            make.left.equalTo(self.refreshCoverBtnView.mas_right).offset(0);
            make.size.mas_equalTo(CGSizeMake(setpopViewWidth/3, setpopViewHeight/2));
        }];
        //分享按钮
        [self.setpopView addSubview:self.shareBtnView];
        [self.shareBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.setpopView.mas_top).offset(0);
            make.right.equalTo(self.setpopView.mas_right).offset(0);
            make.size.mas_equalTo(CGSizeMake(setpopViewWidth/3, setpopViewHeight/2));
        }];
        
        //云存按钮
        [self.setpopView addSubview:self.cloudBtnView];
        [self.cloudBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.setpopView.mas_bottom).offset(0);
            make.left.equalTo(self.setpopView.mas_left).offset(0);
            make.size.mas_equalTo(CGSizeMake(setpopViewWidth/3, setpopViewHeight/2));
        }];
        //设置按钮
        [self.setpopView addSubview:self.setBtnView];
        [self.setBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.setpopView.mas_bottom).offset(0);
            make.left.equalTo(self.cloudBtnView.mas_right).offset(0);
            make.size.mas_equalTo(CGSizeMake(setpopViewWidth/3, setpopViewHeight/2));
        }];
        
    }
    return self;
}

#pragma mark - 手势触控
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.setpopView];
    
    if (![self.setpopView.layer containsPoint:point]) {
        [self setPopUpViewShowDismiss];
    }
}


#pragma mark - 显示
- (void)setPopUpViewShow
{
    self.setpopView.frame = CGRectMake(self.touchPointX, self.touchPointY, 0, 0);
    self.verticalLine1.frame = CGRectMake(self.touchPointX, self.touchPointY, 0, 0);//竖线
    self.verticalLine2.frame = CGRectMake(self.touchPointX, self.touchPointY, 0, 0);//竖线
    self.horizontallyLine.frame = CGRectMake(self.touchPointX, self.touchPointY, 0, 0);//横线
    [self contentViewisHidden:YES];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [UIView animateWithDuration:0. animations:^{
        self.setpopView.frame = CGRectMake((iPhoneWidth-setpopViewWidth)/2, (iPhoneHeight-setpopViewHeight)/2, setpopViewWidth, setpopViewHeight);
        self.verticalLine1.frame = CGRectMake(iPhoneWidth/2-setpopViewWidth/6, (iPhoneHeight-setpopViewHeight)/2, 1, setpopViewHeight);//竖线1
        self.verticalLine2.frame = CGRectMake(iPhoneWidth/2+setpopViewWidth/6, (iPhoneHeight-setpopViewHeight)/2, 1, setpopViewHeight);//竖线2
        self.horizontallyLine.frame = CGRectMake((iPhoneWidth-setpopViewWidth)/2, iPhoneHeight/2, setpopViewWidth, 1);//横线
        
    } completion:^(BOOL finished) {
       [self contentViewisHidden:NO];
    }];

}

#pragma mark - 消失
- (void)setPopUpViewShowDismiss{
    [self contentViewisHidden:YES];
    //动画效果淡出
    [UIView animateWithDuration:0. animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        self.setpopView.frame = CGRectMake(self.touchPointX, self.touchPointY, 0, 0);
        self.verticalLine1.frame = CGRectMake(self.touchPointX, self.touchPointY, 0, 0);//竖线1
        self.verticalLine2.frame = CGRectMake(self.touchPointX, self.touchPointY, 0, 0);//竖线2
        self.horizontallyLine.frame = CGRectMake(self.touchPointX, self.touchPointY, 0, 0);//横线
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - 判断View里面的内容是否隐藏
- (void)contentViewisHidden:(BOOL)isHidden
{
    self.refreshCoverBtnView.hidden = isHidden;
    self.shareBtnView.hidden = isHidden;
    self.cloudBtnView.hidden = isHidden;
    self.setBtnView.hidden = isHidden;
}

#pragma mark - 刷新封面点击事件
- (void)refreshCoverBtnViewClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(refreshCoverBtnViewClick)]) {
        [self.delegate refreshCoverBtnViewClick];
    }
    [self setPopUpViewShowDismiss];
}

#pragma mark - 分享点击事件
- (void)shareBtnViewClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(shareBtnViewClick)]) {
        [self.delegate shareBtnViewClick];
    }
    [self setPopUpViewShowDismiss];
}

#pragma mark - 云存购买点击事件
- (void)cloudBtnViewClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(cloudBtnViewClick)]) {
        [self.delegate cloudBtnViewClick];
    }
    [self setPopUpViewShowDismiss];
}

#pragma mark - 设置按钮点击事件
- (void)setBtnViewClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(setBtnViewClick)]) {
        [self.delegate setBtnViewClick];
    }
    [self setPopUpViewShowDismiss];
}
#pragma mark - 时光相册点击事件
- (void)timeAlbumBtnViewClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(timeAlbumBtnViewClick)]) {
        [self.delegate timeAlbumBtnViewClick];
    }
    [self setPopUpViewShowDismiss];
}
#pragma mark - getter && setter
//弹出框
- (UIView *)setpopView
{
    if (!_setpopView) {
        _setpopView = [[UIView alloc]initWithFrame:CGRectZero];
        _setpopView.backgroundColor = [UIColor whiteColor];
        _setpopView.layer.cornerRadius = 10.f;
        _setpopView.alpha = 0.98;
    
    }
    return _setpopView;
}

//竖线1
-(UIView *)verticalLine1{
    if (!_verticalLine1) {
        _verticalLine1 = [[UIView alloc]initWithFrame:CGRectZero];
        _verticalLine1.backgroundColor = RGB(240, 240, 240);
    }
    return _verticalLine1;
}
//竖线2
-(UIView *)verticalLine2{
    if (!_verticalLine2) {
        _verticalLine2 = [[UIView alloc]initWithFrame:CGRectZero];
        _verticalLine2.backgroundColor = RGB(240, 240, 240);
    }
    return _verticalLine2;
}
//水平线
- (UIView *)horizontallyLine
{
    if (!_horizontallyLine) {
        _horizontallyLine = [[UIView alloc]init];
        _horizontallyLine.backgroundColor = RGB(240, 240, 240);
    }
    return _horizontallyLine;
}
//刷新封面
- (DeviceSetBtnView *)refreshCoverBtnView
{
    if (!_refreshCoverBtnView) {
        _refreshCoverBtnView = [[DeviceSetBtnView alloc]init];
        _refreshCoverBtnView.btnImgView.image = [UIImage imageNamed:@"refreshNew"];
        _refreshCoverBtnView.btnTitleLb.text = NSLocalizedString(@"刷新封面", nil);
        //添加单击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshCoverBtnViewClick)];
        [_refreshCoverBtnView addGestureRecognizer:tap];
    }
    return _refreshCoverBtnView;
}

//分享
- (DeviceSetBtnView *)shareBtnView
{
    if (!_shareBtnView) {
        _shareBtnView = [[DeviceSetBtnView alloc]init];
        _shareBtnView.btnImgView.image = [UIImage imageNamed:@"shareNew"];
        _shareBtnView.btnTitleLb.text = NSLocalizedString(@"分享", nil);
        //添加单击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareBtnViewClick)];
        [_shareBtnView addGestureRecognizer:tap];
    }
    return _shareBtnView;
}
//购买云存
- (DeviceSetBtnView *)cloudBtnView
{
    if (!_cloudBtnView) {
        _cloudBtnView = [[DeviceSetBtnView alloc]init];
        _cloudBtnView.btnImgView.image = [UIImage imageNamed:@"cloud_storageNew"];
        _cloudBtnView.btnTitleLb.text = NSLocalizedString(@"云存", nil);
        //添加单击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cloudBtnViewClick)];
        [_cloudBtnView addGestureRecognizer:tap];
    }
    return _cloudBtnView;
}


//设置按钮
- (DeviceSetBtnView *)setBtnView
{
    if (!_setBtnView) {
        _setBtnView = [[DeviceSetBtnView alloc]init];
        _setBtnView.btnImgView.image = [UIImage imageNamed:@"setNew"];
        _setBtnView.btnTitleLb.text = NSLocalizedString(@"设置", nil);
        //添加单击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setBtnViewClick)];
        [_setBtnView addGestureRecognizer:tap];
    }
    return _setBtnView;
}
//时光相册按钮
- (DeviceSetBtnView *)timeAlbumView
{
    if (!_timeAlbumView) {
        _timeAlbumView = [[DeviceSetBtnView alloc]init];
        _timeAlbumView.btnImgView.image = [UIImage imageNamed:@"device_album"];
        _timeAlbumView.btnTitleLb.text = NSLocalizedString(@"时光相册", nil);
        //添加单击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeAlbumBtnViewClick)];
        [_timeAlbumView addGestureRecognizer:tap];
    }
    return _timeAlbumView;
}

@end
