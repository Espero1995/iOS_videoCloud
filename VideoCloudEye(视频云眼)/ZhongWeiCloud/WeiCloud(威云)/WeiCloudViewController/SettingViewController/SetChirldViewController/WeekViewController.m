//
//  WeekViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "WeekViewController.h"
#import "SetChirldCell.h"
#import "SetTimeViewController.h"
#import "SetTimeModel.h"

@interface WeekViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

{
    //数据源数组
    NSMutableArray * _array;
    //传值数组
    NSMutableArray * _dataArray;
}

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,copy) NSString * weekString;

@end

@implementation WeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"重复";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = BG_COLOR;
    [self createData];
    [self createTableView];
    [self cteateNavBtn];
//    [self setButtonitem];
    [self getData];
}
#pragma mark ------生成数据源
//数据源
- (void)createData{


    NSArray * timeArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    _array = [[NSMutableArray alloc]initWithArray:timeArray];
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    _weekString = [NSMutableString string];
}
#pragma mark ------ 查询布防
//查询布放
- (void)getData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/getguardplan" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            SetTimeModel * model = [SetTimeModel mj_objectWithKeyValues:responseObject[@"body"]];
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:model.guardConfigList[0]];
            _weekString = [dic valueForKey:@"period"];

        [self.tableView reloadData];
        
    }
    } failure:^(NSError * _Nonnull error) {
    
}];

}
#pragma mark ------设置导航栏按钮和响应事件
//返回上一页
- (void)returnVC{

    SetTimeViewController * setTimeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    if (_dataArray.count == 0) {//!_dataArray.count ||
        [self createAlert];
    }else{
        setTimeVC.weekArray = [NSMutableArray arrayWithArray:_dataArray];
        [self.navigationController popToViewController:setTimeVC animated:true];

    }
}
- (void)createAlert{
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没有选择重复周期！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
    
}
#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 35)];
    headView.backgroundColor = BG_COLOR;
//    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.5)];
//    lineView.backgroundColor = [UIColor colorWithHexString:@"#c9cadc"];
//    [headView addSubview:lineView];
    self.tableView.tableHeaderView = headView;
    
    
    [self.view addSubview:self.tableView];
}

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return 45;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray * titleArray = @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];
    
    static NSString * str = @"MyCell";
    SetChirldCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[SetChirldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.titleLb.text = titleArray[indexPath.row];
    if (!_weekString) {
        NSArray * arr = [_weekString componentsSeparatedByString:@","];
        _dataArray = [NSMutableArray arrayWithArray:arr];
        for (NSString * str in arr) {
            if ([str integerValue] ==  indexPath.row+1) {
                cell.chooseBtn.selected = YES;
            }
        }
    }

    return cell;
}

#pragma mark ------设置区头区尾
//区尾高
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 30;
    }else
        return 0;
}
//区尾高
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 30)];
        backView.backgroundColor = BG_COLOR;
        return backView;
    }
    return nil;
}
#pragma mark ------cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        SetChirldCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.chooseBtn.selected == NO) {
            cell.chooseBtn.selected = YES;
            [_dataArray addObject:_array[indexPath.row]];
            NSLog(@"%@",_dataArray);
        }else{
            
            cell.chooseBtn.selected = NO;
            [_dataArray removeObject:_array[indexPath.row]];
        }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
