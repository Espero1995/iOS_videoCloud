//
//  MineHeadView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/8.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MineHeadView.h"

@implementation MineHeadView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tagClickFunc)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tag];
    
    
    UserModel *userModel = [unitl getUserModel];    
    if ([unitl isEmailAccountType]) {
        self.lab_tel.text = userModel.mail;
        self.iconImg.image = [UIImage imageNamed:@"whitemail"];
    }else{
        self.lab_tel.text = userModel.mobile;
        self.iconImg.image = [UIImage imageNamed:@"whitephone"];
    }
    if (userModel.user_name) {
        self.lab_name.text = userModel.user_name;
    }else{
        LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
        self.lab_name.text = loginModel.phoneStr;
    }
    
}

- (void)tagClickFunc
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mineHeadViewLabnameClick)]) {
        [self.delegate mineHeadViewLabnameClick];
    }
}


@end
