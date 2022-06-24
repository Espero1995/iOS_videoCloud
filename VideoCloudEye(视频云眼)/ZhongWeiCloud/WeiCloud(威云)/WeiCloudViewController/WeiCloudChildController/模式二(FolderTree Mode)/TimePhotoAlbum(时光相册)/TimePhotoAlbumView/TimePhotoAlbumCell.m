//
//  TimePhotoAlbumCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/17.
//  Copyright © 2018 张策. All rights reserved.
//

#import "TimePhotoAlbumCell.h"

@implementation TimePhotoAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.albumImgView.layer.masksToBounds = YES;
    self.albumImgView.layer.cornerRadius = 10.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (IBAction)albumDownloadClick:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(AlbumPhotoDownload:)]) {
        [self.delegate AlbumPhotoDownload:self];
    }
}
- (IBAction)albumShareClick:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(AlbumPhotoShare:)]) {
        [self.delegate AlbumPhotoShare:self];
    }
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        [self.albumImgView addSubview:_activityIndicator];
        [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.albumImgView.mas_centerX);
            make.centerY.equalTo(self.albumImgView.mas_centerY);
        }];
        //设置小菊花颜色
        _activityIndicator.color = [UIColor whiteColor];
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

@end
