//
//  BaseTableView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "BaseTableView.h"

@interface BaseTableView()

@property(nonatomic,strong) UIImageView *iv_noData;

@property(nonatomic,strong) UIImage *noDataImage;

@property(nonatomic,copy) NSString *tipStr;

@property (nonatomic,strong) UILabel *tipLb;

@end

@implementation BaseTableView

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self add_no_data_view];
}

-(void)add_no_data_view
{
    CGFloat width=self.frame.size.width;
    CGFloat height=self.frame.size.height;
    CGFloat pic_width=width/2.5;
    self.iv_noData=[[UIImageView alloc] initWithFrame:CGRectMake((width-pic_width)/2, (height-pic_width)/2, pic_width, pic_width)];
    self.iv_noData.image=self.noDataImage?self.noDataImage:[UIImage imageNamed:@"noContent"];
    self.iv_noData.contentMode=UIViewContentModeScaleAspectFit;
    self.iv_noData.hidden=YES;
    [self addSubview:self.iv_noData];
    
    self.tipLb = [[UILabel alloc]initWithFrame:CGRectZero];
    self.tipLb.text = self.tipStr?self.tipStr:@"暂无数据";
    self.tipLb.textAlignment = NSTextAlignmentCenter;
    self.tipLb.font = FONT(15);
    self.tipLb.textColor = RGB(150, 150, 150);
    self.tipLb.hidden = YES;
    [self addSubview:self.tipLb];
    [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.iv_noData.mas_bottom).offset(5);
    }];
    
}

///设置无网络时的图片
- (void)set_noNetWork_img:(UIImage*)image andTip:(NSString *)tip
{
    if (image) {
        self.noDataImage=image;
        self.tipStr=tip;
    }
}

-(void)reloadData
{
    [super reloadData];
    
    if (self.indexPathsForVisibleRows.count>0) {
        self.iv_noData.hidden=YES;
        self.tipLb.hidden=YES;
    }else{
        if (self.tableHeaderView) {
            CGFloat width=self.frame.size.width;
            CGFloat height=self.frame.size.height;
            CGFloat pic_width=width/5;
            self.iv_noData.frame=CGRectMake((width-pic_width)/2, (height-pic_width)/3+self.tableHeaderView.frame.size.height, pic_width, pic_width);
            self.tipLb.frame=CGRectMake((width-pic_width)/2, (height-pic_width)/3+self.tableHeaderView.frame.size.height+pic_width, pic_width, pic_width);
        }
        self.iv_noData.hidden=NO;
        self.tipLb.hidden=NO;
    }
}

@end
