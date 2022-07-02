//
//  AboutUsCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/20.
//  Copyright © 2018 张策. All rights reserved.
//

#import "AboutUsCell.h"
@interface AboutUsCell()
@property (nonatomic,strong) UIImageView *pushImg;
@property (nonatomic,strong) UIStackView *stackView;
@end
@implementation AboutUsCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    [self.contentView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
    }];
    [self.contentView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.left.greaterThanOrEqualTo(self.titleLb.mas_right).offset(10.f);
    }];
    [self.redDot setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [self.pushImg setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [self.stackView addArrangedSubview:self.detailLb];
    [self.stackView addArrangedSubview:self.redDot];
    [self.stackView addArrangedSubview:self.pushImg];
    [self.redDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
    [self.pushImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@11.5);
        make.width.equalTo(@6.5);
    }];
    
//    [self.contentView addSubview:self.pushImg];
//    [self.pushImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.contentView.mas_centerY);
//        make.right.equalTo(self.contentView.mas_right).offset(-15);
//        make.height.equalTo(@11.5);
//        make.width.equalTo(@6.5);
//    }];
//    [self.contentView addSubview:self.detailLb];
//    [self.detailLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.pushImg.mas_left).offset(-7);
//        make.centerY.equalTo(self.contentView.mas_centerY);
//        make.left.equalTo(self.titleLb.mas_right).offset(10);
//    }];
//    [self.contentView addSubview:self.redDot];
//    [self.redDot mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.pushImg.mas_left).offset(-1);
//        make.centerY.equalTo(self.contentView.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(6, 6));
//    }];
}

// 红点显示设置
- (void)configRedDotShow:(BOOL)show {
    self.redDot.hidden = !show;
}

#pragma mark - getter&&setter
-(UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.font = FONT(15);
        _titleLb.textColor = RGB(70, 70, 70);
    }
    return _titleLb;
}
- (UILabel *)detailLb
{
    if (!_detailLb) {
        _detailLb = [[UILabel alloc]init];
        _detailLb.font = FONT(14);
        _detailLb.textColor = RGB(150, 150, 150);
        _detailLb.textAlignment = NSTextAlignmentRight;
    }
    return _detailLb;
}
- (UIImageView *)pushImg
{
    if (!_pushImg) {
        _pushImg = [[UIImageView alloc]init];
        _pushImg.image = [UIImage imageNamed:@"more1"];
    }
    return _pushImg;
}

- (UIView *)redDot {
    if (!_redDot) {
        _redDot = [UIView new];
        _redDot.backgroundColor = [UIColor redColor];
        _redDot.layer.masksToBounds = YES;
        _redDot.layer.cornerRadius = 3;
    }
    return _redDot;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [UIStackView new];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.spacing = 4;
    }
    return _stackView;
}

@end
