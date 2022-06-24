//
//  FingerPrintCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FingerPrintCell : UITableViewCell
//图标
@property (nonatomic,strong) UIImageView *IconImg;
//名称
@property (nonatomic,strong) UILabel *nameLb;
//开关按钮
@property (nonatomic,strong) UISwitch * switchBtn;
@end
