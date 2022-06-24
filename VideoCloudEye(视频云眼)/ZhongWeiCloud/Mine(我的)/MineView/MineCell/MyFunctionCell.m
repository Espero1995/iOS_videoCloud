//
//  MyFunctionCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MyFunctionCell.h"
#import "ViewClickEffect.h"

@interface MyFunctionCell()
/*我的文件*/
@property (strong, nonatomic) IBOutlet ViewClickEffect *myFileView;
/*设备共享*/
@property (strong, nonatomic) IBOutlet ViewClickEffect *myShareView;
/*常见问题*/
@property (strong, nonatomic) IBOutlet ViewClickEffect *myHelpView;
/*客服中心*/
@property (strong, nonatomic) IBOutlet ViewClickEffect *myServiceView;
@end

@implementation MyFunctionCell

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
    //我的文件
    UITapGestureRecognizer *myFileTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myFileAction:)];
    [self.myFileView addGestureRecognizer:myFileTap];
    //设备共享
    UITapGestureRecognizer *myShareTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myShareAction:)];
    [self.myShareView addGestureRecognizer:myShareTap];
    //常见问题
    UITapGestureRecognizer *myHelpViewTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myHelpViewTapAction:)];
    [self.myHelpView addGestureRecognizer:myHelpViewTap];
//    //客服中心
//    UITapGestureRecognizer *myServicetap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myServiceAction:)];
//    [self.myServiceView addGestureRecognizer:myServicetap];
}
//我的文件
- (void)myFileAction:(id)tap
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(myFileViewClick)]) {
        [self.delegate myFileViewClick];
    }
}
//设备分享
- (void)myShareAction:(id)tap
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(myShareViewClick)]) {
        [self.delegate myShareViewClick];
    }
}
//常见问题
- (void)myHelpViewTapAction:(id)tap
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(myHelpViewClick)]) {
        [self.delegate myHelpViewClick];
    }
}
//客服中心
//- (void)myServiceAction:(id)tap
//{
//    if (self.delegate &&[self.delegate respondsToSelector:@selector(myServiceViewClick)]) {
//        [self.delegate myServiceViewClick];
//    }
//}

@end
