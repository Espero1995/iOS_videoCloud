//
//  AboutUsQRCodeCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/20.
//  Copyright © 2018 张策. All rights reserved.
//

#import "AboutUsQRCodeCell.h"
@interface AboutUsQRCodeCell()
@property (nonatomic,strong) UILabel *tipLb;
@end
@implementation AboutUsQRCodeCell

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
    [self.contentView addSubview:self.QRCodeImg];
    [self.QRCodeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.contentView addSubview:self.tipLb];
    [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.left.equalTo(self.contentView.mas_left).offset(10);
//        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
}


#pragma mark - getter&&setter
- (UIImageView *)QRCodeImg
{
    if (!_QRCodeImg) {
        _QRCodeImg = [[UIImageView alloc]init];
    }
    return _QRCodeImg;
}

- (UILabel *)tipLb
{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
        _tipLb.font = FONT(15);
        _tipLb.textColor = RGB(70, 70, 70);
        _tipLb.text = NSLocalizedString(@"扫码分享下载客户端", nil);//扫描二维码,您的好友也可以下载客户端
    }
    return _tipLb;
}
@end
