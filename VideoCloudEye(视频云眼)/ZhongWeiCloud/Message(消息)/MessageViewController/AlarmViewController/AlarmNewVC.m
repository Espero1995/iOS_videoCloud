//
//  AlarmNewVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/12.
//  Copyright © 2018年 张策. All rights reserved.
//
#import "AlarmNewVC.h"
#import "AlarmNewCell.h"
#import "ZCTabBarController.h"
#import "PushMsgModel.h"
#import "InvestigateViewController.h"
#import "WeiCloudListModel.h"
/*点击进入的页面*/
#import "PlayBackNewVC.h"
#import "FilerView.h"//筛选View
#import "FilerDeviceVC.h"//选择设备VC
#import "BallLoading.h"//等待框
#import "NSDate+calculate.h"
#import "EmptyDataBGView.h"//无内容是显示视图
#import "ProgressBarView.h"
@interface AlarmNewVC ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    AlarmCell_tDelegete,
    FilerViewDelegate,
    UIScrollViewDelegate
>
{   /*数据源*/
    NSMutableArray * _array;
    /*本地数据*/
    NSMutableArray * _arrayM;
    /*记录删除数据*/
    NSMutableArray * _deleteArray;
    /*编辑按钮*/
    UIButton * _editBtn;
    /*筛选按钮*/
    UIButton* _filterBtn;
    /*返回按钮*/
    UIButton * _backButton;
    /*全选按钮*/
    UIButton * _allChooseBtn;
    /*删除按钮*/
    UIButton * _deleteBtn;
    /*全部已读按钮*/
    UIButton * _readBtn;
    /*记录tableView的编辑状态*/
    BOOL _editing;
    /*区别是否是同一天*/
    NSString *tempDate;
    /*记录是选择了哪一个时间点*/
    NSInteger dateRow;
    /*存储显示的七天时间*/
    NSMutableArray *fdateArr;
    NSInteger loadCount;//加载次数
}

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) UILabel * deleteBottomLb;
/*未操作的数据源*/
@property (nonatomic,strong) NSMutableArray * btnArr;
@property (nonatomic,strong) NSString * pushStr;

@property (nonatomic,strong) UIView * backView;

/*存储日期*/
@property (nonatomic,strong) NSMutableArray *resultDateArr;
@property (nonatomic,strong) NSMutableArray* testArr;
/*头部日期提醒*/
@property (nonatomic,strong) UILabel *dateTipLb;
@property (nonatomic,assign) BOOL isPop;//是否已经弹出,默认为NO
@property (nonatomic,strong) FilerView* filerView;//筛选View
@property (nonatomic,strong) EmptyDataBGView* bgView;//无内容时背景图
/*进度条View*/
@property (nonatomic,strong) ProgressBarView *progressView;

@property (nonatomic,strong) UIScrollView *scanImg;//放大的图片
@property (nonatomic,strong) UIView *enlargeImageView;

@end

@implementation AlarmNewVC
//========================system========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"事件中心";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = BG_COLOR;
    tempDate = @"tempDate";
    //初始化数据
    self.isPop = NO;//默认关闭弹出视图
    dateRow = -1;//默认 -1（0~6）
    loadCount = 0;
    //创建导航栏按钮
    [self setButtonitem];
    //创建tableview
    [self createTableView];
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    
//    NSLog(@"nameArr:%@",[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceName"]);
    //展示选择的设备名字
    [self.filerView getDeviceNameArr:[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceName"]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //存储最新的pushmodel
    NSString * userID = [unitl get_User_id];
    NSString * tempStrKey = [unitl getKeyWithSuffix:userID Key:@"user_id_push"];
    
    if (_arrayM.count == 0) {
        [unitl clearDataWithKey:tempStrKey];
    }else{
        PushMsgModel * newPushModel = _arrayM[0];
        [unitl saveNeedArchiverDataWithKey:tempStrKey Data:newPushModel];
    }
}

//========================init========================
#pragma mark-------创建tableview并设置分区和高度
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64) style:UITableViewStyleGrouped];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    
    [self.view addSubview:self.tableView];

    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownMethod)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
    //上拉加载
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

#pragma mark ------ 刷新
//上拉刷新响应
- (void)loadMoreData
{
    loadCount ++;
    [self performSelector:@selector(endUpRefresh) withObject:nil afterDelay:2];
}
- (void)endUpRefresh
{
    if (loadCount < self.resultDateArr.count) {
        [self.testArr addObject:self.resultDateArr[loadCount]];
    }else{
        [XHToast showCenterWithText:@"暂无更多数据"];
    }
    
    [self.tableView reloadData];
    [self.tableView.mj_footer endRefreshing];

}



- (JW_CIPHER_CTX)cipher
{
//    if (_cipher == nil) {
        if (self.key && self.bIsEncrypt) {
            size_t len = strlen([self.key cStringUsingEncoding:NSASCIIStringEncoding]);
            _cipher =  jw_cipher_create((const unsigned char*)[self.key cStringUsingEncoding:NSASCIIStringEncoding], len);
//            NSLog(@"报警界面创建cipher：%p",&_cipher);
        }
//    }
    return _cipher;
}


//========================method========================
//下拉刷新
- (void)pullDownMethod
{
    NSString* resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
    NSLog(@"resultID:%@",resultID);
    [self.bgView removeFromSuperview];
    if (dateRow == -1 && self.myResultDeviceArr.count == 0) {
        [self queryAlarmMessageFromServer];
    }else{//dateRow == -1 && self.myResultDeviceArr.count != 0
        if (dateRow == -1) {
            NSString* resultID;
            if (self.myResultDeviceArr.count == 0) {
                resultID = @"";
            }else{
                resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
            }
            [self FilterAlarmMessageFromServerID:resultID];
        }else{
            NSString* resultID;
            if (self.myResultDeviceArr.count == 0) {
                resultID = @"";
            }else{
                resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
            }
            [self FilterAlarmMessageFromServerID:resultID andDate:fdateArr[dateRow]];
        }
     }
}

#pragma mark - 从服务器主动查询推送过来的报警信息
- (void)queryAlarmMessageFromServer
{
    self.btnArr = [NSMutableArray array];
    _timeString = [NSString string];
    _deleteArray = [NSMutableArray array];
    NSDate * date = [NSDate date];//当前时间
//    NSDate * lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
    NSDate* lastDay = [NSDate zeroOfDate];
    NSLog(@"date:%@lastDay:%@",date,lastDay);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *startTime = [NSString stringWithFormat:@"%ld", (long)[lastDay timeIntervalSince1970]-8*60*60-6*24*3600];//7天前的时间
    NSString *stopTime = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];

//    NSLog(@"7天前的时间%@截止到今天的时间：%@",startTime,stopTime);
    
    NSMutableDictionary * postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [postDic setObject:@"" forKey:@"dev_id"];
    [postDic setObject:stopTime forKey:@"stop_time"];
    [postDic setObject:startTime forKey:@"start_time"];
    [postDic setObject:@"0" forKey:@"offset"];
    [postDic setObject:@"500" forKey:@"limit"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        
//        if (self.isPop == YES) {
//            [self closeFilerClick];//查询成功后关闭筛选
//        }
        
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            NSLog(@"从服务器主动查询推送过来的报警信息responseObject:%@",responseObject);
            NSMutableArray * tempArr = responseObject[@"body"][@"alarmList"];
            _arrayM = [[NSMutableArray alloc]init];
            for (int i = 0; i < tempArr.count; i++) {
                PushMsgModel *pushModel = [[PushMsgModel alloc]init];
                pushModel.alarmId = tempArr[i][@"alarmId"];
                pushModel.alarmPic = tempArr[i][@"alarmPic"];
                pushModel.deviceId = tempArr[i][@"deviceId"];
                pushModel.deviceName = tempArr[i][@"deviceName"];
                pushModel.alarmTime = [tempArr[i][@"alarmTime"]intValue];
                pushModel.markread = [tempArr[i][@"markread"]boolValue];//NO
                [_arrayM addObject:pushModel];
            }
//            NSLog(@"个数：%lu",(unsigned long)_arrayM.count);
            //得到按时间分组后的结果数组self.resultArr
            
            //用来选择选中的数组TODO
            for (int i = 0; i<_arrayM.count; i++) {
                NSString * btnStr = [NSString stringWithFormat:@"no"];
                [self.btnArr addObject:btnStr];
            }

            [self arrayClassification:_arrayM];
            
            if (_arrayM.count == 0) {
                [self.view addSubview:self.bgView];
            }else{
                [self.bgView removeFromSuperview];
            }
            [self.tableView reloadData];
            
            [self.tableView.mj_header endRefreshing];
        }else{
            [self.view addSubview:self.bgView];
            NSLog(@"从服务器主动查询推送过来的报警信息【失败】:%@",responseObject);
            [self.tableView.mj_header endRefreshing];
        }
        [BallLoading hideBallInView:self.filerView];
    }failure:^(NSError * _Nonnull error) {
        if (self.isPop == YES) {
//            [self closeFilerClick];//查询失败也需关闭筛选
            [BallLoading hideBallInView:self.filerView];
        }
        [self.view addSubview:self.bgView];
        NSLog(@"从服务器主动查询推送过来的报警信息【失败~~】");
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark ------编辑按钮和相应事件
//编辑按钮（未编辑状态）
- (void)setButtonitem{
    //编辑按钮
    _editBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    _editBtn.titleLabel.font = FONT(17);
    [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(editCell) forControlEvents:UIControlEventTouchUpInside];
    _editBtn.userInteractionEnabled = YES;
    _editBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem* editRightItem = [[UIBarButtonItem alloc]initWithCustomView:_editBtn];
    
    _filterBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_filterBtn setTitle:@"筛选" forState:UIControlStateNormal];
    _filterBtn.titleLabel.font = FONT(17);
    [_filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_filterBtn addTarget:self action:@selector(filterClick) forControlEvents:UIControlEventTouchUpInside];
    _filterBtn.userInteractionEnabled = YES;
    _filterBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
    
    UIBarButtonItem* filterRightItem = [[UIBarButtonItem alloc]initWithCustomView:_filterBtn];
    self.navigationItem.rightBarButtonItems = @[editRightItem,filterRightItem];
    
    [self cteateNavBtn];
}


//编辑按钮
- (void)editCell{
    
    if (_arrayM.count!=0) {
        _editing = YES;
        _tableView.allowsMultipleSelection = YES;
        self.tableView.frame = CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-110);
        [self createDeleteButton];
        [self createNavButton];
        if (_editBtn.selected == NO) {
            _editBtn.selected = YES;
            [_tableView reloadData];
        }
    }else{
        [XHToast showCenterWithText:@"无事件消息"];
    }

}
#pragma mark ------取消和全选按钮
//创建取消，全选按钮（编辑状态）
- (void)createNavButton
{
    _editBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_editBtn setTitle:@"取消" forState:UIControlStateNormal];
    _editBtn.titleLabel.font = FONT(17);
    [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    _editBtn.userInteractionEnabled = YES;
    _editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *btn = [[UIButton alloc]init];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItems = @[leftItem];
}

//全选cell
- (void)chooseAllCell{
    
    [_deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_deleteBtn setTitle:@"删除(全部)" forState:UIControlStateNormal];
    if (_allChooseBtn.selected == NO) {
        _allChooseBtn.selected = YES;
        [_allChooseBtn setTitle:@"取消全选" forState:UIControlStateNormal];
        [_deleteArray removeAllObjects];
        for (int i = 0; i<_arrayM.count; i++) {
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
        }
            [_deleteArray addObjectsFromArray:_arrayM];

    }else{
        for (int i = 0; i<_arrayM.count; i++) {
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
        }
        
        _allChooseBtn.selected = NO;
        [_allChooseBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteArray removeAllObjects];
    }
    [self.tableView reloadData];
}

//取消编辑按钮
- (void)cancelEdit
{
    for (int i = 0; i<_arrayM.count; i++) {
        NSString * btnStr = [NSString stringWithFormat:@"no"];
        [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
    }
    
    _editing = NO;
    self.tableView.frame = CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64);
    [_deleteArray removeAllObjects];
    _editBtn.selected = NO;
    
    [_tableView reloadData];
    //编辑按钮
    [self setButtonitem];
    
    [_deleteBottomLb removeFromSuperview];
    [_deleteBtn removeFromSuperview];
    [_readBtn removeFromSuperview];
    [_allChooseBtn removeFromSuperview];
}
#pragma mark ------删除和已读按钮的创建和响应事件
//创建删除按钮
- (void)createDeleteButton
{
    _deleteBottomLb= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 50)];
    _deleteBottomLb.backgroundColor = [UIColor colorWithHexString:@"#f4f3f3"];
    [self.view addSubview:_deleteBottomLb];
    [self.view bringSubviewToFront:_deleteBottomLb];
    [_deleteBottomLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(@50);
    }];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(0, 0, 40, 15);
    
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    if (_deleteArray.count == 0) {
        [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    _deleteBtn.userInteractionEnabled = YES;
    [_deleteBtn addTarget:self action:@selector(deleteCellAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_deleteBottomLb.mas_centerX);
        make.centerY.equalTo(_deleteBottomLb.mas_centerY);
    }];
    [self.view bringSubviewToFront:_deleteBtn];
    
    _readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _readBtn.frame = CGRectMake(0, 0, 75, 15);
    [_readBtn setTitle:@"标记已读" forState:UIControlStateNormal];
    [_readBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _readBtn.userInteractionEnabled = YES;
    [_readBtn addTarget:self action:@selector(ignoreMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_readBtn];
    [_readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_deleteBottomLb.mas_right).offset(-10);
        make.centerY.equalTo(_deleteBottomLb.mas_centerY);
        make.left.equalTo(_deleteBottomLb.mas_right).offset(-100);
    }];
    _readBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
     _allChooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allChooseBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_allChooseBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [_allChooseBtn addTarget:self action:@selector(chooseAllCell) forControlEvents:UIControlEventTouchUpInside];
    _allChooseBtn.highlighted = YES;
    _allChooseBtn.userInteractionEnabled = YES;
    _allChooseBtn.selected = NO;
    [self.view addSubview:_allChooseBtn];
    [_allChooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_deleteBottomLb.mas_left).offset(10);
        make.right.equalTo(_deleteBottomLb.mas_left).offset(100);
        make.centerY.equalTo(_deleteBottomLb.mas_centerY);
    }];
    _allChooseBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

//删除警告框
- (void)deleteCellAlert
{
    if (_deleteArray.count == 0) {
        return ;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示"message:@"删除后不可恢复，确定要删除吗？"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteCell];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//删除cell
- (void)deleteCell
{

    
    [self.view addSubview:self.progressView];
    
    /*
     * description : POST v1/alarm/delete(删除告警消息)
     *  param：access_token=<令牌> & user_id=<用户ID> & alarm_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    NSString *totalStr = [NSString stringWithFormat:@"%lu",(unsigned long)_deleteArray.count];
    int totalCount = [totalStr intValue];
   __block int deleteCount = 0;
    for (int i = 0; i<_deleteArray.count; i++) {
        PushMsgModel *pushModel = _deleteArray[i];
        [dic setObject:pushModel.alarmId forKey:@"alarm_id"];
       
        [[HDNetworking sharedHDNetworking]POST:@"v1/alarm/delete" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
            deleteCount ++;
            [self.progressView ProgressBarTip:@"正在删除报警消息..." totalCount:totalCount andCurrentCount:deleteCount];
//            NSLog(@"deleteCount:%d,_deleteArray.count:%d",deleteCount,totalCount);
            if (deleteCount == totalCount) {
                [self.progressView removeFromSuperview];
                [XHToast showCenterWithText:@"告警信息删除成功"];
            }
        } failure:^(NSError * _Nonnull error) {
//            [XHToast showCenterWithText:@"部分告警信息删除失败"];
            [self.progressView removeFromSuperview];
        }];
        
      
    }
    [_arrayM removeAllObjects];
    [self pullDownMethod];
    [_deleteArray removeAllObjects];
    [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self cancelEdit];
}

//返回上一页
- (void)returnVC{
    [self.navigationController popViewControllerAnimated:YES];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

//消息已读
- (void)ignoreMessage{
//    for (int i = 0; i<_arrayM.count; i++) {
//        PushMsgModel * model = _arrayM[i];
//        if (model.isRead == NO) {
//            model.isRead = YES;
//        }
//    }
    
    if (_deleteArray.count == 0) {
        [XHToast showCenterWithText:@"未选择任何告警消息"];
        return;
    }
    
    NSMutableArray *markreadArr = [NSMutableArray arrayWithCapacity:0];
    for (PushMsgModel *model in _deleteArray) {
        if (model.markread == NO) {
            model.markread = YES;
            [markreadArr addObject:model];
        }
    }
    NSLog(@"markreadArr:%@",markreadArr);

    if (markreadArr.count == 0) {
        [XHToast showCenterWithText:@"所选告警消息已读"];
    }
    
    
    /*
     * description : POST v1/alarm/markread(告警消息已读)
     *  param：access_token=<令牌> & user_id=<用户ID> & alarm_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];

    for (int i = 0; i < markreadArr.count; i++) {
        PushMsgModel *model = markreadArr[i];
        [dic setObject:model.alarmId forKey:@"alarm_id"];
        [[HDNetworking sharedHDNetworking] POST:@"v1/alarm/markread" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
//            NSLog(@"responseObject：%@",responseObject);
                [XHToast showCenterWithText:@"告警信息已设置已读"];
        } failure:^(NSError * _Nonnull error) {
            //        [XHToast showTopWithText:@"部分告警信"];
            NSLog(@"告警标记已读失败~");
        }];
    }

//    [_arrayM removeAllObjects];
    
    [_deleteArray removeAllObjects];
    [markreadArr removeAllObjects];
    [self cancelEdit];

    
    [self.tableView reloadData];
}


#pragma mark ----- 时间转星期
- (NSString*)getWeekDay:(NSString*)currentStr
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];//实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式,要注意跟下面的dateString匹配，否则日起将无效
    NSDate*date =[dateFormat dateFromString:currentStr];
    NSArray*weekdays = [NSArray arrayWithObjects: [NSNull null],@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",nil];
    NSCalendar*calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone*timeZone = [[NSTimeZone alloc]initWithName:@"Asia/Beijing"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit =NSCalendarUnitWeekday;
    NSDateComponents*theComponents = [calendar components:calendarUnit fromDate:date];
    return[weekdays objectAtIndex:theComponents.weekday];
}



//========================delegate========================
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return self.resultDateArr.count;
    return self.testArr.count;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
//    [tempArr addObjectsFromArray:self.resultDateArr[section]];
    [tempArr addObjectsFromArray:self.testArr[section]];
    return  tempArr.count;
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        UIView *headView = [[UIView alloc]init];
        //根据已读未读显示红点
        PushMsgModel * model = self.testArr[section][0];//self.resultDateArr
        NSString * timeStr= [NSString stringWithFormat:@"%d",model.alarmTime];
        NSTimeInterval time=[timeStr doubleValue];//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];

        //实例化一个NSDateFormatter对象
        NSDateFormatter * timeDate = [[NSDateFormatter alloc]init];
        NSDateFormatter * timeWeek = [[NSDateFormatter alloc]init];
        //设定时间格式,这里可以设置成自己需要的格式
        [timeDate setDateFormat:@"MM-dd"];
        [timeWeek setDateFormat:@"yyyy-MM-dd"];
        NSString *currentWeekStr = [timeWeek stringFromDate: detaildate];
        NSString *currentDateStr = [timeDate stringFromDate: detaildate];

         UILabel *dateTipLb1 = [[UILabel alloc]init];
    
        dateTipLb1.frame = CGRectMake(10, 0, self.view.frame.size.width, 44);
        dateTipLb1.text =  [NSString stringWithFormat:@"%@  %@",currentDateStr,[self getWeekDay:currentWeekStr]];
        [headView addSubview:dateTipLb1];
    
        headView.backgroundColor = BG_COLOR;
    
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}


//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    
    static NSString * str = @"MyCell";
    AlarmNewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(cell == nil){
        cell = [[AlarmNewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.delegete = self;
    
    if (_editing == NO){
        cell.isEdit = NO;
    }else{
        cell.isEdit = YES;
    }
    
    NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
    [tempDateArr addObjectsFromArray:self.testArr[section]];//resultDateArr
            
    //根据已读未读显示红点
    PushMsgModel * model = tempDateArr[indexPath.row];//_arrayM
        NSString * timeStr= [NSString stringWithFormat:@"%d",model.alarmTime];
        NSTimeInterval time=[timeStr doubleValue];//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //    NSLog(@"date:%@",[detaildate description]);
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter * timeDate = [[NSDateFormatter alloc]init];
        NSDateFormatter * timeWeek = [[NSDateFormatter alloc]init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
        [timeDate setDateFormat:@"MM月dd"];
        [timeWeek setDateFormat:@"yyyy-MM-dd"];
        NSString *currentTimeStr = [dateFormatter stringFromDate: detaildate];
        //设置了时间
        cell.timeLabel.text = currentTimeStr;

    if (model.markread == NO) {
        cell.attentionView.alpha = 1;
    }else{
        cell.attentionView.alpha = 0;
    }
    cell.typeLabel.text = [NSString stringWithFormat:@"%@警报",model.deviceName];
    cell.messageLabel.text = [NSString stringWithFormat:@"来自 %@",model.deviceName];
    NSString *imaStr = [NSString isNullToString:model.alarmPic];
    NSURL *imaUrl = [NSURL URLWithString:imaStr];
    NSString * imageName =  [cell.pictureImage.image accessibilityIdentifier];
    if (cell.pictureImage.image == nil || [imageName isEqualToString:@"img2"]) {
        cell.pictureImage.image = [UIImage imageNamed:@"img2"];
    }
   
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imaUrl];
    __block UIImage * image;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        //设备图片展示时所需解密的东西
        dev_list *devModel;
        NSMutableArray *devArr = (NSMutableArray *)[unitl getAllDeviceCameraModel];
        for (int i = 0; i < devArr.count; i++) {
            if ([((dev_list*)(devArr[i])).ID isEqualToString:model.deviceId]) {
                devModel = ((dev_list*)(devArr[i]));
                break;
            }
        }

        self.key = devModel.dev_p_code;
        self.bIsEncrypt = devModel.enable_sec;
        
        
        NSLog(@"报警界面收到图片的data：%@---长度：%zd",response,data.length);
        
        const unsigned char *imageCharData=(const unsigned char*)[data bytes];
        size_t len = [data length];
        
        unsigned char outImageCharData[len];
        size_t outLen = len;
        NSLog(@"收到图片的data：%@---长度：%zd",response,[data length]);
        if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200 && self.key.length > 0 && self.bIsEncrypt) {
            int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
            NSLog(@"报警界面，收到加密图片数据正确，进行解密:%d",decrptImageSucceed);
            if (decrptImageSucceed == 1) {
                NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                image  = [UIImage imageWithData:imageData];
                if (image) {
                    cell.pictureImage.image = image;
                }else{
                    dispatch_async(dispatch_get_main_queue(),^{
                        [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
                    });
                }
            }else{
                dispatch_async(dispatch_get_main_queue(),^{
                    [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(),^{
                [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
            });
        }
    }];
    
    
    if (_editBtn.selected == YES) {
        cell.chooseBtn.alpha = 1;
        cell.chooseBtn.enabled = YES;
        cell.chooseBtn.userInteractionEnabled = YES;
        //全选的判断
        if (_allChooseBtn.selected == YES ) {
            cell.chooseBtn.selected = YES;
        }else{
            cell.chooseBtn.selected = NO;
        }
        
        
        //判断当前选择第几个
        NSInteger tempCount = 0;
        for (int i =0; i< indexPath.section; i++) {
            tempCount += [[self.resultDateArr objectAtIndex:i] count];
        }
        tempCount = tempCount + indexPath.row+1;
//        NSLog(@"我self.btnArr的状态：%@",self.btnArr);
       
        
        if ([self.btnArr[tempCount-1] isEqualToString:@"yes"]) {//[indexPath.row]
            cell.chooseBtn.selected = YES;
        }else{
            cell.chooseBtn.selected = NO;
        }

    }else{
        cell.chooseBtn.alpha = 0;
        cell.chooseBtn.enabled = NO;
        cell.chooseBtn.userInteractionEnabled = NO;
    }
    
    return cell;
}


#pragma mark------ 点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //判断当前选择第几个
    NSInteger tempCount = 0;
    for (int i =0; i< indexPath.section; i++) {
        tempCount += [[self.resultDateArr objectAtIndex:i] count];
    }
    tempCount = tempCount + indexPath.row+1;
//    NSLog(@"我现在选择的是第%ld个",tempCount);
   

    if (_editing == YES) {

        if ([self.btnArr[tempCount-1] isEqualToString:@"no"]) {//indexPath.row
            
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:tempCount -1 withObject:btnStr];//indexPath.row
            
            [_deleteArray addObject:[_arrayM objectAtIndex:tempCount-1]];//indexPath.row
            [self.tableView reloadData];
        }else{
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:tempCount-1 withObject:btnStr];//indexPath.row
            [_deleteArray removeObject:[_arrayM objectAtIndex:tempCount-1]];//indexPath.row
            [self.tableView reloadData];
        }
        //根据删除的个数来变化删除的颜色
        if (_deleteArray.count == 0) {
            [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        }else{
            NSString *title = [NSString stringWithFormat:@"删除(%ld)",_deleteArray.count];
            [_deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [_deleteBtn setTitle:title forState:UIControlStateNormal];
        }
        
    }
    
    else if (_editing == NO){
//        PushMsgModel * model = _arrayM[indexPath.row];
        PushMsgModel * model = self.resultDateArr[indexPath.section][indexPath.row];
        if (model.markread == NO) {
            model.markread = YES;
        }
        AlarmNewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.attentionView.alpha = 0;

        [self Alarmcell_tPictureImageClick:cell];
    }
}

#pragma mark ———获取所有cell
-(NSArray *)cellsForTableView:(UITableView *)TableView
{
    NSInteger sections = TableView.numberOfSections;
    NSMutableArray * cells = [[NSMutableArray alloc]  init];
    for (int section = 0; section < sections; section++) {
        NSInteger rows =  [TableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [cells addObject:[TableView cellForRowAtIndexPath:indexPath]];
        }
    }
    return cells;
}

#pragma mark------- cell上控件的响应方法
#pragma mark ----- 选择要删除的CELL
- (void)AlarmCell_tChooseBtnClick:(AlarmNewCell *)cell
{
//        [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"38adff"] forState:UIControlStateNormal];
//        if (cell.chooseBtn.selected == NO) {
//            cell.chooseBtn.selected = YES;
//            NSIndexPath *selectIndexPath = [self.tableView indexPathForCell:cell];
//
//            [_deleteArray addObject:[_arrayM objectAtIndex:selectIndexPath.row]];
//        }
//        else{
//            cell.chooseBtn.selected = NO;
//            NSIndexPath *selectIndexPath = [self.tableView indexPathForCell:cell];
//            [_deleteArray removeObject:[_arrayM objectAtIndex:selectIndexPath.row]];
//        }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //判断当前选择第几个
    NSInteger tempCount = 0;
    for (int i =0; i< indexPath.section; i++) {
        tempCount += [[self.resultDateArr objectAtIndex:i] count];
    }
    tempCount = tempCount + indexPath.row+1;
    NSLog(@"我现在选择的是第%ld个",tempCount);
    
    if ([self.btnArr[tempCount-1] isEqualToString:@"no"]) {//indexPath.row
        
        NSString * btnStr = [NSString stringWithFormat:@"yes"];
        [self.btnArr replaceObjectAtIndex:tempCount -1 withObject:btnStr];//indexPath.row
        
        [_deleteArray addObject:[_arrayM objectAtIndex:tempCount-1]];//indexPath.row
        [self.tableView reloadData];
    }else{
        NSString * btnStr = [NSString stringWithFormat:@"no"];
        [self.btnArr replaceObjectAtIndex:tempCount-1 withObject:btnStr];//indexPath.row
        [_deleteArray removeObject:[_arrayM objectAtIndex:tempCount-1]];//indexPath.row
        [self.tableView reloadData];
    }
    
    if (_deleteArray.count == 0) {
        [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    }else{
        NSString *title = [NSString stringWithFormat:@"删除(%ld)",_deleteArray.count];
        [_deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_deleteBtn setTitle:title forState:UIControlStateNormal];
    }
    
}

#pragma mark ----- cell上图片点击事件（放大图片）
- (void)Alarmcell_tPictureImageClick:(AlarmNewCell *)cell
{    //获取到图片所在的cell未读变已读红点消失
    
    NSIndexPath *IndexPath = [self.tableView indexPathForCell:cell];
    PushMsgModel * model = self.resultDateArr[IndexPath.section][IndexPath.row];
    if (model.markread == NO) {
        model.markread = YES;
        cell.attentionView.alpha = 0;
    }
    
    //============================放大图片去掉红点
    /*
     * description : POST v1/alarm/markread(告警消息已读)
     *  param：access_token=<令牌> & user_id=<用户ID> & alarm_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    [dic setObject:model.alarmId forKey:@"alarm_id"];
    [[HDNetworking sharedHDNetworking] POST:@"v1/alarm/markread" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject：%@",responseObject);
    } failure:^(NSError * _Nonnull error) {
        //            [XHToast showTopWithText:@"去除标记失败了"];
    }];
    //============================
    
    
    [self.tableView reloadData];
    
   /*
    //    取出存在本地的消息修改为已读 重新写入
    if ([[NSUserDefaults standardUserDefaults]objectForKey:_pushStr]) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:_pushStr];
        NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
        //把本地数据中相应未读的变为已读
        
        PushMsgModel * model = pushArr[IndexPath.row];
        model.isRead = YES;
        model.alarmTime = model.alarmTime;
        model.deviceName = model.deviceName;
        [pushArr replaceObjectAtIndex:IndexPath.row withObject:model];
        //        把操作过的排好序的数据源写入本地
        NSArray *DataArr = [NSArray arrayWithArray:pushArr];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:_pushStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
*/
    _editBtn.userInteractionEnabled = NO;
    _backButton.userInteractionEnabled = NO;
    _filterBtn.userInteractionEnabled = NO;
    CGFloat bili = (CGFloat)(70.000/105.000);
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    view.backgroundColor = [UIColor colorWithWhite:0.4f alpha:0.4f];
    
    view.userInteractionEnabled = YES;
    view.tag = 10;
    [self.view addSubview:view];
    [view addSubview:self.scanImg];
    [self.scanImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneWidth*bili));
    }];
    
    [self.scanImg addSubview:self.enlargeImageView];
    [self.enlargeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scanImg.mas_centerX);
        make.centerY.equalTo(self.scanImg.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneWidth*bili));
    }];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    imageView.image = cell.pictureImage.image;
    imageView.userInteractionEnabled = YES;
    [self.enlargeImageView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.enlargeImageView.mas_centerX);
        make.centerY.equalTo(self.enlargeImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneWidth*bili));
    }];

    UITapGestureRecognizer * deleteTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteImageV:)];
    [view addGestureRecognizer:deleteTap];
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.enlargeImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGRect frame = self.enlargeImageView.frame;
    
    frame.origin.y = (self.scanImg.frame.size.height - self.enlargeImageView.frame.size.height) > 0 ? (self.scanImg.frame.size.height - self.enlargeImageView.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scanImg.frame.size.width - self.enlargeImageView.frame.size.width) > 0 ? (self.scanImg.frame.size.width - self.enlargeImageView.frame.size.width) * 0.5 : 0;
    self.enlargeImageView.frame = frame;
    
    self.scanImg.contentSize = CGSizeMake(self.enlargeImageView.frame.size.width, self.enlargeImageView.frame.size.height);
}



#pragma mark - 删除放大图片
- (void)deleteImageV:(UITapGestureRecognizer *)deletetap{
    
    _editBtn.userInteractionEnabled = YES;
    _backButton.userInteractionEnabled = YES;
    _filterBtn.userInteractionEnabled = YES;
    UIView * view1 = [self.view viewWithTag:10];
    
    [view1 removeFromSuperview];
};


#pragma mark ----- 懒加载
-(NSMutableArray *)resultDateArr{
    if (!_resultDateArr) {
        _resultDateArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _resultDateArr;
}

//给数组分类别
-(void)arrayClassification:(NSMutableArray *)arr{
    NSMutableArray *tempArr;
    [self.resultDateArr removeAllObjects];
    [self.testArr removeAllObjects];
    for (int i = 0; i<arr.count; i++) {
        //根据已读未读显示红点
        PushMsgModel * model = arr[i];
        NSString * timeStr= [NSString stringWithFormat:@"%d",model.alarmTime];
        NSTimeInterval time=[timeStr doubleValue];//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        //实例化一个NSDateFormatter对象

        NSDateFormatter * timeDate = [[NSDateFormatter alloc]init];
        //设定时间格式,这里可以设置成自己需要的格式
        [timeDate setDateFormat:@"MM月dd"];
        NSString *currentDateStr = [timeDate stringFromDate: detaildate];
        
//        NSLog(@"currentDateStr:%@",currentDateStr);
        
        /**
         *  description: 当temp与当前循环元素相等且不为最后一次循环
         *  添加一个元素到同类别的已有的组别中
         */
        
        if (i != 0 && i != arr.count - 1) {
            
            if ([tempDate isEqualToString:currentDateStr]) {//arr[i]
                [tempArr addObject:arr[i]];
            } else {
                [self.resultDateArr addObject:tempArr];
                tempArr = [NSMutableArray array];
                tempDate = currentDateStr;//arr[i]
                [tempArr addObject:arr[i]];
            }
            
        } else {
            if (i == 0) {
                tempArr = [NSMutableArray array];
                tempDate = currentDateStr;//arr[i]
                [tempArr addObject:arr[i]];
                if (arr.count == 1) {
                    [self.resultDateArr addObject:tempArr];
                }
            } else if (i == arr.count-1) {
                if ([tempDate isEqualToString: currentDateStr]) {//arr[i]
                    [tempArr addObject:arr[i]];
                    [self.resultDateArr addObject:tempArr];
                } else {
                    [self.resultDateArr addObject:tempArr];
                    tempArr = [NSMutableArray array];
                    [tempArr addObject:arr[i]];
                    [self.resultDateArr addObject:tempArr];
                }
            }
        }
        
        
    }
//    NSLog(@"result:%@",_resultDateArr);
//    NSLog(@"_arrayM:%@",_arrayM);
    if (self.resultDateArr.count != 0) {
        [self.testArr addObject:self.resultDateArr[0]];
    }
    
    }

//时间提示信息懒加载
- (UILabel *)dateTipLb{
    if (!_dateTipLb) {
        _dateTipLb = [[UILabel alloc]init];
    }
    return _dateTipLb;
}




#pragma mark - 筛选模块
- (void)filterClick
{
    self.isPop = YES;
    [self.view addSubview:self.filerView];
    [UIView animateWithDuration:0.5 animations:^{
        self.filerView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } completion:^(BOOL finished) {
    }];
}
#pragma mark - 关闭筛选模块(该类调用)
- (void)closeFilerClick
{
    self.isPop = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UIView animateWithDuration:0.3 animations:^{
        self.filerView.frame = CGRectMake(0, iPhoneHeight, iPhoneWidth, iPhoneHeight);
    } completion:^(BOOL finished) {
        [self.filerView removeFromSuperview];
//        [self.myResultDeviceArr removeAllObjects];
//        dateRow = -1;
//        self.filerView = nil;
    }];
}

#pragma mark - 关闭筛选消息视图代理协议
- (void)closeFilerView
{
    self.isPop = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UIView animateWithDuration:0.3 animations:^{
        self.filerView.frame = CGRectMake(0, iPhoneHeight, iPhoneWidth, iPhoneHeight);
    } completion:^(BOOL finished) {
        [self.filerView removeFromSuperview];
//        [self.myResultDeviceArr removeAllObjects];
//        dateRow = -1;
//        self.filerView = nil;
    }];
}


#pragma mark - filerView中的TableView选择的代理方法
-(void)SelectSectionofRowAtIndex:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        FilerDeviceVC *filerDeviceVC = [[FilerDeviceVC alloc]init];
        filerDeviceVC.myResultDeviceArr = self.myResultDeviceArr;
        [self.navigationController pushViewController:filerDeviceVC animated:YES];
    }else{
//        NSLog(@"我选择了第%ld组第%ld行",(long)section,(long)row);
        dateRow = row;
    }
}
#pragma mark - 重置按钮的代理方法
- (void)resetAllinfoClick
{
    //重置设备名称
    [self.myResultDeviceArr removeAllObjects];
    dateRow = -1;
    [self.filerView resetDateandGetDeviceNameArr:self.myResultDeviceArr];
}

#pragma mark - 提交按钮的代理方法
- (void)submitFlierClick
{
    loadCount = 0;
    [BallLoading showBallInView:self.filerView andTip:@"数据加载中,请稍等..."];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [Toast dissmiss];
        [self closeFilerClick];//点击完成后等待一会儿关闭筛选view
    });
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownMethod)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
}

#pragma mark - 警告
- (void)createAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请选择查询某一特定时间" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:btnAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 弹出视图的懒加载
-(FilerView *)filerView
{
    if (!_filerView) {
        _filerView = [[FilerView alloc]initWithDateArr:[self formatterDateArr] frame:CGRectMake(0, iPhoneHeight-64, iPhoneWidth, iPhoneHeight)];
        _filerView.delegate = self;
    }
    return _filerView;
}

#pragma mark - 时间格式化
- (NSMutableArray *)formatterDateArr
{
    fdateArr = [NSMutableArray arrayWithCapacity:0];
    //当天时间归零方法(获取当天的零点零分)
    NSDate* now = [NSDate zeroOfDate];
 //    NSLog(@"现在时间：%@",now);
    //日期计算，返回当天的前某一天或者后某一天
    [fdateArr addObject:now];
    [fdateArr addObject:[NSDate offsetDay:-1 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-2 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-3 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-4 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-5 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-6 Date:now]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM月dd日"];
    NSDateFormatter* weekFormatter = [[NSDateFormatter alloc]init];
    [weekFormatter setDateFormat:@"yyyy-MM-dd"];

    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:0];

    for (int i = 0; i< fdateArr.count; i++) {
        NSDate *destDate = [weekFormatter dateFromString:[weekFormatter stringFromDate:fdateArr[i]]];
        //判断今天单独拎出来
        NSString *resultDate;
        if (i == 0) {
            resultDate = [NSString stringWithFormat:@"%@ %@",@"今天",[self weekStringFromDate:destDate] ];
        }else{
            resultDate = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:fdateArr[i]],[self weekStringFromDate:destDate]];
        }
        
        [resultArr addObject:resultDate];
    }
    
    return resultArr;
}

#pragma mark - 时间转换星期
- (NSString *)weekStringFromDate:(NSDate *)date
{
    NSArray *weeks = @[[NSNull null],@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    NSCalendar* calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone* timeZone = [[NSTimeZone alloc]initWithName:@"Asia/Beijing"];
    [calendar setTimeZone:timeZone];
    NSCalendarUnit calendarUnit =NSCalendarUnitWeekday;
    NSDateComponents* components = [calendar components:calendarUnit fromDate:date];
    return[weeks objectAtIndex:components.weekday];
}


/**
 字典数组取出某个key再组成一个数组
 
 @param dicArr 字典数组
 @param key 要取出组成数组的key
 @return 返回该key组成的数组
 */
- (NSMutableArray *)getKeyArray:(NSMutableArray *)dicArr byOneKey:(NSString *)key
{
    NSMutableArray *keyArr =[NSMutableArray arrayWithCapacity:0];
    for(NSDictionary *dic in dicArr){
        [keyArr addObject:dic[key]];
    }
    return keyArr;
}



- (void)FilterAlarmMessageFromServerID:(NSString *)ID andDate:(NSDate *)date
{
    /*
     * description : GET v1/alarm/list(按条件筛选告警信息)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & start_time=<开始时间> & stop_time=<结束时间> & offset= <偏移量> & limit<记录数>
     ps：
         dev_id:如果为空表示获取用户账号下所有设备的告警,多个设备用分号分隔
         start_time: 1970开始的秒数
         stop_time: 1970开始的秒数
         offset: 开始记录的偏移量
         limit: 一次获取的记录条数
     */
    //时间
    NSDate * endDate = [NSDate dateWithTimeInterval:24*60*60-1 sinceDate:date];//当天晚上23.59
    //时区要减8个小时
    NSString *startTime = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]-8*60*60];
    NSString *stopTime = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970]-8*60*60];

    NSLog(@"ID:%@",ID);
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:ID forKey:@"dev_id"];
    [dic setObject:stopTime forKey:@"stop_time"];
    [dic setObject:startTime forKey:@"start_time"];
    [dic setObject:@"0" forKey:@"offset"];
    [dic setObject:@"500" forKey:@"limit"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/list" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        
//        [self closeFilerClick];//查询成功后关闭筛选
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            NSLog(@"从服务器主动查询推送过来的报警信息responseObject:%@",responseObject);
            NSMutableArray * tempArr = responseObject[@"body"][@"alarmList"];
            _arrayM = [[NSMutableArray alloc]init];
            for (int i = 0; i < tempArr.count; i++) {
                PushMsgModel *pushModel = [[PushMsgModel alloc]init];
                pushModel.alarmId = tempArr[i][@"alarmId"];
                pushModel.alarmPic = tempArr[i][@"alarmPic"];
                pushModel.deviceId = tempArr[i][@"deviceId"];
                pushModel.deviceName = tempArr[i][@"deviceName"];
                pushModel.alarmTime = [tempArr[i][@"alarmTime"]intValue];
                pushModel.markread = [tempArr[i][@"markread"]boolValue];//NO
                [_arrayM addObject:pushModel];
            }
            //NSLog(@"个数：%@",_arrayM);
            //得到按时间分组后的结果数组self.resultArr
            [self arrayClassification:_arrayM];

            if (_arrayM.count == 0) {
                [self.view addSubview:self.bgView];
            }else{
                [self.backView removeFromSuperview];
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }else{
            [self.view addSubview:self.bgView];
//            NSLog(@"从服务器主动查询推送过来的报警信息【失败】:%@",responseObject);
            [self.tableView.mj_header endRefreshing];
        }
        [BallLoading hideBallInView:self.filerView];
    }failure:^(NSError * _Nonnull error) {
//        [self closeFilerClick];//查询失败也需关闭筛选
        [BallLoading hideBallInView:self.filerView];
        [self.view addSubview:self.bgView];
        NSLog(@"从服务器主动查询推送过来的报警信息【失败~~】");
        [self.tableView.mj_header endRefreshing];
    }];
}


- (void)FilterAlarmMessageFromServerID:(NSString *)ID
{
    /*
     * description : GET v1/alarm/list(按条件筛选告警信息)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & start_time=<开始时间> & stop_time=<结束时间> & offset= <偏移量> & limit<记录数>
     ps：
     dev_id:如果为空表示获取用户账号下所有设备的告警,多个设备用分号分隔
     start_time: 1970开始的秒数
     stop_time: 1970开始的秒数
     offset: 开始记录的偏移量
     limit: 一次获取的记录条数
     */
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:ID forKey:@"dev_id"];
    [dic setObject:@"0" forKey:@"offset"];
    [dic setObject:@"500" forKey:@"limit"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/list" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"FilterAlarmMessageFromServerID===responseObject:%@",responseObject);
//        [self closeFilerClick];//查询成功后关闭筛选
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            NSLog(@"从服务器主动查询推送过来的报警信息responseObject:%@",responseObject);
            NSMutableArray * tempArr = responseObject[@"body"][@"alarmList"];
            _arrayM = [[NSMutableArray alloc]init];
            for (int i = 0; i < tempArr.count; i++) {
                PushMsgModel *pushModel = [[PushMsgModel alloc]init];
                pushModel.alarmId = tempArr[i][@"alarmId"];
                pushModel.alarmPic = tempArr[i][@"alarmPic"];
                pushModel.deviceId = tempArr[i][@"deviceId"];
                pushModel.deviceName = tempArr[i][@"deviceName"];
                pushModel.alarmTime = [tempArr[i][@"alarmTime"]intValue];
                pushModel.markread = [tempArr[i][@"markread"]boolValue];//NO
                [_arrayM addObject:pushModel];
            }
            //NSLog(@"个数：%@",_arrayM);
            //得到按时间分组后的结果数组self.resultArr
            [self arrayClassification:_arrayM];
            
            if (_arrayM.count == 0) {
                [self.view addSubview:self.bgView];
            }else{
                [self.backView removeFromSuperview];
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }else{
            [self.view addSubview:self.bgView];
            //            NSLog(@"从服务器主动查询推送过来的报警信息【失败】:%@",responseObject);
            [self.tableView.mj_header endRefreshing];
        }
        [BallLoading hideBallInView:self.filerView];
    }failure:^(NSError * _Nonnull error) {
//        [self closeFilerClick];//查询失败也需关闭筛选
        [BallLoading hideBallInView:self.filerView];
        [self.view addSubview:self.bgView];
        NSLog(@"从服务器主动查询推送过来的报警信息【失败~~】");
        [self.tableView.mj_header endRefreshing];
    }];
    
}


//无内容时的背景图
-(EmptyDataBGView *)bgView{
    if (!_bgView) {
        _bgView = [[EmptyDataBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-64) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"noContent"] bgTip:@"暂无相关信息"];
    }
    return _bgView;
}

-(NSMutableArray *)testArr
{
    if (!_testArr) {
        _testArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _testArr;
}

- (ProgressBarView *)progressView
{
    if (!_progressView) {
        _progressView = [[ProgressBarView alloc]initWithFrame:self.view.bounds];
    }
    return _progressView;
}

- (UIScrollView *)scanImg
{
    if (!_scanImg) {
        _scanImg = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _scanImg.minimumZoomScale = 1.f;
        _scanImg.maximumZoomScale = 10.f;
        _scanImg.showsHorizontalScrollIndicator = NO;
        _scanImg.showsVerticalScrollIndicator = NO;
        _scanImg.delegate = self;
    }
    return _scanImg;
}

- (UIView *)enlargeImageView
{
    if (!_enlargeImageView) {
        _enlargeImageView = [[UIView alloc]initWithFrame:CGRectZero];
        _enlargeImageView.backgroundColor = [UIColor clearColor];
    }
    return _enlargeImageView;
}


@end
