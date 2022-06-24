//
//  CloudStorageController.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2017/11/24.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "CloudStorageController.h"
#import "ZCTabBarController.h"
#import "PayWayViewController.h"
#import "SetmealSelectedCell.h"
//套餐类型model
#import "MealTypeModel.h"
//套餐记录model
#import "MealRecordModel.h"
//订单记录页面
#import "OrderRecordController.h"
@interface CloudStorageController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    NSMutableArray  *_tv_dataSource;
    NSMutableArray *_tempArr;
}
@property (nonatomic,strong) UITableView *tableView;
//创建介绍内容的view
@property (nonatomic,strong) UIView *introduceView;
//创建套餐类型view
@property (nonatomic,strong) UIView *setMealView;
//创建三个参数视图view
@property (nonatomic,strong) UIView *parameterView;

//@property (nonatomic,assign) NSInteger row;//为了标记前一个点击的cell

@property (nonatomic,strong) MealTypeModel *mealModel;

@property(nonatomic,strong)NSIndexPath *lastPath;//***主要是用来接收用户上一次所选的cell的indexpath
@end

@implementation CloudStorageController
//======================system========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"云存储", nil);
    self.view.backgroundColor = BG_COLOR;

//    self.row = -1;///使得第一个能被点中
//    [self setNav];
    [self cteateNavBtn];//创建导航栏
    [self loadData];//数据源
    [self createHeadView];//创建头视图【介绍信息+推荐套餐类型+三个参数标准】
    [self createTableView];//创建表视图
    [self createSubmitBtn];//创建提交按钮
    
    //初始化数据源
    _tv_dataSource=[NSMutableArray arrayWithCapacity:0];
    _tempArr=[NSMutableArray arrayWithCapacity:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

//======================init========================
#pragma mark ------创建头视图【介绍信息】
- (void)createHeadView{
    //创建介绍内容的view
    _introduceView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    _introduceView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_introduceView];
    [self.introduceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 120));
    }];
    //给headView添加手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(orderRecordClick)];
    //将手势添加到需要相应的view中去
    [_introduceView addGestureRecognizer:tapGesture];
    
    //云存储的图片
    UIImageView *headImg = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 0, 0) imageName:@"cloudStorage"];
    [self.introduceView addSubview:headImg];//CGRectMake(30, 20, 60, 80)
    [headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.introduceView.mas_left).offset(30);
        make.top.equalTo(self.introduceView.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 80));
    }];
    
    //标题
//    UILabel *titleLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 0, 0) text:headTitle font:[UIFont systemFontOfSize:18]];
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.introduceView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headImg.mas_right).offset(15);
        make.top.equalTo (headImg.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(150, 18));
    }];
    


    //判断是否有购买记录的数据
    if (self.orderRecordArr.count == 0) {
        titleLabel.text = NSLocalizedString(@"云存储", nil);
        //内容
       NSString * content = NSLocalizedString(@"云存储[1] 是在云计算(cloud computing)概念上延伸和发展出来的一个新的概念，是一种新兴的网络存储技术，共同对外提供数据存储和业务访问功能的系统。", nil);
        UILabel *contentLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 0, 0)text:content font:[UIFont systemFontOfSize:12]];
        contentLabel.textColor = RGB(140, 141, 142);
        contentLabel.numberOfLines = 0;
        contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.introduceView addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headImg.mas_right).offset(15);
            make.top.equalTo (titleLabel.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth-90-30, 80));
        }];
    }else{
        titleLabel.text  = NSLocalizedString(@"当前套餐", nil);
        MealRecordModel *model = self.orderRecordArr[0];

        //当前套餐信息
        UILabel *planInfoLb = [[UILabel alloc]init];
        planInfoLb.font = [UIFont systemFontOfSize:17.0f];
        [self.introduceView addSubview:planInfoLb];
        [planInfoLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headImg.mas_right).offset(15);
            make.top.equalTo (titleLabel.mas_bottom).offset(5);
            make.right.equalTo(self.view.mas_right).offset(0);
        }];
        planInfoLb.text = model.plan_info;
        //开始时间与截止时间
        UILabel *timeLb = [[UILabel alloc]init];
        timeLb.font = [UIFont systemFontOfSize:14.0f];
        timeLb.textColor =RGB(177, 177, 177);
        timeLb.numberOfLines = 0;
        [self.introduceView addSubview:timeLb];
        [timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headImg.mas_right).offset(15);
            make.top.equalTo (planInfoLb.mas_bottom).offset(5);
            make.size.mas_equalTo(CGSizeMake(250, 40));
        }];
        NSString *startTime = [NSString stringWithFormat:@"%d",model.start_date];
        NSString *endTime = [NSString stringWithFormat:@"%d",model.stop_date];
        NSString *content =  [NSString stringWithFormat:@"%@:%@\n%@:%@",NSLocalizedString(@"生效时间", nil),[self backFormatterTime:startTime],NSLocalizedString(@"到期时间", nil),[self backFormatterTime:endTime]];
        timeLb.text = content;
    }
    
    //创建套餐类型view
    _setMealView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    _setMealView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_setMealView];
    [self.setMealView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.top.equalTo(self.introduceView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
    }];
    
    
    UILabel *typeLabel =  [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 0, 0) text:NSLocalizedString(@"推荐套餐类型", nil) font:[UIFont systemFontOfSize:16]];
    [self.setMealView addSubview:typeLabel];
    [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.setMealView).offset(15);
        make.centerY.equalTo(self.setMealView);//修改过
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 16));
    }];
    
    //创建三个参数的view
    _parameterView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    _parameterView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_parameterView];
    [self.parameterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.top.equalTo(self.setMealView.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
    }];
    
    float width = iPhoneWidth/3;
    //1.
    UILabel *tipLabel1 = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    tipLabel1.text = NSLocalizedString(@"录像保存(循环)", nil);
    tipLabel1.textColor = [UIColor colorWithRed:81/255.0 green:82/255.0 blue:83/255.0 alpha:1];
    tipLabel1.textAlignment=NSTextAlignmentCenter;
    [self.parameterView addSubview:tipLabel1];
    [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.parameterView.mas_left).offset(0);
        make.centerY.mas_equalTo(self.parameterView);
        make.size.mas_equalTo(CGSizeMake(width, 20));
    }];
    //2.
    UILabel *tipLabel2 = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    tipLabel2.text = NSLocalizedString(@"套餐类型", nil);
    tipLabel2.textColor = [UIColor colorWithRed:81/255.0 green:82/255.0 blue:83/255.0 alpha:1];
    tipLabel2.textAlignment=NSTextAlignmentCenter;
    [self.parameterView addSubview:tipLabel2];
    [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipLabel1.mas_right).offset(0);
        make.centerY.mas_equalTo(self.parameterView);
        make.size.mas_equalTo(CGSizeMake(width, 20));
    }];
    //3.
    UILabel *tipLabel3 = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    tipLabel3.text = NSLocalizedString(@"价格", nil);
    tipLabel3.textColor = [UIColor colorWithRed:81/255.0 green:82/255.0 blue:83/255.0 alpha:1];
    tipLabel3.textAlignment=NSTextAlignmentCenter;
    [self.parameterView addSubview:tipLabel3];
    [tipLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.parameterView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.parameterView);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
}


#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.parameterView.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.width.mas_equalTo(iPhoneWidth);
        make.bottom.mas_equalTo(self.view).offset(-80);
    }];
    
}
#pragma mark ------创建提交按钮
- (void)createSubmitBtn{
    UIView *submitView = [[UIView alloc]initWithFrame:CGRectMake(0, iPhoneHeight-80-iPhoneNav_StatusHeight, iPhoneWidth, 80)];
    submitView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:submitView];
    [submitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 80));
    }];
    submitView.layer.shadowColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1].CGColor;//shadowColor阴影颜色
    submitView.layer.shadowOffset = CGSizeMake(0,-3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    submitView.layer.shadowOpacity = 0.5;//阴影透明度，默认0
    submitView.layer.shadowRadius = 4;//阴影半径，默认3
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame=CGRectMake(15, 15, iPhoneWidth-30, 50);
    [submitBtn setTitle:NSLocalizedString(@"提交订单", nil) forState:UIControlStateNormal];
    [submitBtn setTintColor:[UIColor whiteColor]];
    submitBtn.backgroundColor = MAIN_COLOR;
    submitBtn.layer.cornerRadius=5.0f;
    [submitView addSubview:submitBtn];
    [submitBtn addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark ------生成数据源
- (void)loadData
{
    NSMutableDictionary * putData = [[NSMutableDictionary alloc]initWithCapacity:0];
    NSNumber *languageType;
    if (isSimplifiedChinese) {
        languageType = [NSNumber numberWithInt:1];
    }else{
        languageType = [NSNumber numberWithInt:2];
    }
    [putData setObject:self.deviceID forKey:@"device_id"];//deviceIDTODO
    [putData setObject:languageType forKey:@"languageType"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/cloudplans/list" parameters:putData Iszfb:YES IsToken:YES success:^(id  _Nonnull responseObject) {
//        NSLog(@"套餐选择：%@",responseObject);
        
        //TODO
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSDictionary *dic = responseObject[@"body"];
            NSArray *arr = [dic objectForKey:@"planList"];
            
//            NSLog(@"arr:%@",arr);
            _tempArr=[MealTypeModel mj_objectArrayWithKeyValuesArray: arr];
//            NSLog(@"tempArr:%@",_tempArr);
//            MealTypeModel *model = [[MealTypeModel alloc]init];
//            model = _tempArr[0];
//            NSLog(@"打印信息：%@%@",model.plan_info,model.subject);
            
            if (_tempArr) {
                [_tv_dataSource addObjectsFromArray:_tempArr];
            }
            [self.tableView reloadData];
        
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"购买套餐列表查询失败");
    }];
}

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


//======================delegate========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 5;
    return _tv_dataSource.count;
}


//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    //创建cell视图
    static NSString * str = @"Cell";
    //根据indexPath准确地取出一行，而不是从cell重用队列中取出
//    SetmealSelectedCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    SetmealSelectedCell * cell = [tableView dequeueReusableCellWithIdentifier:str];

    if(!cell){
        cell = [[SetmealSelectedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    //***
    NSInteger oldRow = [_lastPath row];
    if (row == oldRow && _lastPath!=nil) {
        //这个是系统中对勾的那种选择框
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell changeSelectUI];
    }else{
//        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell cancelSelectUI];
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    MealTypeModel *model=[_tv_dataSource objectAtIndex:row];
    //录像保留天数
    cell.daysLabel.text = [NSString stringWithFormat:@"%d%@",model.saving_days,NSLocalizedString(@"天", nil)];
    //套餐类型
//    if (model.plan_type == 1) {
//        cell.typeLabel.text = @"月套餐";
//    }else{
//        cell.typeLabel.text = @"年套餐";
//    }
    
    cell.typeLabel.text = model.plan_info;
    cell.typeLabel.numberOfLines = 0;
    
    //套餐价格（如果价格一样就显示未打折的价格，否则显示打折后的价格）
    if ([model.discount_fee isEqualToString:model.fee]) {
        cell.priceLabel.text = [NSString stringWithFormat:@"￥%@",model.fee];
        cell.originalPriceLabel.text = @"";
        cell.recommandImg.hidden = YES;
        cell.lineImgLabel.hidden = YES;
    }else{
        cell.recommandImg.hidden = NO;
        cell.priceLabel.text = [NSString stringWithFormat:@"￥%@",model.discount_fee];
        cell.originalPriceLabel.text = [NSString stringWithFormat:@"%@",model.fee];
        cell.lineImgLabel.hidden = NO;
    }
    
    
    //todo
//    if (model.isRecommend == 1) {
//        cell.recommandImg.hidden=NO;
//    }else{
//        cell.recommandImg.hidden=YES;
//    }
    
    
    return cell;
}


#pragma mark ------cell的点击事件
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSInteger newRow = [indexPath row];
    NSInteger oldRow = (self .lastPath !=nil)?[self .lastPath row]:-1;
    if (newRow != oldRow) {
        SetmealSelectedCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
//        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [newCell changeSelectUI];
        SetmealSelectedCell *oldCell = [tableView cellForRowAtIndexPath:_lastPath];
//        oldCell.accessoryType = UITableViewCellAccessoryNone;
        [oldCell cancelSelectUI];
        self.lastPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _mealModel = [[MealTypeModel alloc]init];
    _mealModel = [_tv_dataSource objectAtIndex:indexPath.row];
}


//======================method========================
- (void)submitClick{
    
    //选择天数，类型，价格均可
    if (!_mealModel.saving_days) {
        [self showAlert];
    }else{
        PayWayViewController *pay = [[PayWayViewController alloc]init];
        pay.payMealModel=_mealModel;//传值
        pay.deviceID = self.deviceID;
        pay.isMyVCJumpTo = NO;
        [self.navigationController pushViewController:pay animated:YES];
    }
    
}



//警告框
- (void)showAlert{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:NSLocalizedString(@"请选择一种服务套餐", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"好", nil) style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         
                                                     }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//跳转到订单记录页面
- (void) orderRecordClick{
    OrderRecordController *order = [[OrderRecordController alloc]init];
    order.orderRecordArr = self.orderRecordArr;
    [self.navigationController pushViewController:order animated:YES];
}

@end
