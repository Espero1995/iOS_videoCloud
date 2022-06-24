//
//  RowView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "RowView.h"

@implementation RowView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_left).offset(15);
    }];
    //箭头图标
    [self addSubview:self.pushImage];
    [self.pushImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-10);
        make.height.equalTo(@11.5);
        make.width.equalTo(@6.5);
    }];
    [self addSubview:self.subTitleLb];
    [self.subTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pushImage.mas_left).offset(-5);
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.titleLb.mas_right).offset(30);
    }];
    
    //给View添加点击事件
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
}

//点击事件
-(void)tapAction:(UITapGestureRecognizer *)gesture
{
    if (self.rowViewDelegate &&[self.rowViewDelegate respondsToSelector:@selector(didSelectRowView:)]) {
        [self.rowViewDelegate didSelectRowView:self.row];
    }
}

#pragma mark - getter && setter
//标题
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.font = FONT(16);
        _titleLb.textColor = RGB(80, 80, 80);
    }
    return _titleLb;
}
//副标题
- (UILabel *)subTitleLb
{
    if (!_subTitleLb) {
        _subTitleLb = [[UILabel alloc]init];
        _subTitleLb.font = FONT(14);
        _subTitleLb.textColor = RGB(180, 180, 180);
        _subTitleLb.textAlignment = NSTextAlignmentRight;
    }
    return _subTitleLb;
}
//箭头图标
- (UIImageView *)pushImage
{
    if (!_pushImage) {
        _pushImage = [[UIImageView alloc]init];
        _pushImage.image = [UIImage imageNamed:@"more1"];
    }
    return _pushImage;
}
@end
