//
//  SharetimeLimitVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/16.
//  Copyright © 2018年 张策. All rights reserved.
//
#define OneDay NSLocalizedString(@"1天", nil)
#define ThreeDay NSLocalizedString(@"3天", nil)
#define Week NSLocalizedString(@"7天", nil)
#define Forever NSLocalizedString(@"永久", nil)

#import "SharetimeLimitDetailVC.h"
#import "ZCTabBarController.h"

#import "FriendShareDetailVC.h"
#import "FilerDateCell.h"
@interface SharetimeLimitDetailVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    /*记录是选择了哪一个时间点*/
    NSInteger dateRow;
    /*记录第一次选择的时间点*/
    NSInteger firstRow;
}
/*表视图*/
@property (nonatomic,strong) UITableView* tv_list;
/*完成按钮*/
@property (nonatomic,strong) UIButton *completeBtn;
/*时限选项*/
@property (nonatomic,strong) NSArray *dateArr;
@property(nonatomic,strong)NSIndexPath *lastPath;//***主要是用来接收用户上一次所选的cell的indexpath

@end

@implementation SharetimeLimitDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"分享时限", nil);
    [self setNavBtnItem];
    self.view.backgroundColor = BG_COLOR;
    self.dateArr = @[OneDay,ThreeDay,Week,Forever];

    if ([self.shareModel.timeLimit intValue] == 0) {//默认为0 设置即永久
        self.lastPath = [NSIndexPath indexPathForRow:3 inSection:0];
    }else if ([self.shareModel.timeLimit intValue] == 1){
        self.lastPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }else if ([self.shareModel.timeLimit intValue] == 3){
        self.lastPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }else if ([self.shareModel.timeLimit intValue] == 7){
        self.lastPath = [NSIndexPath indexPathForRow:2 inSection:0];
    }else{
        self.lastPath = [NSIndexPath indexPathForRow:3 inSection:0];
    }
    firstRow = [self.lastPath row];
    dateRow = [self.lastPath row];
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
    if (self.lastPath.row == firstRow) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self createAlertView];
    }
}

#pragma mark - 警告框
- (void)createAlertView
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"你确定要放弃修改吗？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
    [Toast showLoading:self.view Tips:NSLocalizedString(@"正在设置分享时限，请稍候...", nil)];
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.dev_mList.ID forKey:@"dev_id"];//设备id
    [postDic setObject:self.sharedPersonID forKey:@"to_userId"];//被分享的用户id

    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.rtv intValue]] forKey:@"rtv"];//实时视频
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.volice intValue]] forKey:@"volice"];//声音
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.hp intValue]] forKey:@"hp"];//历史回放
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.alarm intValue]] forKey:@"alarm"];//报警推送
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.talk intValue]] forKey:@"talk"];//对讲
    [postDic setObject:[NSNumber numberWithInt:[self.shareModel.ptz intValue]] forKey:@"ptz"];//云台
    //对时段与时限进行处理
    if (self.shareModel.startTime) {
        [postDic setObject:self.shareModel.startTime forKey:@"startTime"];
    }else{
        [postDic setObject:@"00:00" forKey:@"startTime"];
        self.shareModel.startTime = @"00:00";//设置完之后model要修改
    }
    if (self.shareModel.endTime) {
        [postDic setObject:self.shareModel.endTime forKey:@"endTime"];
    }else{
        [postDic setObject:@"23:59" forKey:@"endTime"];
        self.shareModel.endTime = @"23:59";//设置完之后model要修改
    }
    
    //对时限的选择
    if ([self.dateArr[dateRow] isEqualToString:OneDay]) {
        [postDic setObject:@"1" forKey:@"timeLimit"];
        self.shareModel.timeLimit = @"1";//设置完之后model要修改
    }else if ([self.dateArr[dateRow] isEqualToString:ThreeDay]){
        [postDic setObject:@"3" forKey:@"timeLimit"];
        self.shareModel.timeLimit = @"3";//设置完之后model要修改
    }else if ([self.dateArr[dateRow] isEqualToString:Week]){
        [postDic setObject:@"7" forKey:@"timeLimit"];
        self.shareModel.timeLimit = @"7";//设置完之后model要修改
    }else{
        [postDic setObject:@"-1" forKey:@"timeLimit"];
        self.shareModel.timeLimit = @"-1";//设置完之后model要修改
    }
    
    
//    NSString *resultStr = [NSString stringWithFormat:@"我选择了%@",self.dateArr[dateRow]];
    /*
     * description :POST v1/device/ setPersonalShare(设置该用户的权限)
     *  param：access_token=<令牌> & user_id=<用户ID>& to_userId=<用户ID> & dev_id=<设备ID> & rtv=<实时视频>& talk=<对讲>& volice=<声音>& hp=<历史回放>& ptz=<云台>& alarm=<报警>& startTime=<时段的开始时间(01:30)> & endTime=<时段的结束时间(23:59)> & timeLimit=<时限(1,3,7,-1)(-1代表无穷大)>
     */
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
                sharedVC.shareModel = self.shareModel;
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
    return 4;
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
    static NSString* filerDateCell_Identifier = @"filerDateCell_Identifier";
    FilerDateCell* cell = [tableView dequeueReusableCellWithIdentifier:filerDateCell_Identifier];
    if(!cell){
        cell = [[FilerDateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:filerDateCell_Identifier];
    }
    cell.dateLb.text = self.dateArr[row];
    cell.dateLb.textColor = RGB(60, 60, 60);
    NSInteger oldRow = [_lastPath row];
    if (row == oldRow && _lastPath!=nil) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
    
}
//cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *newIndexPath;
    if (indexPath.section == 0) {
        NSInteger newRow = [indexPath row];
        NSInteger oldRow = (self.lastPath !=nil)?[self.lastPath row]:-1;
        if (newRow != oldRow) {
            FilerDateCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            FilerDateCell *oldCell = [tableView cellForRowAtIndexPath:_lastPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.lastPath = indexPath;
            newIndexPath = indexPath;
            //拿到当前选中的
            dateRow = [indexPath row];
        }

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
        dateTipLb.text = NSLocalizedString(@"时限选择", nil);
        dateTipLb.textColor = RGB(50, 50, 50);
        dateTipLb.font = FONT(16);
        
        UILabel* detailTipLb = [[UILabel alloc]init];
        [headView addSubview:detailTipLb];
        [detailTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(dateTipLb.mas_right).offset(0);
            make.centerY.equalTo(dateTipLb.mas_centerY);
        }];
        detailTipLb.text = NSLocalizedString(@"（到期后权限将自动失效）", nil);
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
