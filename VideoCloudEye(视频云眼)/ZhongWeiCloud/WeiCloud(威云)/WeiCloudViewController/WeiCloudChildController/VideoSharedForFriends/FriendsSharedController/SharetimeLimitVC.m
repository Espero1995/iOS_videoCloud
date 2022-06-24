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

#import "SharetimeLimitVC.h"
#import "ZCTabBarController.h"

#import "FriendsSharedVC.h"
#import "FilerDateCell.h"
@interface SharetimeLimitVC ()
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
/*分享设备能力集model*/
@property (nonatomic,strong) shareFeature *shareModel;
@end

@implementation SharetimeLimitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"分享时限", nil);
    [self setNavBtnItem];
    self.view.backgroundColor = BG_COLOR;
    self.dateArr = @[OneDay,ThreeDay,Week,Forever];
    
    if (self.modifyPermissionDic) {//判断是否是修改过传的值，否则用默认值
       NSNumber *tempLimtNum = [self.modifyPermissionDic objectForKey:@"timeLimit"];
        if ([tempLimtNum intValue] == 0) {//默认为0 设置即永久
            self.lastPath = [NSIndexPath indexPathForRow:3 inSection:0];
        }else if ([tempLimtNum intValue] == 1){
            self.lastPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }else if ([tempLimtNum intValue] == 3){
            self.lastPath = [NSIndexPath indexPathForRow:1 inSection:0];
        }else if ([tempLimtNum intValue] == 7){
            self.lastPath = [NSIndexPath indexPathForRow:2 inSection:0];
        }else{
            self.lastPath = [NSIndexPath indexPathForRow:3 inSection:0];
        }
    }else{
        //给其初始化（其他）能力集
        if (self.dev_mList.ext_info.shareFeature) {
            self.shareModel = self.dev_mList.ext_info.shareFeature;
            if ([self.shareModel.timeLimit intValue] == 0) {//默认为0 设置即永久
                self.lastPath = [NSIndexPath indexPathForRow:3 inSection:0];
            }else if ([self.shareModel.timeLimit intValue] == 1){
                self.lastPath = [NSIndexPath indexPathForRow:0 inSection:0];
            }else if ([self.shareModel.timeLimit intValue]== 3){
                self.lastPath = [NSIndexPath indexPathForRow:1 inSection:0];
            }else if ([self.shareModel.timeLimit intValue] == 7){
                self.lastPath = [NSIndexPath indexPathForRow:2 inSection:0];
            }else{
                self.lastPath = [NSIndexPath indexPathForRow:3 inSection:0];
            }
        }else{
            self.lastPath = [NSIndexPath indexPathForRow:3 inSection:0];
        }
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
    
    if (self.modifyPermissionDic) {
//         NSLog(@"self.modifyPermissionDic:%@",self.modifyPermissionDic);
        
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"rtv"] forKey:@"rtv"];//实时视频
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"volice"] forKey:@"volice"];//声音
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"hp"] forKey:@"hp"];//历史回放
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"alarm"] forKey:@"alarm"];//报警推送
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"talk"] forKey:@"talk"];//对讲
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"ptz"] forKey:@"ptz"];//云台
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"startTime"] forKey:@"startTime"];//开始时间
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"endTime"] forKey:@"endTime"];//结束时间
        
    }else{
//        NSLog(@"我会使用model里的属性的");
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
        }
        if (self.shareModel.endTime) {
            [postDic setObject:self.shareModel.endTime forKey:@"endTime"];
        }else{
            [postDic setObject:@"23:59" forKey:@"endTime"];
        }
        
    }
    
    //对时限的选择
    if ([self.dateArr[dateRow] isEqualToString:OneDay]) {
        [postDic setObject:@"1" forKey:@"timeLimit"];
    }else if ([self.dateArr[dateRow] isEqualToString:ThreeDay]){
        [postDic setObject:@"3" forKey:@"timeLimit"];
    }else if ([self.dateArr[dateRow] isEqualToString:Week]){
        [postDic setObject:@"7" forKey:@"timeLimit"];
    }else{
        [postDic setObject:@"-1" forKey:@"timeLimit"];
    }
    
    
//    NSString *resultStr = [NSString stringWithFormat:@"我选择了%@",self.dateArr[dateRow]];

    [[HDNetworking sharedHDNetworking] POST:@"v1/device/setSharedDev" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"成功了%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            
            //修改本地的model
            NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
            tempAllGroupArr = [unitl getAllGroupCameraModel];
            NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
            devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
            
            for (int i = 0; i < devListArr.count; i++) {
                if ([((dev_list *)devListArr[i]).ID isEqualToString:self.dev_mList.ID]) {
                    dev_list * appointDevModel = devListArr[i];
                    appointDevModel.ext_info.shareFeature.timeLimit = postDic[@"timeLimit"];
                }
            }
            [unitl saveAllGroupCameraModel:tempAllGroupArr];
            
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"设置成功", nil)];
                NSLog(@"postDic:%@",postDic);

                FriendsSharedVC* sharedVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
                sharedVC.modifyPermissionDic = postDic;
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
