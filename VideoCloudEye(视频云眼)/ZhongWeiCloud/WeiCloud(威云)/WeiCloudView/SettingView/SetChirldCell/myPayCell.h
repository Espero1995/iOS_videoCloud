//
//  myPayCell.h
//  Demo
//
//  Created by Espero on 2017/12/4.
//  Copyright © 2017年 Espero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myPayCell : UITableViewCell
//图片
@property (nonatomic,strong) UIImageView *headImg;
//名字
@property (nonatomic,strong) UILabel *payName;
//选择按钮图片
@property (nonatomic,strong) UIImageView *selectImg;

@property (nonatomic,assign) NSInteger selectStyle;
@end
