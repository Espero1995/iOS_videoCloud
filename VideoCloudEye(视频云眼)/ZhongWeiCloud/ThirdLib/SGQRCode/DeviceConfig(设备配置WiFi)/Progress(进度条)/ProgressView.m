//
//  ProgressView.m
//  ProgressViewDome
//
//  Created by Rainy on 2017/12/28.
//  Copyright © 2017年 Rainy. All rights reserved.
//

#define kProgressTintColor       MAIN_COLOR
#define kTrackTintColor          RGB(174,182,204)

#define kPopupWindowIMG          [UIImage imageNamed:@"config_progress"]

#define kProgressView_H          5
#define kInterval                3

#import "ProgressView.h"
#import "GGProgressView.h"
@interface ProgressView ()

@property (nonatomic, strong) UIImageView *progressAccountIMG;
@property (nonatomic, strong) UILabel * progressTitleLabel;
//@property (nonatomic, strong) UIProgressView * rateProgressView;
@property (nonatomic, strong) GGProgressView * rateProgressView;

@end

@implementation ProgressView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.progressAccountIMG = [[UIImageView alloc]initWithImage:kPopupWindowIMG];
    self.progressAccountIMG.frame = CGRectMake(-15, 0, 64/2, 83/2);
    [self addSubview:self.progressAccountIMG];
    
    self.progressTitleLabel = [[UILabel alloc] init];
    self.progressTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.progressTitleLabel.textColor = [UIColor whiteColor];
    self.progressTitleLabel.font = FONT(15);
    [self.progressAccountIMG addSubview:self.progressTitleLabel];
    [self.progressTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.progressAccountIMG.mas_centerX);
        make.centerY.equalTo(self.progressAccountIMG.mas_centerY).offset(-5);
    }];
    
    // 进度条初始化
//    self.rateProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//    self.rateProgressView.frame = CGRectMake(0, CGRectGetMaxY(self.progressAccountIMG.frame) + kInterval, self.frame.size.width, 30);
//    // 进度条的底色
//    self.rateProgressView.progressTintColor = kProgressTintColor;
//    self.rateProgressView.trackTintColor = kTrackTintColor;
//    self.rateProgressView.layer.cornerRadius = kProgressView_H / 2;
//    [self addSubview:self.rateProgressView];
    
    
    self.rateProgressView = [[GGProgressView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.progressAccountIMG.frame) + kInterval, self.frame.size.width, kProgressView_H)];
    //设置
    self.rateProgressView.progressTintColor = kProgressTintColor;
    self.rateProgressView.trackTintColor = kTrackTintColor;
//    self.rateProgressView.layer.cornerRadius = kProgressView_H / 2;
    self.rateProgressView.progressViewStyle = GGProgressViewStyleTrackFillet;
    //添加
    [self addSubview:self.rateProgressView];

    
    
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    [self setSubviewsFrame];
//}

- (void)setSubviewsFrame
{

    [UIView animateWithDuration:self.rateProgressView.progress animations:^{
        self.progressAccountIMG.frame = CGRectMake(self.frame.size.width * self.rateProgressView.progress-15, 0, 64/2, 83/2);
        
        self.rateProgressView.frame = CGRectMake(0, CGRectGetMaxY(self.progressAccountIMG.frame) + kInterval, CGRectGetWidth(self.frame), kProgressView_H);
//
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(self.progressTitleLabel.frame));
        
    }];
}

- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
//    [self.rateProgressView setProgress:progress animated:YES];
    self.rateProgressView.progress = progress;
}

- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString;
    self.progressTitleLabel.text = titleString;
    [self setSubviewsFrame];
}


@end
