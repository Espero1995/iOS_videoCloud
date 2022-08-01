//
//  AlarmMsgVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/8.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "AlarmMsgVC.h"

//========Model========
#import "NSDate+calculate.h"
#import "PushMsgModel.h"
#import "WeiCloudListModel.h"
#import "NSDate+calculate.h"
//========View========
#import "AlarmNewCell.h"
/*放大图片*/
#import "EnlargeimageView.h"
/*删除时的进度条*/
#import "ProgressBarView.h"
/*筛选View*/
#import "FilerView.h"
/*等待框*/
#import "BallLoading.h"
//========VC========
/*工具栏*/
#import "ZCTabBarController.h"
/*选择设备VC*/
#import "FilerDeviceVC.h"
/*录像回放VC*/
#import "OnlyPlayBackVC.h"
/*短视频VC*/
#import "AVPlayerVC.h"
#define PAGESIZE 200

@interface AlarmMsgVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    AlarmCell_tDelegete,
    FilerViewDelegate
>
{
    /*编辑按钮*/
    UIButton *_editBtn;
    /*筛选按钮*/
    UIButton *_filterBtn;
    /*页数*/
    NSInteger pageNum;
    /*临时数组*/
    NSMutableArray *tempArr;
    /*区别是否是同一天*/
    NSString *tempDate;
    /*记录tableView的编辑状态*/
    BOOL isEditable;
    /*记录删除数据*/
    NSMutableArray *_deleteArr;

    /*记录是选择了哪一个时间点*/
    NSInteger dateRow;
    /*存储显示的七天时间*/
    NSMutableArray *fdateArr;

    //记录当前选中的是哪一组，哪一行
    NSInteger _selectSection;
    NSInteger _selectRow;
}
@property (nonatomic, assign) BOOL bIsEncrypt;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) JW_CIPHER_CTX cipher;//解码器
@property (nonatomic, strong) UITableView *tv_list;
@property (nonatomic, strong) NSMutableArray *alarmArr;//告警消息列表
@property (nonatomic, strong) NSMutableArray *resultDateArr;//根据日期分类后的告警消息数组
@property (nonatomic, strong) EnlargeimageView *enlarge;//放大图片View
@property (nonatomic, strong) UIView *bottomEditView;//底部编辑操作的View
@property (nonatomic, strong) UIButton *allChooseBtn;//全选按钮
@property (nonatomic, strong) UIButton *deleteBtn;//删除按钮
@property (nonatomic, strong) UIButton *markReadBtn;//标记已读按钮
@property (nonatomic, strong) NSMutableArray *btnArr;//所有告警消息有没有被选中
@property (nonatomic, strong) ProgressBarView *progressView;//进度条View
@property (nonatomic, assign) BOOL isPop;//是否已经弹出,默认为NO
@property (nonatomic, strong) FilerView *filerView;//筛选View

@end

@implementation AlarmMsgVC
//==========================System==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"事件中心", nil);
    tempArr = [NSMutableArray arrayWithCapacity:0];
    _deleteArr = [NSMutableArray arrayWithCapacity:0];
    tempDate = @"tempDate";
    self.isPop = NO;//默认关闭弹出视图
    dateRow = -1;//默认 -1（0~6）
    _selectSection = -1;
    _selectRow = -1;
    [self setUpUI];//整个界面的布局
    [self setNavBtn];//设置导航栏上的按钮
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    //展示选择的设备名字
    [self.filerView getDeviceNameArr:[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceName"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //存储最新的pushmodel
    NSString *userID = [unitl get_User_id];
    NSString *tempStrKey = [unitl getKeyWithSuffix:userID Key:@"user_id_push"];

    if (self.alarmArr.count == 0) {
        [unitl clearDataWithKey:tempStrKey];
    } else {
        PushMsgModel *newPushModel = self.alarmArr[0];
        [unitl saveNeedArchiverDataWithKey:tempStrKey Data:newPushModel];
    }
}

//返回上一页
- (void)returnVC {
    [self.navigationController popViewControllerAnimated:YES];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

//==========================init==========================
//整个界面的布局
- (void)setUpUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = RGB(245, 245, 245);
    [self.view addSubview:self.tv_list];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownMethod)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
    //上拉加载
    self.tv_list.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//设置导航栏上的按钮
- (void)setNavBtn
{
    //编辑按钮
    _editBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_editBtn setTitle:NSLocalizedString(@"编辑", nil) forState:UIControlStateNormal];
    _editBtn.titleLabel.font = FONT(16);
    [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(editClick) forControlEvents:UIControlEventTouchUpInside];
    _editBtn.userInteractionEnabled = YES;
    _editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *editRightItem = [[UIBarButtonItem alloc]initWithCustomView:_editBtn];

    _filterBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_filterBtn setTitle:NSLocalizedString(@"筛选", nil) forState:UIControlStateNormal];
    _filterBtn.titleLabel.font = FONT(16);
    [_filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_filterBtn addTarget:self action:@selector(filterClick) forControlEvents:UIControlEventTouchUpInside];
    _filterBtn.userInteractionEnabled = YES;
    _filterBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *filterRightItem = [[UIBarButtonItem alloc]initWithCustomView:_filterBtn];
    self.navigationItem.rightBarButtonItems = @[editRightItem, filterRightItem];

    [self cteateNavBtn];
}

//重设置导航栏按钮
- (void)resetNavBtn
{
    //取消按钮
    _editBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_editBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    _editBtn.titleLabel.font = FONT(16);
    [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    _editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    UIButton *btn = [[UIButton alloc]init];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItems = @[leftItem];
}

//增加底部的编辑框
- (void)setEditBottomView
{
    self.tv_list.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight - 50);
    [self.view addSubview:self.bottomEditView];
    [self.bottomEditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(@50);
    }];
    [self.allChooseBtn setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    self.allChooseBtn.selected = NO;
    [self.bottomEditView addSubview:self.allChooseBtn];
    [self.allChooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomEditView.mas_centerY);
        make.left.equalTo(self.bottomEditView.mas_left).offset(10);
    }];
    [self.bottomEditView addSubview:self.markReadBtn];
    [self.markReadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomEditView.mas_centerY);
        make.right.equalTo(self.bottomEditView.mas_right).offset(-10);
    }];
    [self.deleteBtn setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.bottomEditView addSubview:self.deleteBtn];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bottomEditView.mas_centerX);
        make.centerY.equalTo(self.bottomEditView.mas_centerY);
    }];
}

//移除底部的编辑框
- (void)removeEditBottomView
{
    self.tv_list.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
    [self.bottomEditView removeFromSuperview];
}

//==========================method==========================
//下拉刷新
- (void)pullDownMethod
{
    pageNum = 0;
    NSString *resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
    NSLog(@"resultID:%@", resultID);

    if (dateRow == -1 && self.myResultDeviceArr.count == 0) {
        if (self.homeDevID) {
            [self FilterAlarmMessageFromServerID:self.homeDevID];
        } else {
            [self queryAlarmMessageFromServer];
        }
    } else {//dateRow == -1 && self.myResultDeviceArr.count != 0
        if (dateRow == -1) {
            NSString *resultID;
            if (self.myResultDeviceArr.count == 0) {
                resultID = @"";
            } else {
                resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
            }
            [self FilterAlarmMessageFromServerID:resultID];
        } else {
            NSString *resultID;
            if (self.myResultDeviceArr.count == 0) {
                resultID = @"";
            } else {
                resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
            }
            [self FilterAlarmMessageFromServerID:resultID andDate:fdateArr[dateRow]];
        }
    }
}

//上拉加载
- (void)loadMoreData
{
    pageNum++;
//    NSString* resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
//    NSLog(@"resultID:%@",resultID);
    if (dateRow == -1 && self.myResultDeviceArr.count == 0) {
        [self queryAlarmMessageFromServer];
    } else {//dateRow == -1 && self.myResultDeviceArr.count != 0
        if (dateRow == -1) {
            NSString *resultID;
            if (self.myResultDeviceArr.count == 0) {
                resultID = @"";
            } else {
                resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
            }
            [self FilterAlarmMessageFromServerID:resultID];
        } else {
            NSString *resultID;
            if (self.myResultDeviceArr.count == 0) {
                resultID = @"";
            } else {
                resultID = [[self getKeyArray:self.myResultDeviceArr byOneKey:@"deviceID"] componentsJoinedByString:@";"];
            }
            [self FilterAlarmMessageFromServerID:resultID andDate:fdateArr[dateRow]];
        }
    }
}

#pragma mark - 从服务器主动查询推送过来的报警消息
- (void)queryAlarmMessageFromServer
{
    /*
     * description : GET v1/alarm/list(查询告警消息)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & start_time=<开始时间> & stop_time=<结束时间> & offset= <页数> & limit<每页条数>
     */
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate *date = [NSDate date]; //当前时间
    NSDate *lastDay = [NSDate zeroOfDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *startTime = [NSString stringWithFormat:@"%ld", (long)[lastDay timeIntervalSince1970] - 8 * 60 * 60 - 6 * 24 * 3600];//7天前的时间
    NSString *stopTime = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    //    NSLog(@"7天前的时间%@截止到今天的时间：%@",startTime,stopTime);

    [postDic setObject:@"" forKey:@"dev_id"];
    [postDic setObject:stopTime forKey:@"stop_time"];
    [postDic setObject:startTime forKey:@"start_time"];
    [postDic setObject:[NSString stringWithFormat:@"%ld", (long)pageNum * PAGESIZE] forKey:@"offset"];
    [postDic setObject:[NSString stringWithFormat:@"%d", PAGESIZE] forKey:@"limit"];
    [postDic setObject:@"100" forKey:@"alarmType"];//alarmType传100就是查询所有报警的,否则是过滤报警
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/list" parameters:postDic IsToken:YES success:^(id _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            NSLog(@"从服务器主动查询推送过来的报警信息responseObject:%@", responseObject);
            tempArr = [PushMsgModel mj_objectArrayWithKeyValuesArray:responseObject[@"body"][@"alarmList"]];
            if ([self.tv_list.mj_header isRefreshing]) {
                [self.alarmArr removeAllObjects];
            }
            if (tempArr.count != 0) {
                [self.alarmArr addObjectsFromArray:tempArr];
            }
            [self arrayClassification:self.alarmArr];//按日期分组
            [self.tv_list reloadData];
        } else {
            [self.tv_list.mj_header endRefreshing];
        }

        if ([self.tv_list.mj_header isRefreshing]) {
            [self.tv_list.mj_header endRefreshing];
        }
        if (tempArr.count < PAGESIZE) {
            [self.tv_list.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tv_list.mj_footer resetNoMoreData];
        }
    } failure:^(NSError *_Nonnull error) {
        if (self.isPop == YES) {//查询失败也需关闭筛选
            [BallLoading hideBallInView:self.filerView];
        }
        [XHToast showCenterWithText:NSLocalizedString(@"查询告警消息失败，请检查您的网络", nil)];
        [self.alarmArr removeAllObjects];
        [self.tv_list reloadData];
        [self.tv_list.mj_header endRefreshing];
        [self.tv_list.mj_footer endRefreshingWithNoMoreData];
    }];
}

#pragma mark - 给数组分类别
- (void)arrayClassification:(NSMutableArray *)arr {
    NSMutableArray *tempArr;
    [self.resultDateArr removeAllObjects];
    for (int i = 0; i < arr.count; i++) {
        //根据已读未读显示红点
        PushMsgModel *model = arr[i];
        NSString *timeStr = [NSString stringWithFormat:@"%d", model.alarmTime];
        NSTimeInterval time = [timeStr doubleValue];//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
        //实例化一个NSDateFormatter对象

        NSDateFormatter *timeDate = [[NSDateFormatter alloc]init];
        //设定时间格式,这里可以设置成自己需要的格式
        [timeDate setDateFormat:@"MM.dd"];
        NSString *currentDateStr = [timeDate stringFromDate:detaildate];
        /**
         *  description: 当temp与当前循环元素相等且不为最后一次循环
         *  添加一个元素到同类别的已有的组别中
         */

        if (i != 0 && i != arr.count - 1) {
            if ([tempDate isEqualToString:currentDateStr]) {
                [tempArr addObject:arr[i]];
            } else {
                [self.resultDateArr addObject:tempArr];
                tempArr = [NSMutableArray array];
                tempDate = currentDateStr;
                [tempArr addObject:arr[i]];
            }
        } else {
            if (i == 0) {
                tempArr = [NSMutableArray array];
                tempDate = currentDateStr;
                [tempArr addObject:arr[i]];
                if (arr.count == 1) {
                    [self.resultDateArr addObject:tempArr];
                }
            } else if (i == arr.count - 1) {
                if ([tempDate isEqualToString:currentDateStr]) {
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
    //    NSLog(@"日期组别：%@",self.resultDateArr);
}

#pragma mark - 时间转星期
- (NSString *)getWeekDay:(NSString *)currentStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];//实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式,要注意跟下面的dateString匹配，否则日起将无效
    NSDate *date = [dateFormat dateFromString:currentStr];
    NSArray *weekdays = [NSArray arrayWithObjects:[NSNull null], NSLocalizedString(@"星期日", nil), NSLocalizedString(@"星期一", nil), NSLocalizedString(@"星期二", nil), NSLocalizedString(@"星期三", nil), NSLocalizedString(@"星期四", nil), NSLocalizedString(@"星期五", nil), NSLocalizedString(@"星期六", nil), nil];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSTimeZone *timeZone = [[NSTimeZone alloc]initWithName:@"Asia/Beijing"];
//    [calendar setTimeZone: timeZone];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
//    NSLog(@"当前的时区：%@",[NSTimeZone systemTimeZone]);
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:date];
    return [weekdays objectAtIndex:theComponents.weekday];
}

#pragma mark - 编辑点击事件
- (void)editClick
{
    if (self.alarmArr.count != 0) {
        [self.btnArr removeAllObjects];
        //用来选择选中的数组
        for (int i = 0; i < self.alarmArr.count; i++) {
            NSString *btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr addObject:btnStr];
        }
        isEditable = YES;
        [self resetNavBtn];//重置导航栏
        [self setEditBottomView];//增加底部的编辑框
        [self.tv_list reloadData];
    } else {
        [XHToast showCenterWithText:NSLocalizedString(@"暂无事件消息！", nil)];
    }
}

#pragma mark - 取消编辑
- (void)cancelEdit
{
    for (int i = 0; i < self.alarmArr.count; i++) {
        NSString *btnStr = [NSString stringWithFormat:@"no"];
        [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
    }

    isEditable = NO;
    [self setNavBtn];
    [self removeEditBottomView];//移除底部的编辑框
    [_deleteArr removeAllObjects];//移除所有被选中的
    [self.tv_list reloadData];
}

#pragma mark - 全选
- (void)allChooseClick
{
    if (_allChooseBtn.selected == NO) {
        _allChooseBtn.selected = YES;
        [_allChooseBtn setTitle:NSLocalizedString(@"取消全选", nil) forState:UIControlStateNormal];
        [_deleteArr removeAllObjects];
        for (int i = 0; i < self.alarmArr.count; i++) {
            NSString *btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
        }
        [_deleteArr addObjectsFromArray:self.alarmArr];
    } else {
        for (int i = 0; i < self.alarmArr.count; i++) {
            NSString *btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
        }

        _allChooseBtn.selected = NO;
        [_allChooseBtn setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_deleteBtn setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
        [_deleteArr removeAllObjects];
    }
    [_deleteBtn setTitleColor:RGB(248, 56, 39) forState:UIControlStateNormal];
    [_deleteBtn setTitle:[NSString stringWithFormat:@"%@(%lu)", NSLocalizedString(@"删除", nil), (unsigned long)_deleteArr.count] forState:UIControlStateNormal];
    [self.tv_list reloadData];
}

#pragma mark - 删除
- (void)deleteClick
{
    if (_deleteArr.count == 0) {
        return;
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"删除后不可恢复，确定要删除吗？", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"删除", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action) {
            [self deleteAlarmMsg];
        }]];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - 删除告警消息
- (void)deleteAlarmMsg
{
    [self.view addSubview:self.progressView];
    NSString *totalStr = [NSString stringWithFormat:@"%lu", (unsigned long)_deleteArr.count];
    int totalCount = [totalStr intValue];
    __block int deleteCount = 0;
    [self.progressView ProgressBarTip:NSLocalizedString(@"正在删除报警消息...", nil) totalCount:totalCount andCurrentCount:deleteCount];
    /*
     * description : POST v1/alarm/delete(删除告警消息)
     *  param：access_token=<令牌> & user_id=<用户ID> & alarm_id=<设备ID>
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *userID = [unitl get_User_id];
    [dic setObject:userID forKey:@"user_id"];
    for (int i = 0; i < _deleteArr.count; i++) {
        PushMsgModel *pushModel = _deleteArr[i];
        [dic setObject:pushModel.alarmId forKey:@"alarm_id"];
        [[HDNetworking sharedHDNetworking]POST:@"v1/alarm/delete" parameters:dic IsToken:YES success:^(id _Nonnull responseObject) {
            deleteCount++;
            [self.progressView ProgressBarTip:NSLocalizedString(@"正在删除报警消息...", nil) totalCount:totalCount andCurrentCount:deleteCount];
            if (deleteCount == totalCount) {
                [self.progressView removeFromSuperview];
                [XHToast showCenterWithText:NSLocalizedString(@"报警消息删除成功", nil)];
            }
        } failure:^(NSError *_Nonnull error) {
            [self.progressView removeFromSuperview];
        }];
    }
    [self.alarmArr removeAllObjects];
    [self pullDownMethod];
    [self cancelEdit];
}

#pragma mark - 标记已读
- (void)markReadClick
{
    if (_deleteArr.count == 0) {
        return;
    } else {
        NSMutableArray *markreadArr = [NSMutableArray arrayWithCapacity:0];
        for (PushMsgModel *model in _deleteArr) {
            if (model.markread == NO) {
                model.markread = YES;
                [markreadArr addObject:model];
            }
        }
        NSLog(@"markreadArr:%@", markreadArr);

        if (markreadArr.count == 0) {
            return;
        } else {
            /*
             * description : POST v1/alarm/markread(告警消息已读)
             *  param：access_token=<令牌> & user_id=<用户ID> & alarm_id=<设备ID>
             */
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *userID = [defaults objectForKey:@"user_id"];
            [dic setObject:userID forKey:@"user_id"];

            for (int i = 0; i < markreadArr.count; i++) {
                PushMsgModel *model = markreadArr[i];
                [dic setObject:model.alarmId forKey:@"alarm_id"];
                [[HDNetworking sharedHDNetworking] POST:@"v1/alarm/markread" parameters:dic IsToken:YES success:^(id _Nonnull responseObject) {
                    //NSLog(@"responseObject：%@",responseObject);
                    [XHToast showCenterWithText:NSLocalizedString(@"报警消息已设置已读", nil)];
                } failure:^(NSError *_Nonnull error) {
                    NSLog(@"报警消息已读失败~");
                }];
            }
        }

        [_deleteArr removeAllObjects];
        [self cancelEdit];
        [self.tv_list reloadData];
    }
}

//==========================delegate==========================
//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.resultDateArr.count;
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *tempArr1 = [NSMutableArray arrayWithCapacity:0];
    [tempArr1 addObjectsFromArray:self.resultDateArr[section]];
    return tempArr1.count;
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
    headView.backgroundColor = RGB(245, 245, 245);
    //根据已读未读显示红点
    PushMsgModel *model = self.resultDateArr[section][0]; //self.resultDateArr
    NSString *timeStr = [NSString stringWithFormat:@"%d", model.alarmTime];
    NSTimeInterval time = [timeStr doubleValue];//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *timeDate = [[NSDateFormatter alloc]init];
    NSDateFormatter *timeWeek = [[NSDateFormatter alloc]init];
    //设定时间格式,这里可以设置成自己需要的格式
    [timeDate setDateFormat:@"yyyy.MM.dd."];
    [timeWeek setDateFormat:@"yyyy-MM-dd"];
    NSString *currentWeekStr = [timeWeek stringFromDate:detaildate];
    NSString *currentDateStr = [timeDate stringFromDate:detaildate];

    UILabel *dateTipLb1 = [[UILabel alloc]init];
    dateTipLb1.frame = CGRectMake(16, 0, self.view.frame.size.width, 40);
    dateTipLb1.font = FONT(15);
    dateTipLb1.textColor = RGB(30, 30, 30);
    dateTipLb1.text =  [NSString stringWithFormat:@"%@ %@", currentDateStr, [self getWeekDay:currentWeekStr]];
    [headView addSubview:dateTipLb1];

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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    static NSString *AlarmNewCell_Identifier = @"AlarmNewCell_Identifier";
    AlarmNewCell *cell = [tableView dequeueReusableCellWithIdentifier:AlarmNewCell_Identifier];
    if (cell == nil) {
        cell = [[AlarmNewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlarmNewCell_Identifier];
    }
    NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
    [tempDateArr addObjectsFromArray:self.resultDateArr[section]];//resultDateArr
    PushMsgModel *model = tempDateArr[row];
    
    cell.indexPath = indexPath;
    cell.delegete = self;
    cell.alermModel = model;

    if (isEditable == NO) {
        cell.isEdit = NO;
//        cell.chooseBtn.hidden = YES;
        [cell configChooseBtnHidden:YES];
    } else {
        cell.isEdit = YES;
//        cell.chooseBtn.hidden = NO;
        [cell configChooseBtnHidden:NO];

        //全选的判断
        if (self.allChooseBtn.selected == YES) {
//            cell.chooseBtn.selected = YES;
            [cell configChooseBtnSeleted:YES];
        } else {
//            cell.chooseBtn.selected = NO;
            [cell configChooseBtnSeleted:NO];
        }

        //判断当前选择第几个
        NSInteger tempCount = 0;
        for (int i = 0; i < indexPath.section; i++) {
            tempCount += [[self.resultDateArr objectAtIndex:i] count];
        }
        tempCount = tempCount + indexPath.row + 1;
        //NSLog(@"我self.btnArr的状态：%@",self.btnArr);
        if ([self.btnArr[tempCount - 1] isEqualToString:@"yes"]) {
//            cell.chooseBtn.selected = YES;
            [cell configChooseBtnSeleted:YES];
        } else {
//            cell.chooseBtn.selected = NO;
            [cell configChooseBtnSeleted:NO];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AlarmNewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    //判断当前选择第几个
    NSInteger tempCount = 0;
    for (int i = 0; i < indexPath.section; i++) {
        tempCount += [[self.resultDateArr objectAtIndex:i] count];
    }
    tempCount = tempCount + indexPath.row + 1;
//    NSLog(@"我现在选择的是第%ld个",(long)tempCount);

    if (isEditable == YES) {//在可编辑情况下下
        if ([self.btnArr[tempCount - 1] isEqualToString:@"no"]) {//indexPath.row
            NSString *btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:tempCount - 1 withObject:btnStr];//indexPath.row

            [_deleteArr addObject:[self.alarmArr objectAtIndex:tempCount - 1]];//indexPath.row
            [self.tv_list reloadData];
        } else {
            NSString *btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:tempCount - 1 withObject:btnStr];//indexPath.row
            [_deleteArr removeObject:[self.alarmArr objectAtIndex:tempCount - 1]];//indexPath.row
            [self.tv_list reloadData];
        }
        //根据删除的个数来变化删除的颜色
        if (_deleteArr.count == 0) {
            [self.deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.deleteBtn setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
        } else {
            NSString *title = [NSString stringWithFormat:@"%@(%lu)", NSLocalizedString(@"删除", nil), (unsigned long)_deleteArr.count];
            [self.deleteBtn setTitleColor:RGB(248, 56, 39) forState:UIControlStateNormal];
            [self.deleteBtn setTitle:title forState:UIControlStateNormal];
        }
    } else {
        NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
        [tempDateArr addObjectsFromArray:self.resultDateArr[indexPath.section]];//resultDateArr
        //根据已读未读显示红点
        PushMsgModel *model = tempDateArr[indexPath.row];

        NSNumber *typeNum = [[NSUserDefaults standardUserDefaults] objectForKey:ALARMVIDEOTYPE];

        switch ([typeNum intValue]) {
            case AlarmVideoType_shortVideo:
                if (model.alarmVideo) {
                    [self alarmVideoPlayMethodTitle:model.deviceName videoURL:model.alarmVideo];//http://220.249.115.46:18080/wav/day_by_day.mp4
                } else {
                    //若alarmViedo字段为空，则只是放大图片而已
//                    [self.view addSubview:self.enlarge];
//                    self.enlarge.enlargeImage = cell.pictureImage.image;
//                    [self.enlarge enlargeImageClick];
                    [self enlargeImageWithCell:cell atIndexPath:indexPath];
                }

                break;
            case AlarmVideoType_CloudVideo:
                [self videoPlaybackMethodisDeviceVideo:NO devID:model.deviceId];
                break;
            case AlarmVideoType_SDVideo:
                [self videoPlaybackMethodisDeviceVideo:YES devID:model.deviceId];
                break;
            default:
                break;
        }

        [self removeMarkReadClick:cell];
    }
}

#pragma mark - 录像回放点击事件
- (void)videoPlaybackMethodisDeviceVideo:(BOOL)isDeviceVideo devID:(NSString *)devID
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [paramDic setValue:devID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking] GET:@"/open/device/deviceinfo" parameters:paramDic IsToken:YES success:^(id _Nonnull responseObject) {
        //            NSLog(@"查询单个设备的信息:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            dev_list *devModel = [dev_list mj_objectWithKeyValues:responseObject[@"body"][@"dev"]];
            OnlyPlayBackVC *playbackVC = [[OnlyPlayBackVC alloc]init];
            playbackVC.titleName = devModel.name;
            playbackVC.listModel = devModel;
            playbackVC.bIsEncrypt = devModel.enable_sec;
            playbackVC.key = devModel.dev_p_code;
            playbackVC.isDeviceVideo = isDeviceVideo;
            [self.navigationController pushViewController:playbackVC animated:YES];
        }
    } failure:^(NSError *_Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"查询录像失败，请检查您的网络", nil)];
    }];
}

#pragma mark - 短视频点击事件
- (void)alarmVideoPlayMethodTitle:(NSString *)title videoURL:(NSString *)videoURL
{
    AVPlayerVC *playerVC = [[AVPlayerVC alloc]init];
    playerVC.videoTitle = title;
    playerVC.videoUrl = videoURL;
    [self.navigationController pushViewController:playerVC animated:YES];
}

#pragma mark - 放大告警消息图片代理方法
- (void)Alarmcell_tPictureImageClick:(AlarmNewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self removeMarkReadClick:cell];
    [self enlargeImageWithCell:cell atIndexPath:indexPath];
}

- (void)enlargeImageWithCell:(AlarmNewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self.view addSubview:self.enlarge];
    
    NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
    [tempDateArr addObjectsFromArray:self.resultDateArr[indexPath.section]];//resultDateArr
    //根据已读未读显示红点
    PushMsgModel *model = tempDateArr[indexPath.row];
    if (![NSString isNull:model.alarmPic]) {
        NSURL *imaUrl = [NSURL URLWithString:model.alarmPic];
        NSURLRequest *request = [NSURLRequest requestWithURL:imaUrl];
        __block UIImage *image;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *_Nullable response, NSData *_Nullable data, NSError *_Nullable connectionError) {
            //设备图片展示时所需解密的东西
            dev_list *devModel;
            NSMutableArray *devArr = (NSMutableArray *)[unitl getAllDeviceCameraModel];
            for (int i = 0; i < devArr.count; i++) {
                if ([((dev_list *)(devArr[i])).ID isEqualToString:model.deviceId]) {
                    devModel = ((dev_list *)(devArr[i]));
                    break;
                }
            }

            self.key = devModel.dev_p_code;
            self.bIsEncrypt = devModel.enable_sec;

            const unsigned char *imageCharData = (const unsigned char *)[data bytes];
            size_t len = [data length];

            unsigned char outImageCharData[len];
            size_t outLen = len;
            //        NSLog(@"收到图片的data：%@---长度：%zd",response,[data length]);
            if (len % 16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200 && self.key.length > 0 && self.bIsEncrypt) {
                int decrptImageSucceed = jw_cipher_decrypt(self.cipher, imageCharData, len, outImageCharData, &outLen);
                //            NSLog(@"报警界面，收到加密图片数据正确，进行解密:%d",decrptImageSucceed);
                if (decrptImageSucceed == 1) {
                    NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                    image = [UIImage imageWithData:imageData];

                    if (image) {
//                        cell.pictureImage.image = image;
                        self.enlarge.enlargeImage = image;
                    } else {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                                           [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
//                                       });
                        self.enlarge.imageUrl = model.alarmPic;
                    }
                } else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                                       [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
//                                   });
                    self.enlarge.imageUrl = model.alarmPic;
                }
            } else {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                                   [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
//                               });
                self.enlarge.imageUrl = model.alarmPic;
            }
        }];
    } else {
        self.enlarge.enlargeImage = [UIImage imageNamed:@"alerm"];
    }
    [self.enlarge enlargeImageClick];
}

#pragma mark - 放大图片去掉红点
- (void)removeMarkReadClick:(AlarmNewCell *)cell
{
    NSIndexPath *IndexPath = [self.tv_list indexPathForCell:cell];
    PushMsgModel *model = self.resultDateArr[IndexPath.section][IndexPath.row];
    if (!model.markread) {
        model.markread = YES;
//        cell.attentionView.hidden = YES;
        [cell configRedPointHidden:YES];
        /*
         * description : POST v1/alarm/markread(告警消息已读)
         * param：access_token=<令牌> & user_id=<用户ID> & alarm_id=<设备ID>
         */
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userID = [defaults objectForKey:@"user_id"];
        [dic setObject:userID forKey:@"user_id"];
        [dic setObject:model.alarmId forKey:@"alarm_id"];
        [[HDNetworking sharedHDNetworking] POST:@"v1/alarm/markread" parameters:dic IsToken:YES success:^(id _Nonnull responseObject) {
//            NSLog(@"responseObject：%@",responseObject);
        } failure:^(NSError *_Nonnull error) {
        }];
    }
    [self.tv_list reloadData];
}

//==========================lazy loading==========================
#pragma mark - getter && setter
- (void)dealloc
{
    jw_cipher_release(_cipher);
}

- (JW_CIPHER_CTX)cipher
{
    if (self.key && self.bIsEncrypt) {
        size_t len = strlen([self.key cStringUsingEncoding:NSASCIIStringEncoding]);
        _cipher =  jw_cipher_create((const unsigned char *)[self.key cStringUsingEncoding:NSASCIIStringEncoding], len);
    }
    return _cipher;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

//表视图
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight) style:UITableViewStyleGrouped];
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.backgroundColor = RGB(245, 245, 245);
        _tv_list.separatorStyle = UITableViewCellSelectionStyleNone;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tv_list.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 12)];
    }
    return _tv_list;
}

//告警消息数组
- (NSMutableArray *)alarmArr
{
    if (!_alarmArr) {
        _alarmArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _alarmArr;
}

//可放大的图片
- (EnlargeimageView *)enlarge
{
    if (!_enlarge) {
        _enlarge = [[EnlargeimageView alloc]initWithframe:CGRectZero];
    }
    return _enlarge;
}

//根据日期分类后的告警消息数组
- (NSMutableArray *)resultDateArr {
    if (!_resultDateArr) {
        _resultDateArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _resultDateArr;
}

//底部编辑View
- (UIView *)bottomEditView
{
    if (!_bottomEditView) {
        _bottomEditView = [[UIView alloc]initWithFrame:CGRectZero];
        _bottomEditView.backgroundColor = RGB(244, 243, 243);
        _bottomEditView.layer.shadowColor = [UIColor blackColor].CGColor;
        _bottomEditView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _bottomEditView.layer.shadowRadius = 3.0;
        _bottomEditView.layer.shadowOpacity = 0.3;
    }
    return _bottomEditView;
}

//全选按钮
- (UIButton *)allChooseBtn
{
    if (!_allChooseBtn) {
        _allChooseBtn = [[UIButton alloc]init];
        [_allChooseBtn setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [_allChooseBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _allChooseBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_allChooseBtn addTarget:self action:@selector(allChooseClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allChooseBtn;
}

//删除按钮
- (UIButton *)deleteBtn
{
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc]init];
        [_deleteBtn setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

//标记已读按钮
- (UIButton *)markReadBtn
{
    if (!_markReadBtn) {
        _markReadBtn = [[UIButton alloc]init];
        [_markReadBtn setTitle:NSLocalizedString(@"标记已读", nil) forState:UIControlStateNormal];
        [_markReadBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _markReadBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_markReadBtn addTarget:self action:@selector(markReadClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _markReadBtn;
}

//所有告警消息是否被选中的按钮数组
- (NSMutableArray *)btnArr
{
    if (!_btnArr) {
        _btnArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _btnArr;
}

//删除时弹出的进度条
- (ProgressBarView *)progressView
{
    if (!_progressView) {
        _progressView = [[ProgressBarView alloc]initWithFrame:self.view.bounds];
    }
    return _progressView;
}

#pragma mark - 筛选模块
- (void)filterClick
{
    self.isPop = YES;
    [self.view addSubview:self.filerView];
    [self.filerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    [UIView animateWithDuration:0.3 animations:^{
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
    [UIView animateWithDuration:0.1 animations:^{
        self.filerView.frame = CGRectMake(0, iPhoneHeight, iPhoneWidth, iPhoneHeight);
    } completion:^(BOOL finished) {
        [self.filerView removeFromSuperview];
    }];
}

#pragma mark - 关闭筛选消息视图代理协议
- (void)closeFilerView
{
    self.isPop = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UIView animateWithDuration:0.1 animations:^{
        self.filerView.frame = CGRectMake(0, iPhoneHeight, iPhoneWidth, iPhoneHeight);
    } completion:^(BOOL finished) {
        [self.filerView removeFromSuperview];
    }];
}

#pragma mark - filerView中的TableView选择的代理方法
- (void)SelectSectionofRowAtIndex:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        FilerDeviceVC *filerDeviceVC = [[FilerDeviceVC alloc]init];
        filerDeviceVC.myResultDeviceArr = self.myResultDeviceArr;
        [self.navigationController pushViewController:filerDeviceVC animated:YES];
    } else {
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
    pageNum = 0;
    [BallLoading showBallInView:self.filerView andTip:NSLocalizedString(@"数据加载中,请稍等...", nil)];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void) {
        [BallLoading hideBallInView:self.filerView];
        [self closeFilerClick];//点击完成后等待一会儿关闭筛选view
    });

    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownMethod)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
}

#pragma mark - 警告
- (void)createAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请选择查询某一特定时间", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    }];
    [alert addAction:btnAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 弹出视图的懒加载
- (FilerView *)filerView
{
    if (!_filerView) {
        _filerView = [[FilerView alloc]initWithDateArr:[self formatterDateArr] frame:CGRectMake(0, iPhoneHeight - 64, iPhoneWidth, iPhoneHeight)];
        _filerView.delegate = self;
    }
    return _filerView;
}

#pragma mark - 时间格式化
- (NSMutableArray *)formatterDateArr
{
    fdateArr = [NSMutableArray arrayWithCapacity:0];
    //当天时间归零方法(获取当天的零点零分)
    NSDate *now = [NSDate zeroOfDate];
    //    NSLog(@"现在时间：%@",now);
    //日期计算，返回当天的前某一天或者后某一天
    [fdateArr addObject:now];
    [fdateArr addObject:[NSDate offsetDay:-1 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-2 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-3 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-4 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-5 Date:now]];
    [fdateArr addObject:[NSDate offsetDay:-6 Date:now]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM.dd."];
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc]init];
    [weekFormatter setDateFormat:@"yyyy-MM-dd"];

    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:0];

    for (int i = 0; i < fdateArr.count; i++) {
        NSDate *destDate = [weekFormatter dateFromString:[weekFormatter stringFromDate:fdateArr[i]]];
        //判断今天单独拎出来
        NSString *resultDate;
        if (i == 0) {
            resultDate = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"今天", nil), [self weekStringFromDate:destDate] ];
        } else {
            resultDate = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:fdateArr[i]], [self weekStringFromDate:destDate]];
        }

        [resultArr addObject:resultDate];
    }

    return resultArr;
}

//-(NSString *)getNowDateFromatAnDate:(NSDate *)anyDate
//{
//    //设置源日期时区
//
//    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0900"];//或GMT
//
//    //
//    NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区
//    //设置转换后的目标日期时区
//
//    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
//
//    //得到源日期与世界标准时间的偏移量
//
//    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
//
//    //目标日期与本地时区的偏移量
//
//    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
//
//    //得到时间偏移量的差值
//
//    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
//
//    //转为现在时间
//
//    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
//
//    NSString * dateStr = [self dateToString:destinationDateNow];
//    return dateStr;
//
//}
//
//- (NSDate *)stringToDate:(NSString *)strdate
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *retdate = [dateFormatter dateFromString:strdate];
//    //    [dateFormatter release];
//    return retdate;
//}

#pragma mark - 时间转换星期
- (NSString *)weekStringFromDate:(NSDate *)date
{
    NSArray *weeks = @[[NSNull null], NSLocalizedString(@"星期日", nil), NSLocalizedString(@"星期一", nil), NSLocalizedString(@"星期二", nil), NSLocalizedString(@"星期三", nil), NSLocalizedString(@"星期四", nil), NSLocalizedString(@"星期五", nil), NSLocalizedString(@"星期六", nil)];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
//    NSLog(@"当前的时区1：%@",[NSTimeZone systemTimeZone]);
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *components = [calendar components:calendarUnit fromDate:date];
    return [weeks objectAtIndex:components.weekday];
}

/**
 字典数组取出某个key再组成一个数组

 @param dicArr 字典数组
 @param key 要取出组成数组的key
 @return 返回该key组成的数组
 */
- (NSMutableArray *)getKeyArray:(NSMutableArray *)dicArr byOneKey:(NSString *)key
{
    NSMutableArray *keyArr = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dic in dicArr) {
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
    NSDate *endDate = [NSDate dateWithTimeInterval:24 * 60 * 60 - 1 sinceDate:date];//当天晚上23.59
    //时区要减8个小时
    NSString *startTime = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970] - 8 * 60 * 60];
    NSString *stopTime = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970] - 8 * 60 * 60];

    NSLog(@"ID:%@", ID);

    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:ID forKey:@"dev_id"];
    [dic setObject:stopTime forKey:@"stop_time"];
    [dic setObject:startTime forKey:@"start_time"];
    [dic setObject:[NSString stringWithFormat:@"%ld", (long)pageNum * PAGESIZE] forKey:@"offset"];
    [dic setObject:[NSString stringWithFormat:@"%d", PAGESIZE] forKey:@"limit"];
    [dic setObject:@"100" forKey:@"alarmType"];//alarmType传100就是查询所有报警的,否则是过滤报警
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/list" parameters:dic IsToken:YES success:^(id _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
//            NSLog(@"从服务器主动查询推送过来的报警信息responseObject:%@",responseObject);
            tempArr = [PushMsgModel mj_objectArrayWithKeyValuesArray:responseObject[@"body"][@"alarmList"]];

            if ([self.tv_list.mj_header isRefreshing]) {
                [self.alarmArr removeAllObjects];
            }
            if (tempArr.count != 0) {
                [self.alarmArr addObjectsFromArray:tempArr];
            }
            [self arrayClassification:self.alarmArr];//按日期分组
            [self.tv_list reloadData];
        } else {
            [self.tv_list.mj_header endRefreshing];
        }

        if ([self.tv_list.mj_header isRefreshing]) {
            [self.tv_list.mj_header endRefreshing];
        }
        if (tempArr.count < PAGESIZE) {
            [self.tv_list.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tv_list.mj_footer resetNoMoreData];
        }

        [BallLoading hideBallInView:self.filerView];
    } failure:^(NSError *_Nonnull error) {
        [BallLoading hideBallInView:self.filerView];
        [XHToast showCenterWithText:NSLocalizedString(@"查询告警消息失败，请检查您的网络", nil)];
        [self.alarmArr removeAllObjects];
        [self.tv_list reloadData];
        [self.tv_list.mj_header endRefreshing];
        [self.tv_list.mj_footer endRefreshingWithNoMoreData];
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:ID forKey:@"dev_id"];
    [dic setObject:[NSString stringWithFormat:@"%ld", (long)pageNum * PAGESIZE] forKey:@"offset"];
    [dic setObject:[NSString stringWithFormat:@"%d", PAGESIZE] forKey:@"limit"];
    [dic setObject:@"100" forKey:@"alarmType"];//alarmType传100就是查询所有报警的,否则是过滤报警
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/list" parameters:dic IsToken:YES success:^(id _Nonnull responseObject) {
//        NSLog(@"FilterAlarmMessageFromServerID===responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
//            NSLog(@"从服务器主动查询推送过来的报警信息responseObject:%@",responseObject);

            tempArr = [PushMsgModel mj_objectArrayWithKeyValuesArray:responseObject[@"body"][@"alarmList"]];
            if ([self.tv_list.mj_header isRefreshing]) {
                [self.alarmArr removeAllObjects];
            }
            if (tempArr.count != 0) {
                [self.alarmArr addObjectsFromArray:tempArr];
            }
            [self arrayClassification:self.alarmArr];//按日期分组
            [self.tv_list reloadData];
        } else {
            [self.tv_list.mj_header endRefreshing];
        }

        if ([self.tv_list.mj_header isRefreshing]) {
            [self.tv_list.mj_header endRefreshing];
        }
        if (tempArr.count < PAGESIZE) {
            [self.tv_list.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tv_list.mj_footer resetNoMoreData];
        }

        [BallLoading hideBallInView:self.filerView];
    } failure:^(NSError *_Nonnull error) {
        [BallLoading hideBallInView:self.filerView];
        [XHToast showCenterWithText:NSLocalizedString(@"查询告警消息失败，请检查您的网络", nil)];
        [self.alarmArr removeAllObjects];
        [self.tv_list reloadData];
        [self.tv_list.mj_header endRefreshing];
        [self.tv_list.mj_footer endRefreshingWithNoMoreData];
    }];
}

#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"noContent"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"暂无事件消息！", nil);
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}

@end
