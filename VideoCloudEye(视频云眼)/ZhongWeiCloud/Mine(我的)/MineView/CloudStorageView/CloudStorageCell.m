//
//  CloudStorageCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "CloudStorageCell.h"

@implementation CloudStorageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.openCloud_btn.layer.cornerRadius = 15.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark ----- 开通云存或者续费的点击方法
- (IBAction)openCloudClick:(id)sender {
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(CloudStorageCellOpenCloudClick:)]) {
        [self.cellDelegate CloudStorageCellOpenCloudClick:self];
    }
}

@end
