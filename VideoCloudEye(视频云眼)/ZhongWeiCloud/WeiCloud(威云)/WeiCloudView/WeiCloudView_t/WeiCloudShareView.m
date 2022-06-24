//
//  WeiCloudShareView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "WeiCloudShareView.h"
#import <ContactsUI/ContactsUI.h>

@implementation WeiCloudShareView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)btnPhoneBookClick:(id)sender {
    [self dismiss];
    if (self.shareDelegate &&[self.shareDelegate respondsToSelector:@selector(weiCloudShareBtnPhoneClick)]) {
        [self.shareDelegate weiCloudShareBtnPhoneClick];
    }
}
- (IBAction)btnShareClick:(id)sender {
    [self dismiss];
    if (self.shareDelegate &&[self.shareDelegate respondsToSelector:@selector(weiCloudShareBtnShareClick:)]) {
        [self.shareDelegate weiCloudShareBtnShareClick:self];
    }
}
- (IBAction)btnCancelClick:(id)sender {
    [self dismiss];
    if (self.shareDelegate &&[self.shareDelegate respondsToSelector:@selector(weiCloudShareBtnCancelClick)]) {
        [self.shareDelegate weiCloudShareBtnCancelClick];
    }
}


@end
