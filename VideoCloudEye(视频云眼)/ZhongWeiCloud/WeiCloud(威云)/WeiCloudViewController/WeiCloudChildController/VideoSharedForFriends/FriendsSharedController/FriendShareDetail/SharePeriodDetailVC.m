//
//  SharePeriodVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/16.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "SharePeriodDetailVC.h"
#import "ZCTabBarController.h"
#import "SettingCellOne_t.h"
#import "SetPickerView.h"//pickerView
#import "FriendShareDetailVC.h"
@interface SharePeriodDetailVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    SetPickerView* timePickerView;
    NSArray* _proTimeList;//小时数组
    NSArray* _proTitleList;//分钟数组
    NSString* _hourStr;//选择器小时
    NSString* _minStr;//选择器分钟
    int _editRow;//判断编辑哪个cell（1：第一个；2：第二个）
}
/*表视图*/
@property (nonatomic,strong) UITableView* tv_list;
//在该页面保留住起始时间/结束时间
@property (nonatomic,copy) NSString *tempStartTimeStr;
@property (nonatomic,copy) NSString *tempEndTimeStr;
/*完成按钮*/
@property (nonatomic,strong) UIButton *completeBtn;

@end

@implementation SharePeriodDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"分享时段", nil);
    [self setNavBtnItem];
    self.view.backgroundColor = BG_COLOR;
    [self createdateData];
    //初始化数据
    _editRow = 0;
    
    self.tempStartTimeStr = self.startTime;
    self.tempEndTimeStr = self.endTime;
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)setUpUI
{
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight-64));
    }];
}
//=========================method======================
- (void)returnVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ------编辑按钮和相应事件
//完成按钮
- (void)setNavBtnItem{
    //编辑按钮
    self.completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
    [self.completeBtn setTitle:NSLocalizedString(@"完成了", nil) forState:UIControlStateNormal];
    self.completeBtn.titleLabel.font = FONT(17);
    [self.completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.completeBtn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    self.completeBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.completeBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self cteateNavBtn];
}
#pragma mark - 点击完成按钮
- (void)completeClick
{
//    NSString *tempStr = [NSString stringWithFormat:@"分享时段从%@开始到%@结束",self.startTime,self.endTime];
//    [XHToast showCenterWithText:tempStr];
    
    if ([self getFrontofString:self.startTime] > [self getFrontofString:self.endTime]) {
        [XHToast showCenterWithText:NSLocalizedString(@"起始时间不能大于结束时间", nil)];
        return;
    }
    if ([self getFrontofString:self.startTime] == [self getFrontofString:self.endTime]) {
        if ([self getBackofString:self.startTime] > [self getBackofString:self.endTime]) {
            [XHToast showCenterWithText:NSLocalizedString(@"起始时间不能大于结束时间", nil)];
            return;
        }
        if ([self getBackofString:self.startTime] == [self getBackofString:self.endTime]) {
            [XHToast showCenterWithText:NSLocalizedString(@"起始时间不能等于结束时间", nil)];
            return;
        }
    }
    

    [Toast showLoading:self.view Tips:NSLocalizedString(@"正在设置分享时段，请稍候...", nil)];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.dev_mList.ID forKey:@"dev_id"];//设备id
    [postDic setObject:self.sharedPersonID forKey:@"to_userId"];//被分享的用户id

    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.rtv intValue]] forKey:@"rtv"];//实时视频
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.volice intValue]] forKey:@"volice"];//声音
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.hp intValue]] forKey:@"hp"];//历史回放
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.alarm intValue]] forKey:@"alarm"];//报警推送
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.talk intValue]] forKey:@"talk"];//对讲
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.ptz intValue]] forKey:@"ptz"];//云台
    
    if ([self.shareModel.timeLimit intValue]== 0) {
        [postDic setObject:@"-1" forKey:@"timeLimit"];
        self.shareModel.timeLimit = @"-1";//设置完之后model要修改
    }else{
        NSNumber *timeLimitNum = [NSNumber numberWithInt:[self.shareModel.timeLimit intValue]];
        [postDic setObject:timeLimitNum forKey:@"timeLimit"];
    }
    
    [postDic setObject:self.startTime forKey:@"startTime"];
    [postDic setObject:self.endTime forKey:@"endTime"];
    self.shareModel.startTime = self.startTime;//设置完之后model要修改
    self.shareModel.endTime = self.endTime;//设置完之后model要修改

    [[HDNetworking sharedHDNetworking] POST:@"v1/device/setPersonalShare" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"成功了%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"设置成功", nil)];
//                NSLog(@"postDic:%@",postDic);
                FriendShareDetailVC* sharedVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
                [self.navigationController popToViewController:sharedVC animated:YES];
            });
        }else{
            [Toast dissmiss];
            [XHToast showCenterWithText:NSLocalizedString(@"设置失败，请稍候再试", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        [XHToast showCenterWithText:NSLocalizedString(@"设置失败，请检查您的网络", nil)];
        NSLog(@"失败了");
    }];
    
}




#pragma mark - 创建pickerView
- (void)createPickerView:(NSInteger)row
{
    NSInteger startFrontTime;
    NSInteger startBackTime;
    if (row == 0) {
        startFrontTime = [self getFrontofString:self.tempStartTimeStr];
        startBackTime = [self getBackofString:self.tempStartTimeStr];
    }else{
        startFrontTime = [self getFrontofString:self.tempEndTimeStr];
        startBackTime = [self getBackofString:self.tempEndTimeStr];
    }
    
    NSLog(@"时间是什么：%ld==%ld",startFrontTime,startBackTime);
    
    timePickerView = [[SetPickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    timePickerView.hourPickerData = _proTimeList;
    timePickerView.minPickerData = _proTitleList;
    //
    [timePickerView.pickerView selectRow:startFrontTime inComponent:0 animated:YES];
    [timePickerView.pickerView selectRow:startBackTime inComponent:1 animated:YES];
    [self.view addSubview:timePickerView];
    timePickerView.selectBlock = ^(NSString * hourStr,NSString *minStr){
        _hourStr = hourStr;
        _minStr = minStr;
    };
    [timePickerView.btnOK addTarget:self action:@selector(reloadTableView) forControlEvents:UIControlEventTouchUpInside];
}
-(void)reloadTableView
{
    [self.tv_list reloadData];
}

#pragma mark - 创建日期数据
- (void)createdateData{
    _proTimeList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23", nil];
    _proTitleList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59", nil];
}

#pragma mark - 取“：”字符串之前的部分并转成NSInterger类型
- (NSInteger)getFrontofString:(NSString *)str
{
    NSRange range = [str rangeOfString:@":"]; //现获取要截取的字符串位置
    NSString * resultStr= [str substringToIndex:range.location]; //截取字符串
    NSLog(@"时间冒号前面部分：%@",resultStr);
    if (resultStr) {
        return  [resultStr integerValue];
    }else{
        return 0;
    }
}

#pragma mark - 取“：”字符串之后的部分并转成NSInterger类型
- (NSInteger)getBackofString:(NSString *)str
{
    NSRange range = [str rangeOfString:@":"]; //现获取要截取的字符串位置
    NSString * resultStr= [str substringFromIndex:range.location+1]; //截取字符串
    NSLog(@"时间冒号后面部分：%@",resultStr);
    if (resultStr) {
        return  [resultStr integerValue];
    }else{
        return 0;
    }
}


//=========================delegate=========================
#pragma mark - tableview的代理方法
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;

    if (row == 0) {
        static NSString* startTimeCell_Identifier = @"startTimeCell_Identifier";
        SettingCellOne_t* startTimeCell = [tableView dequeueReusableCellWithIdentifier:startTimeCell_Identifier];
        if(!startTimeCell){
            startTimeCell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:startTimeCell_Identifier];
        }
        startTimeCell.typeLabel.text = NSLocalizedString(@"起始时间", nil);

        if (_editRow == 0) {
            startTimeCell.titleLabel.text = self.startTime;
        }else if(_editRow == 1){
            startTimeCell.titleLabel.text = [NSString stringWithFormat:@"%@:%@",_hourStr,_minStr];
            self.startTime =  startTimeCell.titleLabel.text;
            self.tempStartTimeStr = startTimeCell.titleLabel.text;
        }

        startTimeCell.pushImage.image = [UIImage imageNamed:@"more"];
        return startTimeCell;
    }else{
        static NSString* endTimeCell_Identifier = @"endTimeCell_Identifier";
        SettingCellOne_t* endTimeCell = [tableView dequeueReusableCellWithIdentifier:endTimeCell_Identifier];
        if(!endTimeCell){
            endTimeCell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:endTimeCell_Identifier];
        }
        endTimeCell.typeLabel.text = NSLocalizedString(@"结束时间", nil);
        if (_editRow == 0) {
            endTimeCell.titleLabel.text = self.endTime;
        }else if(_editRow == 2){
            endTimeCell.titleLabel.text = [NSString stringWithFormat:@"%@:%@",_hourStr,_minStr];
            self.endTime =  endTimeCell.titleLabel.text;
            self.tempEndTimeStr = endTimeCell.titleLabel.text;
        }

        endTimeCell.pushImage.image = [UIImage imageNamed:@"more"];
        return endTimeCell;
    }
    

}

//cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (row == 0) {
        _editRow = 1;
        [self createPickerView:0];
    }else if (row == 1){
        _editRow = 2;
        [self createPickerView:1];
    }
    [timePickerView popPickerView];
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
    headView.backgroundColor = BG_COLOR;
    if (section == 0) {
        UILabel* dateTipLb = [[UILabel alloc]init];
        [headView addSubview:dateTipLb];
        [dateTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(headView.mas_centerY).offset(5);
            make.left.equalTo(headView.mas_left).offset(15);
        }];
        dateTipLb.text = NSLocalizedString(@"时段选择", nil);
        dateTipLb.textColor = RGB(50, 50, 50);
        dateTipLb.font = FONT(16);
        
        UILabel* detailTipLb = [[UILabel alloc]init];
        [headView addSubview:detailTipLb];
        [detailTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(dateTipLb.mas_right).offset(0);
            make.centerY.equalTo(dateTipLb.mas_centerY);
        }];
        detailTipLb.text = NSLocalizedString(@"（权限只在该时间段内有效）", nil);
        detailTipLb.textColor = RGB(50, 50, 50);
        detailTipLb.font = FONT(12);
        
    }
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

#pragma mark - getter && setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
    }
    return _tv_list;
}

@end
