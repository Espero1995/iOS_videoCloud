//
//  ProgressBarView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/4/17.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ProgressBarView.h"
@interface ProgressBarView ()
@property (nonatomic,strong) UIView *backView;//白框
@property (nonatomic,strong) UILabel *tipLb;//提示
@property (nonatomic,strong) UIProgressView * progress;//进度条
@property (nonatomic,strong) UILabel *percentageLb;//百分比
@property (nonatomic,strong) UILabel *countLb;//个数比
@property (nonatomic,assign) int totalCount;//总个数
@property (nonatomic,assign) int currentCount;//当前个数
@end

@implementation ProgressBarView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        [self addSubview:self.backView];
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(0.8*iPhoneWidth,120));
        }];
        [self.backView addSubview:self.tipLb];
        [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backView.mas_top).offset(20);
            make.left.equalTo(self.backView.mas_left).offset(20);
        }];
        [self.backView addSubview:self.progress];
        [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backView.mas_left).offset(20);
            make.right.equalTo(self.backView.mas_right).offset(-20);
            make.centerY.equalTo(self.backView.mas_centerY).offset(10);
            make.height.mas_equalTo(@4);
        }];
        [self.backView addSubview:self.percentageLb];
        [self.percentageLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backView.mas_left).offset(20);
            make.bottom.equalTo(self.backView.mas_bottom).offset(-15);
        }];
        [self.backView addSubview:self.countLb];
        [self.countLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.backView.mas_right).offset(-20);
            make.bottom.equalTo(self.backView.mas_bottom).offset(-15);
        }];
    }
    return self;
}

- (void)ProgressBarTip:(NSString *)tip totalCount:(int)totalCount andCurrentCount:(int)currentCount
{
//    NSLog(@"totalCount:%ld;currentCount:%ld",(long)totalCount,(long)currentCount);
    self.tipLb.text = tip;
    self.countLb.text = [NSString stringWithFormat:@"%d/%ld",currentCount,(long)totalCount];
    float percentageProgress = currentCount*100/totalCount;
//    NSLog(@"currentCount/totalCount====%f",currentFloat/stotalFloat);
    self.progress.progress = percentageProgress/100;
    int percentage = currentCount*100/totalCount;
    self.percentageLb.text = [NSString stringWithFormat:@"%d%%",percentage];
}

//背景View
- (UIView *)backView
{
    if (!_backView) {
        _backView = [[UIView alloc]init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = 10.0f;
    }
    return _backView;
}
//提示Label
- (UILabel *)tipLb
{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
        _tipLb.font = FONT(18);
    }
    return _tipLb;
}
//进度条UIProgressView
- (UIProgressView *)progress
{
    if (!_progress) {
        _progress = [[UIProgressView alloc]init];
        //完成进度的颜色
        _progress.tintColor = MAIN_COLOR;
        //未完成进度的颜色
        _progress.trackTintColor = [UIColor colorWithHexString:@"#e0e0e0"];
    }
    return _progress;
}
//百分比Label
- (UILabel *)percentageLb
{
    if (!_percentageLb) {
        _percentageLb = [[UILabel alloc]init];
        _percentageLb.textColor = RGB(150, 150, 150);
        _percentageLb.font = FONT(16);
//        _percentageLb.text = @"8%";
    }
    return _percentageLb;
}
//个数比countLb
- (UILabel *)countLb
{
    if (!_countLb) {
        _countLb = [[UILabel alloc]init];
        _countLb.textColor = RGB(150, 150, 150);
        _countLb.font = FONT(16);
//        _countLb.text = @"39/67";
    }
    return _countLb;
}
@end
