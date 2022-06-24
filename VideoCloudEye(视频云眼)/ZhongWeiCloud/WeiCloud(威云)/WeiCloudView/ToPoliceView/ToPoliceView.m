//
//  ToPoliceView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/9.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ToPoliceView.h"
#import "customAlertViewCell.h"
#define Cell_Denifine @"cell_output"

@interface ToPoliceView()
<
UITableViewDelegate,
UITableViewDataSource
>
/*数据源*/
@property (nonatomic) NSArray *dataArr;
/*起始位置*/
@property (nonatomic) CGPoint originPoint;
/*宽度*/
@property (nonatomic) CGFloat width;
/*高度*/
@property (nonatomic) CGFloat height;
/*标题*/
@property (nonatomic) NSString *title;
/*提醒消息*/
@property (nonatomic) NSString *message;
/*headView*/
@property (nonatomic) UIView *headView;
/*Title*/
@property (nonatomic,strong) UILabel *title_lb;
/*message*/
@property (nonatomic,strong) UILabel *message_lb;
/*表视图*/
@property (nonatomic) UITableView *tab_downOut;

@end
@implementation ToPoliceView
//==========================system==========================
-(instancetype)initWithDataArr:(NSArray *)dataArr origin:(CGPoint)point width:(CGFloat)width Singleheight:(CGFloat)height title:(NSString *)title headTitleHeight:(CGFloat)titleHeight{
    self = [super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.dataArr = dataArr;
        self.originPoint = point;
        self.width = width;
        self.height = height;
        self.title = title;
        self.tab_downOut = [[UITableView alloc] init];
        self.tab_downOut.delegate = self;
        self.tab_downOut.dataSource = self;
        self.tab_downOut.backgroundColor = RGB(255, 255, 255);
        self.tab_downOut.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.headView.frame = CGRectMake(self.originPoint.x - width/2, self.originPoint.y , width, titleHeight);
        self.tab_downOut.scrollEnabled = YES;
        self.tab_downOut.showsVerticalScrollIndicator = NO;
        self.tab_downOut.frame = CGRectMake(self.originPoint.x - width/2, self.originPoint.y+titleHeight, width, iPhoneHeight-2*self.originPoint.y-titleHeight);
        
        [self addSubview: self.tab_downOut];
        [self addSubview:self.headView];
        [self.headView addSubview:self.title_lb];
        

    }
    return self;
}

//==========================method==========================
//显示
- (void)customAlertViewShow{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    //动画效果弹出
    //tableView颜色与其外部的颜色透明度区分开来
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    CGRect frame = self.tab_downOut.frame;
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.tab_downOut.alpha = 0.95;
        self.headView.alpha = 0.95;
        self.tab_downOut.frame = frame;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.headView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.headView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.headView.layer.mask = maskLayer;
        
    }];
}
//消失
- (void)customAlertViewDismiss{
    //动画效果淡出
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//点击屏幕警告框消失
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self customAlertViewDismiss];
}
//==========================delegate==========================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    customAlertViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell_Denifine];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"customAlertViewCell" bundle:nil] forCellReuseIdentifier:Cell_Denifine];
        cell = [tableView dequeueReusableCellWithIdentifier:Cell_Denifine];
    }
        cell.lab_title.text = [self.dataArr objectAtIndex:indexPath.row];
        cell.iv_line.hidden = YES;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate) {
        [self.delegate downOutViewSelectRowAtIndex:indexPath.row];
    }
    [self customAlertViewDismiss];
}

//==========================lazy loading==========================
#pragma mark ----- 头视图懒加载
- (UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc]init];
        _headView.backgroundColor = [UIColor whiteColor];
    }
    return _headView;
}
//title
-(UILabel *)title_lb{
    if (!_title_lb) {
        _title_lb = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, 200, 20)];
        _title_lb.text = self.title;
        _title_lb.font = FONTB(18);
    }
    return _title_lb;
}

@end

