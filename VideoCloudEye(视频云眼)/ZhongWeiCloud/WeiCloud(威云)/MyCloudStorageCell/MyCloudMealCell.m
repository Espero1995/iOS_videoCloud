//
//  MyCloudMealCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/26.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MyCloudMealCell.h"

@implementation MyCloudMealCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)ImmediateUserClick:(id)sender {
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(MyCloudMealCellExtendedUserClick)]) {
        [self.cellDelegate MyCloudMealCellExtendedUserClick];
    }
}

@end
