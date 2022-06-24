//
//  ValueAddedCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ValueAddedCell.h"
#import "ViewClickEffect.h"
@interface ValueAddedCell()
@property (strong, nonatomic) IBOutlet ViewClickEffect *CloudStorageView;
@end
@implementation ValueAddedCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setClickEvent];
}

//==========================method==========================
//设置手势点击事件
- (void)setClickEvent
{
    //云存储
    UITapGestureRecognizer *CloudStorageViewtap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CloudStorageAction:)];
    [self.CloudStorageView addGestureRecognizer:CloudStorageViewtap];

}

//云存储
- (void)CloudStorageAction:(id)tap{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(CloudStorageViewClick)]) {
        [self.delegate CloudStorageViewClick];
    }
}
@end
