//
//  NvrCell_c.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "NvrCell_c.h"
#import "VideoPlayView.h"

@implementation NvrCell_c
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}
- (void)createUI{
    
    _VideoViewBank = [FactoryUI createViewWithFrame:CGRectMake(0, 0, iPhoneWidth/2, 100)];
    _VideoViewBank.backgroundColor = [UIColor colorWithHexString:@"#9e9e9e"];
    [self.contentView addSubview:_VideoViewBank];
    [_VideoViewBank mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
        make.left.equalTo(self.contentView.mas_left).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
    }];
    _ima_videoView = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, iPhoneWidth/2-1, 99) imageName:@"freshen_n"];
    [self.VideoViewBank addSubview:_ima_videoView];
    [_ima_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.VideoViewBank.mas_top).offset(0.5);
        make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(-0.5);
        make.left.equalTo(self.VideoViewBank.mas_left).offset(0.5);
        make.right.equalTo(self.VideoViewBank.mas_right).offset(-0.5);
    }];
//    _playView = [VideoPlayView viewFromXib];
//    [self.contentView addSubview:_playView];
//    [_playView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.ima_videoView.mas_top).offset(0);
//        make.bottom.equalTo(self.ima_videoView.mas_bottom).offset(0);
//        make.left.equalTo(self.ima_videoView.mas_left).offset(0);
//        make.right.equalTo(self.ima_videoView.mas_right).offset(0);
//    }];
}
@end
