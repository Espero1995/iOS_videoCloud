//
//  AboutUsRelatedView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/21.
//  Copyright © 2018 张策. All rights reserved.
//

#import "AboutUsRelatedView.h"

@implementation AboutUsRelatedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"AboutUsRelatedView"owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}

+(instancetype)viewFromXib
{
    NSString *strClass = NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

//服务协议
- (IBAction)agreementBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(agreementBtnAction)]) {
        [self.delegate agreementBtnAction];
    }
}
//官网
- (IBAction)websiteBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(websiteBtnAction)]) {
        [self.delegate websiteBtnAction];
    }
}
//微信号
- (IBAction)WeChatBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(WeChatBtnAction)]) {
        [self.delegate WeChatBtnAction];
    }
}
//热线
- (IBAction)telBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(telBtnAction)]) {
        [self.delegate telBtnAction];
    }
}

@end
