//
//  MulChooseCell.h
//  MulChooseDemo
//
//  Created by L2H on 16/7/13.
//  Copyright © 2016年 ailk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableChooseCell : UITableViewCell
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic, strong)UIButton *SelectIconBtn;
@property (nonatomic,strong)UIImageView *imaView;
@property (nonatomic,assign)BOOL isSelected;
-(void)UpdateCellWithState:(BOOL)select;
@end
