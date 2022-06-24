//
//  SwitchModeView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/31.
//  Copyright © 2018年 张策. All rights reserved.
//
#define CircleWidth 64
#import "SwitchModeView.h"
@interface SwitchModeView ()
<
    CAAnimationDelegate
>
{
    CALayer *layer;
    BOOL _isStatus;
}
@property (nonatomic,strong) UIView *switchView;//切换模式View
@property (nonatomic,strong) UIImageView *IconView;//图标
@property (nonatomic,strong) UILabel *tipLb;//提示语
@property (nonatomic,strong) UIButton *closeBtn;//关闭按钮
@end
@implementation SwitchModeView

- (instancetype)initWithframe:(CGRect) frame
{
    self = [super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        layer = [CALayer layer];
        [self addSubview:self.switchView];
        [self addSubview:self.IconView];
        [self.IconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top).offset(0.1*iPhoneHeight);
            make.size.mas_equalTo(CGSizeMake(CircleWidth, CircleWidth));
        }];
        [self addSubview:self.tipLb];
        [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.IconView.mas_bottom).offset(15);
        }];
        [self addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self.mas_bottom).offset(-50);
        }];
        
    }
    return self;
}


#pragma mark - 显示
- (void)switchModeViewShow:(BOOL)isStatus andGroupID:(NSString *)groupID
{
    _isStatus = isStatus;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.98f];
    if (_isStatus == YES) {
        self.IconView.image = [UIImage imageNamed:@"unselected_Unprotected"];
        self.tipLb.text = NSLocalizedString(@"正在关闭布防...", nil);
    }else{
        self.IconView.image = [UIImage imageNamed:@"unselected_protected"];
        self.tipLb.text = NSLocalizedString(@"正在开启布防...", nil);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.switchView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
        //将动画添加到动画视图上
        [self animation];
        
    } completion:^(BOOL finished) {
        self.switchView.alpha = 1;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void){

            /**
             * description：v1/devicegroup/updateGroupSensibility（设备分组一键布防）
             *access_token=<令牌> & user_id =<用户ID>& group_id=< group_id 组id>& enableSensibility=< enableSensibility布防(意义同设备)> & alarmType=<告警类型>
             & enable= <启用还是停止> & start_time<开始时间> & stop_time<结束时间> & period<周期>&sensibility=<灵敏度 int>
             */
            NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
            [postDic setObject:groupID forKey:@"group_id"];
            [postDic setObject:@"1" forKey:@"alarmType"];
            if (isStatus == YES) {//原来是开启的，要设置成开启布防
                [postDic setObject:@"0" forKey:@"enableSensibility"];
                [postDic setObject:@"0" forKey:@"enable"];
            }else{//要设置成关闭布防
                [postDic setObject:@"1" forKey:@"enableSensibility"];
                [postDic setObject:@"1" forKey:@"enable"];
            }
            [postDic setObject:@"00:00" forKey:@"startTime"];
            [postDic setObject:@"23:59" forKey:@"stopTime"];
            [postDic setObject:@"1,2,3,4,5,6,7" forKey:@"period"];
            [postDic setObject:[NSNumber numberWithInt:60] forKey:@"sensibility"];
            [[HDNetworking sharedHDNetworking]POST:@"v1/devicegroup/updateGroupSensibility" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
                NSLog(@"一键布防的结果:%@",responseObject);
                int ret = [responseObject[@"ret"]intValue];
                if (ret == 0) {
                    self.block(_isStatus);
                    [self stopAnimation];
                    [self switchModeViewDismiss];
                }else{
                    [self switchModeViewDismiss];
                    [XHToast showCenterWithText:NSLocalizedString(@"一键布防设置失败，请稍候再试", nil)];
                }
            } failure:^(NSError * _Nonnull error) {
                [self switchModeViewDismiss];
                [XHToast showCenterWithText:NSLocalizedString(@"一键布防设置失败，请检查您的网络", nil)];
            }];

            
        });
    }];
    

    
}

#pragma mark - 消失
- (void)switchModeViewDismiss{
    //动画效果淡出
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.98f];
        self.switchView.frame = CGRectMake(0, -iPhoneHeight, iPhoneWidth, iPhoneHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.switchView.alpha = 0;
    }];
}

- (void)closeBtnClick
{
    [layer removeFromSuperlayer];
    [self switchModeViewDismiss];
}

- (void)animation {
    layer.frame = CGRectMake(0, 0, CircleWidth, CircleWidth);
    layer.backgroundColor = MAIN_COLOR.CGColor;
    [self.IconView.layer addSublayer:layer];
    //创建圆环
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CircleWidth/2, CircleWidth/2) radius:CircleWidth/2-3 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    //圆环遮罩
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.lineWidth = 2;
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 1;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineDashPhase = 0.8;
    shapeLayer.path = bezierPath.CGPath;
    [layer setMask:shapeLayer];
    //颜色渐变
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.shadowPath = bezierPath.CGPath;
    gradientLayer.frame = CGRectMake(0, 0, CircleWidth, CircleWidth);
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 0);
    gradientLayer.colors = @[(__bridge id)MAIN_COLOR.CGColor, (__bridge id)RGB(45, 45, 110).CGColor, (__bridge id)RGB(45, 45, 155).CGColor, (__bridge id)RGB(190, 200, 195).CGColor, (__bridge id)[UIColor whiteColor].CGColor];
    gradientLayer.locations = @[@0.2, @0.5, @0.8, @0.9, @1.0];
    [layer addSublayer:gradientLayer]; //设置颜色渐变
    //动画
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.delegate = self;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2.0*M_PI];
    
    rotationAnimation.repeatCount = MAXFLOAT;//MAXFLOAT
    rotationAnimation.duration = 0.5;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [layer addAnimation:rotationAnimation forKey:@"rotationAnnimation"];
    
}


//- (void)animationDidStart:(CAAnimation *)anim
//{
//    NSLog(@"animationDidStart%@",self.layer.animationKeys);
//}

- (void)stopAnimation
{
    if (_isStatus == YES) {
        self.tipLb.text = NSLocalizedString(@"已关闭布防", nil);
    }else{
        self.tipLb.text = NSLocalizedString(@"已开启布防", nil);
    }
    
    [layer removeFromSuperlayer];
    layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, CircleWidth, CircleWidth);
    layer.backgroundColor = MAIN_COLOR.CGColor;
    [self.IconView.layer addSublayer:layer];
    //创建圆环
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CircleWidth/2, CircleWidth/2) radius:CircleWidth/2-3 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    //颜色渐变
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    //圆环遮罩
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.lineWidth = 2;
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 1;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineDashPhase = 0.8;
    shapeLayer.path = bezierPath.CGPath;
    [layer setMask:shapeLayer];
    gradientLayer.shadowPath = bezierPath.CGPath;
    gradientLayer.frame = CGRectMake(0, 0, CircleWidth, CircleWidth);
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 0);
    gradientLayer.colors = @[(__bridge id)MAIN_COLOR.CGColor];
    [layer addSublayer:gradientLayer]; //设置颜色渐变
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_isStatus == YES) {
        self.tipLb.text = NSLocalizedString(@"已关闭布防", nil);
    }else{
        self.tipLb.text = NSLocalizedString(@"已开启布防", nil);
    }
    
    [layer removeFromSuperlayer];
    layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, CircleWidth, CircleWidth);
    layer.backgroundColor = MAIN_COLOR.CGColor;
    [self.IconView.layer addSublayer:layer];
    //创建圆环
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CircleWidth/2, CircleWidth/2) radius:CircleWidth/2-3 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    //颜色渐变
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    //圆环遮罩
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.lineWidth = 2;
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 1;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineDashPhase = 0.8;
    shapeLayer.path = bezierPath.CGPath;
    [layer setMask:shapeLayer];
    gradientLayer.shadowPath = bezierPath.CGPath;
    gradientLayer.frame = CGRectMake(0, 0, CircleWidth, CircleWidth);
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 0);
    gradientLayer.colors = @[(__bridge id)MAIN_COLOR.CGColor];
    [layer addSublayer:gradientLayer]; //设置颜色渐变
}




#pragma mark - getter && setter
//切换模式View
- (UIView *)switchView
{
    if (!_switchView) {
        _switchView = [[UIView alloc]initWithFrame:CGRectMake(0, -iPhoneHeight, iPhoneWidth, iPhoneHeight)];
        _switchView.backgroundColor = [UIColor clearColor];
    }
    return _switchView;
}
//图标
- (UIImageView *)IconView
{
    if (!_IconView) {
        _IconView = [[UIImageView alloc]initWithFrame:CGRectZero];
    }
    return _IconView;
}
//提示语
- (UILabel *)tipLb
{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
        _tipLb.font = FONT(14);
        _tipLb.textColor = MAIN_COLOR;
    }
    return _tipLb;
}
//关闭按钮
- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc]init];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"switchClose"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
