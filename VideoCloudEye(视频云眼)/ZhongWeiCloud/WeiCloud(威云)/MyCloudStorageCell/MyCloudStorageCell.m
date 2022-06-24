//
//  MyCloudStorageCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/25.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MyCloudStorageCell.h"

@implementation MyCloudStorageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.extendedBtn.layer.cornerRadius = 15.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
#pragma mark ----- 续费的点击方法
- (IBAction)extendedUserClick:(id)sender {
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(MyCloudStorageCellExtendedUserClick)]) {
        [self.cellDelegate MyCloudStorageCellExtendedUserClick];
    }
}


@end

