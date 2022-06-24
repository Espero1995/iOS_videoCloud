//
//  VideoCell_c.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoCell_c;
@protocol VideoCell_cDelegate <NSObject>
//点击ImageV代理
- (void)ImageVClick:(VideoCell_c *)cell;

@end

@interface VideoCell_c : UICollectionViewCell

@property (nonatomic,strong) UIButton * chooseBtn;

@property (nonatomic,strong) UIImageView * ImageV;

@property (nonatomic,strong) UIImageView * playImage;

@property (nonatomic,strong) UILabel * nameLabel;

@property (nonatomic,weak)id<VideoCell_cDelegate>delegate;
@end
