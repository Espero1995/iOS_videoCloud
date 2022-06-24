//
//  NvrCell_c.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayView.h"
@interface NvrCell_c : UICollectionViewCell

//背景视图
@property (weak, nonatomic) UIView * VideoViewBank;
//播放视图背景图片
@property (weak, nonatomic) UIImageView * ima_videoView;
//播放器
@property (nonatomic,weak) VideoPlayView * playView;


@end
