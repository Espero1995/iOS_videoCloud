//
//  MessageNewVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/11.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MessageNewVC.h"


//========Model========
/*告警消息model*/
#import "PushMsgModel.h"
//========View========
#import "MessageCell_t.h"
/*自定义按钮*/
#import "UnderlineBtn.h"
//========VC========
/*新的告警消息界面*/
#import "AlarmMsgVC.h"
/*直播消息VC*/
#import "LiveMessageVC.h"
/*商城信息VC*/
#import "ShopMessageVC.h"
/*活动提醒*/
#import "ActivityMessageVC.h"
/*系统通知*/
#import "SystemMessageVC.h"
/*意见反馈*/
#import "SubmitFeebackViewController.h"
@interface MessageNewVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
/*表视图*/
@property (nonatomic,strong) UITableView * tableView;
/*通知数组*/
@property (nonatomic,strong) NSMutableArray * pushArr;
/*定时器*/
@property (nonatomic,strong) NSTimer *timer;
/*表视图底部的提示文字*/
@property (nonatomic,strong) UILabel *tipFeedBackLb;
/*表视图底部的提示按钮*/
@property (nonatomic,strong) UnderlineBtn *tipFeedBackBtn;
/*未读条数*/
@property (nonatomic,copy) NSString *unReadCount;
@end

@implementation MessageNewVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"消息", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = BG_COLOR;
//    _timer = [NSTimer scheduledTimerWithTimeInterval:RedDotTime target:self selector:@selector(getMessageRecord) userInfo:nil repeats:YES];//getMesgCount
    [self createTableView];
    [self setUpUI];
 
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMessageRecord];
    _timer = [NSTimer scheduledTimerWithTimeInterval:RedDotTime target:self selector:@selector(getMessageRecord) userInfo:nil repeats:YES];
    //    [self.pushArr removeAllObjects];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//==========================init==========================
- (void)setUpUI{
    [self.view addSubview:self.tipFeedBackLb];
    [self.tipFeedBackLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX).offset(-35);
        make.bottom.equalTo(self.view.mas_bottom).offset(-(iPhoneToolBarHeight+10));
    }];
    
    [self.view addSubview:self.tipFeedBackBtn];
    [self.tipFeedBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipFeedBackLb.mas_right).offset(0);
        make.centerY.equalTo(self.tipFeedBackLb.mas_centerY);
    }];
}

#pragma mark ------创建tableview
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-164) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.scrollEnabled = NO;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    [self.view addSubview:self.tableView];
}


//==========================method==========================
#pragma mark ------检查消息
- (void)getMesgCount
{
    [self.pushArr removeAllObjects];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    MessageCell_t * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UserID = [defaults objectForKey:@"user_id_push"];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:UserID]) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:UserID];
        NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
        
        for (PushMsgModel *model in pushArr) {
            if (model.markread == NO) {
                [self.pushArr addObject:model];
            }
        }
    }
    
//    NSLog(@"self.pushArr:%@",self.pushArr);
    
    if (self.pushArr.count != 0) {
        cell.attentionImage.alpha = 1;
        cell.MessageLabel.text = NSLocalizedString(@"您有新的消息！", nil);
    }else{
        cell.attentionImage.alpha = 0;
        cell.MessageLabel.text = NSLocalizedString(@"暂无事件消息！", nil);
    }
}

#pragma mark - 从后台查询未读报警消息记录
- (void)getMessageRecord
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/unreadStats" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
       // NSLog(@"获取未读消息条数%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            self.unReadCount = responseObject[@"body"];
            [self.tableView reloadData];
        }else{
            self.unReadCount = @"0";
            [self.tableView reloadData];
        }
        
    } failure:^(NSError * _Nonnull error) {
        self.unReadCount = @"0";
        [self.tableView reloadData];
    }];
}



#pragma mark ------结束定时器
- (void)stopTimer
{
    [_timer invalidate];//将定时器从运行循环中移除，
    _timer = nil;
}

- (void)clickFeedBack{
    SubmitFeebackViewController *feedBackVC = [[SubmitFeebackViewController alloc]init];
    [self.navigationController pushViewController:feedBackVC animated:YES];
}

//==========================delegate==========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else{
        return 3;
    }
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString * str = @"MyCell";
    MessageCell_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[MessageCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    if (section == 0) {
        if (row == 0) {
            cell.headImage.image = [UIImage imageNamed:@"msg_message"];
            cell.NameLabel.text = NSLocalizedString(@"事件消息", nil);
            
            cell.iconImage.image = [UIImage imageNamed:@"msg_equipment"];
//            NSLog(@"消息事件条数：%@",self.unReadCount);
            
            //==========================
            //存储最新的推送过来的model
            NSString * userID = [unitl get_User_id];
            NSString * tempStrKey = [unitl getKeyWithSuffix:userID Key:@"user_id_push"];
            PushMsgModel * model  = [unitl getNeedArchiverDataWithKey:tempStrKey];
//            NSLog(@"model的所有信息：%@",model);
            if (model) {
                NSString * timeStr= [NSString stringWithFormat:@"%d",model.alarmTime];
                NSTimeInterval time=[timeStr doubleValue];//因为时差问题要加8小时 == 28800 sec
                NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
                //                    NSLog(@"date:%@",[detaildate description]);
                //实例化一个NSDateFormatter对象
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //设定时间格式,这里可以设置成自己需要的格式
                [dateFormatter setDateFormat:@"HH:mm"];//yyyy-MM-dd HH:mm:ss
                NSString *currentTimeStr = [dateFormatter stringFromDate: detaildate];
                //                    NSLog(@"pushArrData:%@",currentTimeStr);
                cell.TimeLabel.text = currentTimeStr;
            }else{
                cell.TimeLabel.text = @"";
            }
            
            //==========================
            if ([self.unReadCount intValue]!=0) {
                cell.attentionImage.alpha = 1;
                cell.MessageLabel.text = NSLocalizedString(@"您有新的消息，请及时处理！", nil);
            }else{
                cell.attentionImage.alpha = 0;
                cell.MessageLabel.text = NSLocalizedString(@"暂无新消息", nil);
            }

            }else if (row ==1){
            cell.headImage.image = [UIImage imageNamed:@"msg_live"];
            cell.NameLabel.text = NSLocalizedString(@"直播消息", nil);
            cell.MessageLabel.text = NSLocalizedString(@"暂无直播消息", nil);
        }
    }
    else if (section == 1){
        if (row == 0) {
            cell.headImage.image = [UIImage imageNamed:@"msg_shop"];
            cell.NameLabel.text = NSLocalizedString(@"商城信息", nil);
            cell.MessageLabel.text = NSLocalizedString(@"暂无商城信息", nil);
        }else if (row == 1){
            cell.headImage.image = [UIImage imageNamed:@"msg_activity"];
            cell.NameLabel.text = NSLocalizedString(@"活动提醒", nil);
            cell.MessageLabel.text = NSLocalizedString(@"暂无活动提醒", nil);
        }else if (row == 2){
            cell.headImage.image = [UIImage imageNamed:@"msg_notice"];
            cell.NameLabel.text = NSLocalizedString(@"系统通知", nil);
            cell.iconImage.image = [UIImage imageNamed:@"msg_system"];
            cell.MessageLabel.text = NSLocalizedString(@"暂无系统通知", nil);
        }
    }
    
    return cell;
}

//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row ==0) {
            AlarmMsgVC *alarmVC = [[AlarmMsgVC alloc]init];
            [self.navigationController pushViewController:alarmVC animated:YES];
        }
        if (row == 1) {
            LiveMessageVC *liveMsgVC = [[LiveMessageVC alloc]init];
            [self.navigationController pushViewController:liveMsgVC animated:YES];
        }
    }
    if (section == 1) {
        if (row == 0) {
            ShopMessageVC *shopMsgVC = [[ShopMessageVC alloc]init];
            [self.navigationController pushViewController:shopMsgVC animated:YES];
        }
        if (row == 1) {
            ActivityMessageVC *activityMsgVC = [[ActivityMessageVC alloc]init];
            [self.navigationController pushViewController:activityMsgVC animated:YES];
        }
        
        if (row == 2) {
            SystemMessageVC *systemMsgVC = [[SystemMessageVC alloc]init];
            [self.navigationController pushViewController:systemMsgVC animated:YES];
        }
    }
 
}

//头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return 10;
    }
}

//==========================lazy loading==========================
#pragma mark ------懒加载
- (NSMutableArray *)pushArr
{
    if (!_pushArr) {
        _pushArr = [NSMutableArray array];
    }
    return _pushArr;
}
//表视图底部的意见反馈label
- (UILabel *)tipFeedBackLb{
    if (!_tipFeedBackLb) {
        _tipFeedBackLb = [FactoryUI createLabelWithFrame:CGRectZero text:NSLocalizedString(@"有疑问或者建议？点击", nil) font:FONT(15)];
        _tipFeedBackLb.textColor = [UIColor grayColor];
    }
    return _tipFeedBackLb;
}
//表视图底部的意见反馈button
- (UnderlineBtn *)tipFeedBackBtn{
    if (!_tipFeedBackBtn) {
        _tipFeedBackBtn = [[UnderlineBtn alloc]init];
        [_tipFeedBackBtn setTitle:NSLocalizedString(@"我要反馈", nil) forState:UIControlStateNormal];
        [_tipFeedBackBtn setColor:MAIN_COLOR];
        [_tipFeedBackBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _tipFeedBackBtn.titleLabel.font = FONT(15);
        [_tipFeedBackBtn addTarget:self action:@selector(clickFeedBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tipFeedBackBtn;
}

@end
