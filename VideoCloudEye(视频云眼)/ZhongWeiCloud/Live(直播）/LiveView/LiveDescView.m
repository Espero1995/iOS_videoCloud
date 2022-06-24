//
//  LiveDescView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/5.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "LiveDescView.h"
@interface LiveDescView()
/*直播观看图片*/
@property(nonatomic,strong) UIImageView *viewImg;
/*直播介绍的字*/
@property(nonatomic,strong) UILabel *liveIntroduce_lb;
/*bgView*/
@property(nonatomic,strong) UIView *bgView;
@end

@implementation LiveDescView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(255, 255, 255);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //设备名
    [self addSubview:self.liveName_lb];
    [self.liveName_lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(15);
    }];
    //浏览数
    [self addSubview:self.liveViewCount_lb];
    [self.liveViewCount_lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.liveName_lb);
        make.right.mas_equalTo(-10);
    }];
    //浏览数图片
    [self addSubview:self.viewImg];
    [self.viewImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.liveViewCount_lb);
        make.right.equalTo(self.liveViewCount_lb.mas_left).offset(-5);
    }];
    //bgView
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.equalTo(self.liveName_lb.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 40));
    }];
    //直播介绍的title
    [self.bgView addSubview:self.liveIntroduce_lb];
    [self.liveIntroduce_lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.equalTo(self.bgView);
    }];
    
    //直播内容介绍
    [self addSubview:self.liveDesc_tv];
    [self.liveDesc_tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.equalTo(self.bgView.mas_bottom).offset(10);
        make.right.mas_equalTo(-10);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
}

#pragma mark -getter && setter
//设备名
-(UILabel *)liveName_lb{
    if (!_liveName_lb) {
        _liveName_lb = [[UILabel alloc]init];
        _liveName_lb.textColor = [UIColor orangeColor];
        _liveName_lb.font = FONT(16);
    }
    return _liveName_lb;
}
//浏览数
-(UILabel *)liveViewCount_lb{
    if (!_liveViewCount_lb) {
        _liveViewCount_lb = [[UILabel alloc]init];
        _liveViewCount_lb.textColor = RGB(96, 97, 98);
        _liveViewCount_lb.font = FONT(14);
    }
    return _liveViewCount_lb;
}
//浏览数图片
-(UIImageView *)viewImg{
    if (!_viewImg) {
        _viewImg = [[UIImageView alloc]init];
        _viewImg.image = [UIImage imageNamed:@"livingEye"];
    }
    return _viewImg;
}
//bgView
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = BG_COLOR;
    }
    return _bgView;
}
//直播介绍title
-(UILabel *)liveIntroduce_lb{
    if (!_liveIntroduce_lb) {
        _liveIntroduce_lb = [[UILabel alloc]init];
        _liveIntroduce_lb.textColor = [UIColor orangeColor];
        _liveIntroduce_lb.font = FONT(16);
        _liveIntroduce_lb.text = @"直播介绍";
    }
    return _liveIntroduce_lb;
}
//直播内容介绍
-(UITextView *)liveDesc_tv{
    if (!_liveDesc_tv) {
        _liveDesc_tv = [[UITextView alloc]init];
        _liveDesc_tv.font = FONT(15);
        _liveDesc_tv.textColor = RGB(96, 97, 98);
        _liveDesc_tv.editable = NO;
        _liveDesc_tv.showsVerticalScrollIndicator = NO;
    }
    return _liveDesc_tv;
}
@end
