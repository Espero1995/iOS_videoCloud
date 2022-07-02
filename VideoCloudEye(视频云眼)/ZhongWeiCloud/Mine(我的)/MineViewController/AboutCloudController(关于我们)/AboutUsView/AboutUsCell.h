//
//  AboutUsCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/20.
//  Copyright © 2018 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AboutUsCell : UITableViewCell

@property (nonatomic,strong) UILabel *titleLb;
@property (nonatomic,strong) UILabel *detailLb;
@property (nonatomic,strong) UIView *redDot;//小红点

// 红点显示设置
- (void)configRedDotShow:(BOOL)show;

@end

