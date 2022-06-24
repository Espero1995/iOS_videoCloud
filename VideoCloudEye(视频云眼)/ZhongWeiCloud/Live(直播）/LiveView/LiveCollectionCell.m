//
//  LiveCollectionCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/16.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "LiveCollectionCell.h"

@implementation LiveCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)zanClick:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [btn setImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
        [XHToast showCenterWithText:@"点赞成功"];
    }else{
        [btn setImage:[UIImage imageNamed:@"unzan"] forState:UIControlStateNormal];
        [XHToast showCenterWithText:@"已取消"];
    }
}

@end
