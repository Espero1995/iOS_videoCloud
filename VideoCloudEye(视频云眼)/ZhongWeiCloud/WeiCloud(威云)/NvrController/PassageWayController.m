//
//  PassageWayController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "PassageWayController.h"
#import "ZCTabBarController.h"
#import "PassageWay_t.h"
#import "WeiCloudListModel.h"
#import "MonitoringViewController.h"
@interface PassageWayController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    //删除按钮
    UIButton * _lookBtn;
    
    BOOL _editing;
}
@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) UIButton * editButton;

@property (nonatomic,strong) UIButton * allChoose;

@property (nonatomic,strong) UILabel * lookLabel;


@end

@implementation PassageWayController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
    [self refreshUI];
    [self cteateNavBtn];
    [self createTableView];
    _editing = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    
    NSLog(@"%d",_chan_size);
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    
}
- (void)loadData{

    _dataArr = [NSMutableArray array];

}
- (void)refreshUI{

    _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 14)];
    [_editButton setTitle:@"选择" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor colorWithHexString:@"38adff"] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(chooseItem) forControlEvents:UIControlEventTouchUpInside];
    _editButton.userInteractionEnabled = YES;
    
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editButton];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -8;
    self.navigationItem.rightBarButtonItems = @[rightSpace,rightItem];
}

#pragma mark ------ 删除和已读按钮的创建和响应事件
//创建预览按钮
- (void)createLookButton
{
    _lookLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 60)];
    _lookLabel.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
    [self.view addSubview:_lookLabel];
    [self.view bringSubviewToFront:_lookLabel];
    [_lookLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
    }];
    
    _lookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _lookBtn.frame = CGRectMake(0, 0, 300, 80);
    _lookBtn.backgroundColor = [UIColor colorWithHexString:@"#82c6f5"];
    _lookBtn.layer.cornerRadius = 6;
    [_lookBtn setTitle:@"开始预览" forState:UIControlStateNormal];
    
    [_lookBtn setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
    
    _lookBtn.userInteractionEnabled = YES;
    [_lookBtn addTarget:self action:@selector(lookOver) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_lookBtn];
    [_lookBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lookLabel.mas_left).offset(37.5);
        make.top.equalTo(_lookLabel.mas_top).offset(10);
        make.right.equalTo(_lookLabel.mas_right).offset(-37.5);
        make.bottom.equalTo(_lookLabel.mas_bottom).offset(-10);
    }];
    [self.view bringSubviewToFront:_lookBtn];
    
    
}
//取消按钮
- (void)chooseItem
{
    [self createLookButton];
    _editing = YES;
    _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 14)];
    [_editButton setTitle:@"取消" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor colorWithHexString:@"38adff"] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(cancelChoose) forControlEvents:UIControlEventTouchUpInside];
    _editButton.userInteractionEnabled = YES;
    
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editButton];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -8;
    self.navigationItem.rightBarButtonItems = @[rightSpace,rightItem];

    for (int i = 0; i<_chan_size; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        PassageWay_t * cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.chooseBtn.hidden = NO;
    }
}
- (void)lookOver{
    
    MonitoringViewController * monitorVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    monitorVC.chan_way = _way;
    [self.navigationController popToViewController:monitorVC animated:true];

}
//取消编辑
- (void)cancelChoose{
    [_dataArr removeAllObjects];
    [self.lookLabel removeFromSuperview];
    _editing = NO;
    [self cteateNavBtn];
    [self refreshUI];
    for (int i = 0; i<_chan_size; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        PassageWay_t * cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.chooseBtn.selected = NO;
        cell.chooseBtn.hidden = YES;
    }

}


#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, iPhoneHeight) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    
    UIView * footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    [self.view addSubview:self.tableView];
}
//行高

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _chan_size;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"MyCell";
    PassageWay_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        
        cell = [[PassageWay_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        
    }
    cell.titleLbel.text = [NSString stringWithFormat:@"通道00%ld",(long)indexPath.row+1];
    cell.chooseBtn.hidden = YES;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSInteger i = indexPath.row+1;
//    NSNumber * num = [NSNumber numberWithInteger:i];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_editing == YES) {
        for (int i = 0; i<_chan_size; i++) {
            NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
            PassageWay_t * cell1 = [_tableView cellForRowAtIndexPath:index];
            cell1.chooseBtn.selected = NO;
        }

        PassageWay_t * cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.chooseBtn.selected == NO) {
            cell.chooseBtn.selected = YES;
            _way = indexPath.row+1;
            NSLog(@"%ld",(long)_way);
//            
//            [_dataArr addObject:num];
//            NSLog(@"%@",_dataArr);
        }else{
            cell.chooseBtn.selected = NO;
//            [_dataArr removeObject:num];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
