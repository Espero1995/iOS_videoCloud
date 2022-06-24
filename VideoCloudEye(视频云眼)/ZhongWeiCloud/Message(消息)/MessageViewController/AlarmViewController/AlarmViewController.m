//
//  AlarmViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/16.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "AlarmViewController.h"
#import "AlarmCell_t.h"
#import "ZCTabBarController.h"
#import "PushMsgModel.h"
#import "InvestigateViewController.h"
#import "PlayBackViewController.h"
#import "YALSunnyRefreshControl.h"
#import "WeiCloudListModel.h"

@interface AlarmViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    AlarmCell_tDelegete
>
{   //数据源
    NSMutableArray * _array;
    //本地数据
    NSMutableArray * _arrayM;
    //记录删除数据
    NSMutableArray * _deleteArray;
    //编辑按钮
    UIButton * _editButton;
    //返回按钮
    UIButton * _backButton;
    //全选按钮
    UIButton * _allChoose;
    //删除按钮
    UIButton * _deleteBtn;
    //全部已读按钮
    UIButton * _readBtn;
    //记录tableView的编辑状态
    BOOL _editing;
    
}
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) UILabel * deleteLabel;
//未操作的数据源
@property (nonatomic,strong) NSMutableArray *weiDataArr;
@property (nonatomic,strong) NSMutableArray * btnArr;
@property (nonatomic,strong) NSString * pushStr;
//刷新控件
@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;

@property (nonatomic,strong) UIView * backView;

@property (nonatomic,strong) NSMutableArray * tempVideoListInfoArr;

@end

@implementation AlarmViewController

//----------------------------------------system----------------------------------------



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"事件列表";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    //生成假数据
    //    [self creatJiaData];
    //生成数据源
    [self createData];
    //创建导航栏按钮
    [self setButtonitem];
    //创建tableview
    [self createTableView];
    [self getVideoListData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    [self.tableView.mj_header beginRefreshing];
}

//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    //    [self.videoManage stopCloudPlay];
//    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
//    tabVC.tabHidden = NO;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------init----------------------------------------
#pragma mark-------创建tableview并设置分区和高度
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    
    [self.view addSubview:self.tableView];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(createData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
    //    //下拉刷新
    //    [self setupRefreshControl];
}

#pragma mark ------没有告警信息时显示
//没有告警信息时显示
-(void)createBackImage{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    _backView.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4"];
    [self.tableView addSubview:_backView];
    UIImageView * backImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 78.5)];
    backImage.image = [UIImage imageNamed:@"noContent"];
    backImage.center = _backView.center;
    [_backView addSubview:backImage];
    UILabel * backLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    backLabel.text = @"暂无相关信息";
    backLabel.textColor = [UIColor colorWithHexString:@"9d9d9d"];
    [_backView addSubview:backLabel];
    [backLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backImage.mas_bottom).offset(14);
        make.left.equalTo(backImage.mas_left).offset(0);
    }];
    
}

- (JW_CIPHER_CTX)cipher
{
    if (_cipher == nil) {
        if (self.key && self.bIsEncrypt) {
            size_t len = strlen([self.key cStringUsingEncoding:NSASCIIStringEncoding]);
            _cipher =  jw_cipher_create((const unsigned char*)[self.key cStringUsingEncoding:NSASCIIStringEncoding], len);
            NSLog(@"报警界面创建cipher：%p",&_cipher);
        }
    }
    return _cipher;
}

- (NSMutableArray *)weiDataArr
{
    if (!_weiDataArr) {
        _weiDataArr = [NSMutableArray array];
    }
    return _weiDataArr;
}

//----------------------------------------method----------------------------------------
- (void)getVideoListData
{
    /*
     NSData *data =  [[NSUserDefaults standardUserDefaults]objectForKey:VIDEOLISTMODEL];
     self.tempVideoListInfoArr = [NSMutableArray arrayWithCapacity:0];
     self.tempVideoListInfoArr   =  [NSKeyedUnarchiver unarchiveObjectWithData:data];//WeiCloudListModel
     NSLog(@"self.tempVideoListInfoArr:%@",self.tempVideoListInfoArr);
     */
    //注释：这里单独写了工具，上面先留着，测试通过，统一删除。
    self.tempVideoListInfoArr = [NSMutableArray arrayWithCapacity:0];
    self.tempVideoListInfoArr = (NSMutableArray *)[unitl getCameraModel];
    NSLog(@"self.tempVideoListInfoArr:%@",self.tempVideoListInfoArr);
}

#pragma mark ------生成数据
//假数据
- (void)creatJiaData
{
    NSArray * titleArray = @[@"NO.001的报警信息",@"紧急设备警报信息",@"紧急信息告警",@"004信息告警恢复",@"信息恢复报警",@"异常信息警告",@"测试信息",@"测试信息",@"测试信息",@"测试信息",@"测试信息",@"测试信息",@"测试信息",@"测试信息",@"测试信息",@"测试信息",@"测试信息"];
    for (int i = 0; i<17;i++ ) {
        PushMsgModel *pushModel = [[PushMsgModel alloc]init];
        pushModel.markread = NO;
        pushModel.alarmTime = 1485878400+i*86400;
        pushModel.deviceName = titleArray[i];
        [self.weiDataArr addObject:pushModel];
        NSString * btnStr = [NSString stringWithFormat:@"no"];
        [self.btnArr addObject:btnStr];
    }
    NSArray *DataArr = [NSArray arrayWithArray:self.weiDataArr];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:PUSH];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//数据源
- (void)createData{
    self.btnArr = [NSMutableArray array];
    _timeString = [NSString string];
    _deleteArray = [NSMutableArray array];
    _arrayM = [[NSMutableArray alloc]init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UserID = [defaults objectForKey:@"user_id_push"];
    _pushStr = [NSString stringWithString:UserID];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:_pushStr]) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:_pushStr];
        NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
        //数据源换成操作后的数据
        _arrayM = [NSMutableArray arrayWithArray:pushArr];
        for (int i = 0; i<_arrayM.count; i++) {
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr addObject:btnStr];
        }
        //把操作过的排好序的数据源写入本地
        NSArray *DataArr = [NSArray arrayWithArray:pushArr];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:_pushStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }else{
        [self.tableView.mj_header endRefreshing];
    }
    if (_arrayM.count == 0) {
        [self createBackImage];
    }else{
        [self.backView removeFromSuperview];
    }
}


#pragma mark ------编辑按钮和相应事件
//编辑按钮（未编辑状态）
- (void)setButtonitem{
    
    _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 14)];
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(editCell) forControlEvents:UIControlEventTouchUpInside];
    _editButton.highlighted = YES;
    _editButton.userInteractionEnabled = YES;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editButton];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -13;
    self.navigationItem.rightBarButtonItems = @[rightSpace,rightItem];
    
    [self cteateNavBtn];
}


//编辑按钮
- (void)editCell{
    
   
    
    if (_arrayM.count!=0) {
        _editing = YES;
        _tableView.allowsMultipleSelection = YES;
        [self createDeleteButton];
        [self createNavButton];
        if (_editButton.selected == NO) {
            _editButton.selected = YES;
        }else{
        }
        [_tableView reloadData];
    }else{
        [XHToast showCenterWithText:@"再无内容可编辑~"];
    }
}
#pragma mark ------取消和全选按钮
//创建取消，全选按钮（编辑状态）
- (void)createNavButton{
    
    _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 14)];
    [_editButton setTitle:@"取消" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    _editButton.userInteractionEnabled = YES;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editButton];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = 8;
    self.navigationItem.rightBarButtonItems = @[rightSpace,rightItem];
    
    _allChoose = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 14)];
    [_allChoose setTitle:@"全选" forState:UIControlStateNormal];
    [_allChoose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_allChoose addTarget:self action:@selector(chooseAllCell) forControlEvents:UIControlEventTouchUpInside];
    _allChoose.highlighted = YES;
    _allChoose.userInteractionEnabled = YES;
    _allChoose.selected = NO;
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:_allChoose];
    UIBarButtonItem * leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    leftItem.width = 13;
    self.navigationItem.leftBarButtonItems = @[leftSpace,leftItem];
}

//全选cell
- (void)chooseAllCell{
    [_deleteBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];//[UIColor whiteColor]
    if (_allChoose.selected == NO) {
        _allChoose.selected = YES;
        [_deleteArray removeAllObjects];
        for (int i = 0; i<_arrayM.count; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
            [_deleteArray addObjectsFromArray:_arrayM];
        }
    }else
    {
        for (int i = 0; i<_arrayM.count; i++) {
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
        }

        _allChoose.selected = NO;
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
    [_deleteArray removeAllObjects];
    _editButton.selected = NO;
    
    [_tableView reloadData];
    //编辑按钮
    [self setButtonitem];
    
    [_deleteLabel removeFromSuperview];
    [_deleteBtn removeFromSuperview];
    [_readBtn removeFromSuperview];
}
#pragma mark ------删除和已读按钮的创建和响应事件
//创建删除按钮
- (void)createDeleteButton
{
    _deleteLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 40)];
    _deleteLabel.backgroundColor = [UIColor colorWithHexString:@"#f4f3f3"];
    [self.tableView addSubview:_deleteLabel];
    [self.view bringSubviewToFront:_deleteLabel];
    [_deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
    }];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(0, 0, 40, 15);
    
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    if (_deleteArray.count == 0) {
        [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    _deleteBtn.userInteractionEnabled = YES;
    [_deleteBtn addTarget:self action:@selector(deleteCell) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_deleteLabel.mas_left).offset(13);
        make.top.equalTo(_deleteLabel.mas_top).offset(12.5);
        make.right.equalTo(_deleteLabel.mas_left).offset(53);
        make.bottom.equalTo(_deleteLabel.mas_bottom).offset(-12.5);
    }];
    [self.view bringSubviewToFront:_deleteBtn];
    
    _readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _readBtn.frame = CGRectMake(0, 0, 75, 15);
    [_readBtn setTitle:@"全部已读" forState:UIControlStateNormal];
    [_readBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    _readBtn.userInteractionEnabled = YES;
    [_readBtn addTarget:self action:@selector(ignoreMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_readBtn];
    [_readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_deleteLabel.mas_top).offset(12.5);
        make.right.equalTo(_deleteLabel.mas_right).offset(-13);
        make.bottom.equalTo(_deleteLabel.mas_bottom).offset(-12.5);
        make.left.equalTo(_deleteLabel.mas_right).offset(-88);
    }];
}

//删除cell
- (void)deleteCell
{
    [_arrayM removeObjectsInArray:_deleteArray];
    [self.tableView reloadData];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:_pushStr]) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:_pushStr];
        NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
        //  删除数据
        pushArr = [NSMutableArray arrayWithArray:_arrayM];
        //        把操作过的排好序的数据源写入本地
        NSArray *DataArr = [NSArray arrayWithArray:pushArr];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:_pushStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [_deleteArray removeAllObjects];
    [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    if (_arrayM.count == 0) {
        [self createBackImage];
    }
    [self cancelEdit];
    NSLog(@"删除");
}

//返回上一页
- (void)returnVC{
    [self.navigationController popViewControllerAnimated:YES];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

//消息已读
- (void)ignoreMessage{
    
    for (int i = 0; i<_arrayM.count; i++) {
//        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        PushMsgModel * model = _arrayM[i];
        if (model.markread == NO) {
            model.markread = YES;
        }
    }
        //取出存在本地的消息修改为已读 重新写入
        if ([[NSUserDefaults standardUserDefaults]objectForKey:_pushStr]) {
            NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:_pushStr];
            NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
            NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
            //把本地数据中相应未读的变为已读
            for (int j =0; j<pushArr.count; j++) {
                PushMsgModel * model = pushArr[j];
                model.markread = YES;
                model.alarmTime = model.alarmTime;
                model.deviceName = model.deviceName;
                [pushArr replaceObjectAtIndex:j withObject:model];
            }
            //        把操作过的排好序的数据源写入本地
            NSArray *DataArr = [NSArray arrayWithArray:pushArr];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
            [[NSUserDefaults standardUserDefaults]setObject:data forKey:_pushStr];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    [self.tableView reloadData];
}



#pragma mark ------ 刷新
//下拉刷新
-(void)setupRefreshControl{
    self.sunnyRefreshControl = [YALSunnyRefreshControl attachToScrollView:self.tableView
                                                                   target:self
                                                            refreshAction:@selector(sunnyControlDidStartAnimation)];
}

-(void)sunnyControlDidStartAnimation{
    [self performSelector:@selector(createData) withObject:nil afterDelay:2];
}

//结束下拉刷新
-(IBAction)endAnimationHandle{
    [self.sunnyRefreshControl endRefreshing];
}
//上拉刷新响应
- (void)loadMoreData
{
    [self performSelector:@selector(endUpRefresh) withObject:nil afterDelay:2];
}
- (void)endUpRefresh
{
    [self.tableView.mj_footer endRefreshing];
}


//----------------------------------------delegate----------------------------------------
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 105;
}
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayM.count;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"MyCell";
    AlarmCell_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        
        cell = [[AlarmCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.delegete = self;
    cell.detaSore = self;
    
    //根据已读未读显示红点
    PushMsgModel * model = _arrayM[indexPath.row];
    NSString * timeStr= [NSString stringWithFormat:@"%d",model.alarmTime];
    NSTimeInterval time=[timeStr doubleValue];//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    NSLog(@"date:%@",[detaildate description]);
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter * timeDate = [[NSDateFormatter alloc]init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [timeDate setDateFormat:@"yyyy-MM--dd"];
    _timeString = [timeDate stringFromDate:detaildate];
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    cell.timeLabel.text = currentDateStr;
    if (model.markread == NO) {
        cell.attentionView.alpha = 1;
    }else{
        cell.attentionView.alpha = 0;
    }
    cell.typeLabel.text = [NSString stringWithFormat:@"%@发生警报",model.deviceName];
    cell.messageLabel.text = [NSString stringWithFormat:@"%@发生移动报警",model.deviceName];
    NSString *imaStr = [NSString isNullToString:model.alarmPic ];
    NSURL *imaUrl = [NSURL URLWithString:imaStr];
    /*
    [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img1"]];
*/
    NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
    tempArr = [self.tempVideoListInfoArr copy];
    
    // NSLog(@"sssssst:%@==%@==%@",str111,str222,model.deviceId);
    
    for (int i = 0; i<tempArr.count; i++) {
        if ([((dev_list*)(tempArr[i])).ID isEqualToString:model.deviceId]) {
            self.key = ((dev_list*)(tempArr[i])).dev_p_code;
            self.bIsEncrypt = ((dev_list*)(tempArr[i])).enable_sec;
        }
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:imaUrl];
    __block UIImage * image;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {//[[NSOperationQueue alloc] init]   [NSOperationQueue mainQueue]
        
        NSLog(@"报警界面收到图片的data：%@---长度：%zd",response,data.length);
        
        const unsigned char *imageCharData=(const unsigned char*)[data bytes];
        size_t len = [data length];
        
        unsigned char outImageCharData[len];
        size_t outLen = len;
        
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
                        [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img1"]];
                    });
                }
            }else{
                dispatch_async(dispatch_get_main_queue(),^{
                    [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img1"]];
                   // cell.pictureImage.image = [UIImage imageNamed:@"img1"];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(),^{
                [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img1"]];
            });
        }
    }];


    
    if (_editButton.selected == YES) {
        cell.chooseBtn.alpha = 1;
        cell.chooseBtn.enabled = YES;
        cell.chooseBtn.userInteractionEnabled = YES;
        if (_allChoose.selected == YES ) {
            cell.chooseBtn.selected = YES;
            
            
        }else
        {
            cell.chooseBtn.selected = NO;
            
        }
        if ([self.btnArr[indexPath.row] isEqualToString:@"yes"]) {
            cell.chooseBtn.selected = YES;
        }else{
            cell.chooseBtn.selected = NO;
        }
        
    }else{
        
        cell.chooseBtn.alpha = 0;
        cell.chooseBtn.enabled = NO;
        cell.chooseBtn.userInteractionEnabled = NO;
        
    }
    cell.model = model;
    
    return cell;
}


#pragma mark------ 点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_editing == YES) {
        [_deleteBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];

        if ([self.btnArr[indexPath.row] isEqualToString:@"no"]) {
            
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:indexPath.row withObject:btnStr];
            
            [_deleteArray addObject:[_arrayM objectAtIndex:indexPath.row]];
            
            [self.tableView reloadData];
        }else{
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:indexPath.row withObject:btnStr];
            [_deleteArray removeObject:[_arrayM objectAtIndex:indexPath.row]];
            [self.tableView reloadData];
            NSLog(@"取消");
            
        }
    }else if (_editing == NO){
        PushMsgModel * model = _arrayM[indexPath.row];
        if (model.markread == NO) {
            model.markread = YES;
        }
        AlarmCell_t *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.attentionView.alpha = 0;
        //取出存在本地的消息修改为已读 重新写入
        if ([[NSUserDefaults standardUserDefaults]objectForKey:_pushStr]) {
            NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:_pushStr];
            NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
            NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
            //把本地数据中相应未读的变为已读
            PushMsgModel * model = pushArr[indexPath.row];
            model.markread = YES;
            model.alarmTime = model.alarmTime;
            model.deviceName = model.deviceName;
            [pushArr replaceObjectAtIndex:indexPath.row withObject:model];
            //把操作过的排好序的数据源写入本地
            NSArray *DataArr = [NSArray arrayWithArray:pushArr];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
            [[NSUserDefaults standardUserDefaults]setObject:data forKey:_pushStr];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (_editing == YES) {
                return;
            }
        }
        PlayBackViewController *playVc = [[PlayBackViewController alloc]init];
        playVc.pushMsgModel = model;
        playVc.isWarning = YES;
        playVc.timeStr = [NSString stringWithString:_timeString];
        [self.navigationController pushViewController:playVc animated:YES];
        
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
//选择要删除的CELL
- (void)AlarmCell_tChooseBtnClick:(AlarmCell_t *)cell
{
    //    [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"38adff"] forState:UIControlStateNormal];
    //    if (cell.chooseBtn.selected == NO) {
    //        cell.chooseBtn.selected = YES;
    //        NSIndexPath *selectIndexPath = [self.tableView indexPathForCell:cell];
    //
    //        [_deleteArray addObject:[_arrayM objectAtIndex:selectIndexPath.row]];
    //    }
    //    else{
    //        cell.chooseBtn.selected = NO;
    //        NSIndexPath *selectIndexPath = [self.tableView indexPathForCell:cell];
    //        [_deleteArray removeObject:[_arrayM objectAtIndex:selectIndexPath.row]];
    //    }
}
//cell上图片点击事件（放大图片）
- (void)Alarmcell_tPictureImageClick:(AlarmCell_t *)cell

{    //获取到图片所在的cell未读变已读红点消失
    
    NSIndexPath *IndexPath = [self.tableView indexPathForCell:cell];
    PushMsgModel * model = _arrayM[IndexPath.row];
    if (model.markread == NO) {
        model.markread = YES;
        cell.attentionView.alpha = 0;
    }
    
    [self.tableView reloadData];
    
    //    取出存在本地的消息修改为已读 重新写入
    if ([[NSUserDefaults standardUserDefaults]objectForKey:_pushStr]) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:_pushStr];
        NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
        //        把本地数据中相应未读的变为已读
        
        PushMsgModel * model = pushArr[IndexPath.row];
        model.markread = YES;
        model.alarmTime = model.alarmTime;
        model.deviceName = model.deviceName;
        [pushArr replaceObjectAtIndex:IndexPath.row withObject:model];
        //        把操作过的排好序的数据源写入本地
        NSArray *DataArr = [NSArray arrayWithArray:pushArr];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:_pushStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _editButton.userInteractionEnabled = NO;
    _backButton.userInteractionEnabled = NO;
    CGFloat bili = (CGFloat)(68.000/105.000);
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    view.backgroundColor = [UIColor colorWithWhite:0.3f alpha:0.35f];
    
    view.userInteractionEnabled = YES;
    view.tag = 10;
    [self.view addSubview:view];
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 200, self.view.width,iPhoneWidth*bili)];
    
    imageView.image = cell.pictureImage.image;
    imageView.userInteractionEnabled = YES;
    [view addSubview:imageView];
    UITapGestureRecognizer * deleteTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteImageV:)];
    [view addGestureRecognizer:deleteTap];
    
}

//-(NSDictionary *)judgeNeedDecodeImage:(NSString *)deviceId
//{
//    if (deviceId) {
//        NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
//        tempArr = [self.tempVideoListInfoArr copy];
//        [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
////            if () {
////                <#statements#>
////            }
//
//        }];
//    }
//}

//删除放大图片
- (void)deleteImageV:(UITapGestureRecognizer *)deletetap{
    
    _editButton.userInteractionEnabled = YES;
    _backButton.userInteractionEnabled = YES;
    
    UIView * view1 = [self.view viewWithTag:10];
    
    [view1 removeFromSuperview];
};

@end
