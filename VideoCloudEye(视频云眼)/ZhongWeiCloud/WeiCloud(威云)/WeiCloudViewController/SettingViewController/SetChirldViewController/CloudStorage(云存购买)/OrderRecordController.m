//
//  OrderRecordController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2017/12/5.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "OrderRecordController.h"
#import "ZCTabBarController.h"
#import "OrderRecordCell.h"
#import "MealRecordModel.h"
/*无内容是显示视图*/
#import "EmptyDataBGView.h"
@interface OrderRecordController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
@property(nonatomic,strong) UITableView *tv_list;
@property (nonatomic,strong) UIView * backView;//无数据时的背景
@property (nonatomic,strong)EmptyDataBGView *bgView;//无内容时背景图
@end

@implementation OrderRecordController
//======================system========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"当前套餐", nil);
    self.view.backgroundColor = BG_COLOR;
     [self cteateNavBtn];
     [self createTableView];
     [self createHeadView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//======================init========================
#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{
    if (self.orderRecordArr.count == 0) {
//        [self createBackImage];
        [self.view addSubview:self.bgView];
    }else{
        [self.bgView removeFromSuperview];
    self.tv_list=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, iPhoneHeight-64) style:UITableViewStylePlain];
    //设置代理
    self.tv_list.delegate=self;
    self.tv_list.dataSource=self;
    self.tv_list.backgroundColor = BG_COLOR;
    [self.tv_list setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:self.tv_list];
    }
}

#pragma mark ------创建头视图
- (void)createHeadView{
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 45)];
    headView.backgroundColor = BG_COLOR;
    self.tv_list.tableHeaderView = headView;
    
    float width = iPhoneWidth/3;
    //1.
    UILabel *tipLabel1 = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    tipLabel1.text = NSLocalizedString(@"套餐类型", nil);
    tipLabel1.textColor = RGB(140, 141, 142);
    tipLabel1.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:tipLabel1];
    [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headView.mas_left).offset(0);
        make.centerY.mas_equalTo(headView);
        make.size.mas_equalTo(CGSizeMake(width, 18));
    }];
    //2.
    UILabel *tipLabel2 = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    tipLabel2.text = NSLocalizedString(@"生效时间", nil);
    tipLabel2.textColor = RGB(140, 141, 142);
    tipLabel2.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:tipLabel2];
    [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(headView);
        make.centerX.mas_equalTo(headView);
        make.size.mas_equalTo(CGSizeMake(width, 18));
    }];
    //3.
    UILabel *tipLabel3 = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    tipLabel3.text = NSLocalizedString(@"到期时间", nil);
    tipLabel3.textColor = RGB(140, 141, 142);
    tipLabel3.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:tipLabel3];
    [tipLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(headView.mas_right).offset(0);
        make.centerY.mas_equalTo(headView);
        make.size.mas_equalTo(CGSizeMake(width, 18));
    }];
    
}

//======================method========================
//- (void)cteateNavBtn{
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return"] style:UIBarButtonItemStylePlain target:self action:@selector(returnVC)];
//    // 设置返回图片颜色
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//}
//
////返回上一页
//- (void)returnVC{
//    [self.navigationController popViewControllerAnimated:NO];
//}

/**
 * description 输入字符串返回时间格式化的时间字符串方法
 * 默认:返回的是以秒为单位，若为毫秒:则进行interval/1000操作。
 */
- (NSString *)backFormatterTime:(NSString *)time{
    NSTimeInterval interval = [time doubleValue];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *newTimeStr = [formatter stringFromDate:startDate];
    return newTimeStr;
}

#pragma mark ------没有存储信息时显示
//没有存储信息时显示
-(void)createBackImage{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-64)];
    _backView.backgroundColor = BG_COLOR;
    [self.view addSubview:_backView];
    UIImageView * backImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 78.5)];
    backImage.image = [UIImage imageNamed:@"noContent"];
    backImage.center = _backView.center;
    [_backView addSubview:backImage];
    UILabel * backLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    backLabel.text = NSLocalizedString(@"暂无购买记录", nil);
    backLabel.textColor = [UIColor colorWithHexString:@"9d9d9d"];
    [_backView addSubview:backLabel];
    [backLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backImage.mas_bottom).offset(14);
        make.centerX.equalTo(backImage.mas_centerX);
    }];
    
}

//======================delegate========================
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.orderRecordArr.count;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //创建cell视图
    static NSString *str = @"MyOrderCell";
    OrderRecordCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[OrderRecordCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    MealRecordModel *model=[_orderRecordArr objectAtIndex:indexPath.row];
    cell.typeLb.text = model.plan_info;
    
    NSString *startTime = [NSString stringWithFormat:@"%d",model.start_date];
    NSString *endTime = [NSString stringWithFormat:@"%d",model.stop_date];

    cell.effectTimeLb.text = [NSString stringWithFormat:@"%@",[self backFormatterTime:startTime]];
    cell.expireTimeLb.text = [NSString stringWithFormat:@"%@",[self backFormatterTime:endTime]];
    
   
    return cell;
}

//==========================lazy loading==========================
#pragma mark ----- 懒加载
//无内容时的背景图
-(EmptyDataBGView *)bgView{
    if (!_bgView) {
        _bgView = [[EmptyDataBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-44-64) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"noContent"] bgTip:NSLocalizedString(@"暂无购买记录", nil)];
    }
    return _bgView;
}


@end
