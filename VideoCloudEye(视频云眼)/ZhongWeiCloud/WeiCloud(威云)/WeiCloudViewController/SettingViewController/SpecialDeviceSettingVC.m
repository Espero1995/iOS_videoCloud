//
//  SpecialDeviceSettingVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/9.
//  Copyright © 2018年 张策. All rights reserved.
//
/*
 * description:特殊设备的界面【NT4、J3】
 */

#import "SpecialDeviceSettingVC.h"
#import "ZCTabBarController.h"

#import "DeviceNameController.h"
#import "TransferDeviceVC.h"
#import "UpdataViewController.h"

#import "UpdataModel.h"

#import "SettingCellOne_t.h"
#import "autoUpdateCell.h"
#import "SettingCellThree_t.h"
@interface SpecialDeviceSettingVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic,strong) UITableView* tv_list;
@property (nonatomic,copy) NSString* latest_version;//最新版本
@property (nonatomic,copy) NSString* cur_version;//当前版本
@property (nonatomic,assign) BOOL isAutoUpdate;//判断是否自动升级
@end

@implementation SpecialDeviceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"设置", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn]; //导航栏按钮
    [self getAutoUpdateStatus];//获取自动升级状态
    [self getVersionInfo];//查询设备版本信息
    [self.view addSubview:self.tv_list];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    [self.tv_list reloadData];
}

//=========================init=========================
#pragma mark ----- 页面初始化的一些方法 -----

//=========================method=========================
#pragma mark ----- 方法 -----
#pragma mark - 获取自动升级状态
- (void)getAutoUpdateStatus
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getupgradeconfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"自动升级结果：%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            if ([responseObject[@"body"][@"UpgradeConfig"] intValue] == 1) {
                self.isAutoUpdate = YES;
            }else{
                self.isAutoUpdate = NO;
            }
        }else{
            self.isAutoUpdate = NO;
        }
        
        [self.tv_list reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"自动升级获取失败了");
//        self.isAutoUpdate = NO;
        [self.tv_list reloadData];
    }];
}
//更改升级状态
- (void)changeAutoUpdateValue:(UISwitch *)switchBtn
{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        self.isAutoUpdate = YES;
        [self setAutoUpdateDevice];
    }else{
        switchBtn.on = NO;
        self.isAutoUpdate = NO;
        [self setAutoUpdateDevice];
    }
}

#pragma mark - 设置自动升级状态
- (void)setAutoUpdateDevice
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    if (self.isAutoUpdate) {
        [dic setObject:@"1" forKey:@"auto_ug"];
    }else{
        [dic setObject:@"0" forKey:@"auto_ug"];
    }
    
    [[HDNetworking sharedHDNetworking] POST:@"v1/device/setupgradeconfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"自动升级设置：%@",responseObject);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"自动升级设置失败");
    }];
}

#pragma mark - 查询版本信息
- (void)getVersionInfo
{
    /*
     * description : GET v1/device/version/info(获取版本信息)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [defaults objectForKey:@"user_id"];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [dic setObject:userID forKey:@"user_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/version/info" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            UpdataModel* model = [UpdataModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.latest_version = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"当前版本", nil),model.latest_version];
            self.cur_version = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"当前版本", nil),model.cur_version];
            [self.tv_list reloadData];
        }else{
            self.latest_version = NSLocalizedString(@"获取版本号失败", nil);
            self.cur_version = NSLocalizedString(@"获取版本号失败", nil);
            [self.tv_list reloadData];
        }
        
    } failure:^(NSError * _Nonnull error) {
        self.latest_version = NSLocalizedString(@"获取版本号失败", nil);
        self.cur_version = NSLocalizedString(@"获取版本号失败", nil);
        [self.tv_list reloadData];
    }];
}

#pragma mark - 重启设备方法
- (void)restartAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"确定要重启设备吗？发送重启指令后,设备将在几分钟内离线！", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在发送重启指令...", nil)];
        [self deviceRestart];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
//设备重启方法
- (void)deviceRestart
{
    /*
     * description : POST v1/device/restart(重启设备)
     *  param：access_token=<令牌> & dev_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/restart" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            [CircleLoading hideCircleInView:self.view];
            [XHToast showCenterWithText:NSLocalizedString(@"重启设备成功", nil)];
        }else{
            [CircleLoading hideCircleInView:self.view];
            [XHToast showCenterWithText:NSLocalizedString(@"重启设备失败", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [CircleLoading hideCircleInView:self.view];
        [XHToast showCenterWithText:NSLocalizedString(@"重启设备失败", nil)];
    }];
}

#pragma mark - 删除设备方法
- (void)deleteAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"确定删除该设备？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteDevice];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
//删除设备
- (void)deleteDevice
{
    /*
     * description : POST v1/device/delete(删除设备)
     *  param：access_token=<令牌> & dev_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/delete" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        //发送删除设备的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];
        //NSLog(@"删除成功");
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        //NSLog(@"失败了");
    }];
}


//=========================delegate=========================
#pragma mark ----- 代理协议 -----
#pragma mark - tableview的代理方法
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    }else{
        return 1;
    }
}

//cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {//修改名称
        static NSString* nameCell_Identifier = @"NameCell_Identifier";
        SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:nameCell_Identifier];
        if(!cell){
            cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nameCell_Identifier];
        }
        cell.typeLabel.text = NSLocalizedString(@"设备名称", nil);
        
        //获取本地的model
        NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
        tempAllGroupArr = [unitl getAllGroupCameraModel];
        
        NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
        devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
        
        for (int i = 0; i < devListArr.count; i++) {
            if ([((dev_list *)devListArr[i]).ID isEqualToString:self.dev_mList.ID]) {
                dev_list * appointDevModel = devListArr[i];
                cell.titleLabel.text = appointDevModel.name;
            }
        }
        
        return cell;
    }else if (section == 1){//设备转移
        static NSString* TransferDeviceCell_Identifier = @"TransferDeviceCell_Identifier";
        SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:TransferDeviceCell_Identifier];
        if(!cell){
            cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TransferDeviceCell_Identifier];
        }
        cell.typeLabel.text = NSLocalizedString(@"转移设备", nil);
        return cell;
    }else if (section == 2){//设备升级[手动+自动]升级
        if (row == 0) {
            static NSString *autoUpdateCell_Identifier = @"autoUpdateCell_Identifier";
            autoUpdateCell* cell = [tableView dequeueReusableCellWithIdentifier:autoUpdateCell_Identifier];
            if(!cell){
                cell = [[autoUpdateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:autoUpdateCell_Identifier];
            }
            cell.nameLb.text = NSLocalizedString(@"设备自动升级", nil);
            if (self.isAutoUpdate) {
                cell.switchBtn.on = YES;
            }else{
                cell.switchBtn.on = NO;
            }
            [cell.switchBtn addTarget:self action:@selector(changeAutoUpdateValue:) forControlEvents:UIControlEventValueChanged];
            return cell;
            
        }else{
            static NSString* UpdateCell_Identifier = @"UpdateCell_Identifier";
            SettingCellOne_t* updateCell = [tableView dequeueReusableCellWithIdentifier:UpdateCell_Identifier];
            if(!updateCell){
                updateCell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UpdateCell_Identifier];
            }
            updateCell.typeLabel.text = NSLocalizedString(@"设备升级", nil);
            updateCell.titleLabel.text = self.cur_version;
            if(![self.cur_version isEqualToString:self.latest_version]){//红点
                updateCell.redDotImg.hidden = NO;
            }else{
                updateCell.redDotImg.hidden = YES;
            }
            return updateCell;
        }
    }else if (section == 3){//重启设备
        static NSString* RestartCell_Identifier = @"RestartCell_Identifier";
        SettingCellThree_t* cell = [tableView dequeueReusableCellWithIdentifier:RestartCell_Identifier];
        if(!cell){
            cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RestartCell_Identifier];
        }
        cell.deleteLabel.text = NSLocalizedString(@"重启设备", nil);
        return cell;
    }else{//删除设备
        static NSString *DeleteCell_Identifier = @"DeleteCell_Identifier";
        SettingCellThree_t* cell = [tableView dequeueReusableCellWithIdentifier:DeleteCell_Identifier];
        if(!cell){
            cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DeleteCell_Identifier];
        }
        cell.deleteLabel.text = NSLocalizedString(@"删除设备", nil);
        [cell.deleteLabel setTextColor:[UIColor redColor]];
        return cell;
    }
        
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (section == 0) {//修改设备名称
        DeviceNameController * nameVC = [[DeviceNameController alloc]init];
        nameVC.listModel = self.dev_mList;
        nameVC.currentIndex = self.currentIndex;
        [self.navigationController pushViewController:nameVC animated:YES];
    }else if (section == 1){//设备转移
        TransferDeviceVC* transferVC = [[TransferDeviceVC alloc]init];
        transferVC.dev_mList = self.dev_mList;
        [self.navigationController pushViewController:transferVC animated:YES];
    }else if (section == 2){//设备升级
        if (row == 0) {
            //设备自动升级
        }else{
            if (![self.cur_version isEqualToString:self.latest_version]) {
                UpdataViewController * updataVC= [[UpdataViewController alloc]init];
                updataVC.listModel = self.dev_mList;
                [self.navigationController pushViewController:updataVC animated:YES];
            }else{
                if ([self.cur_version isEqualToString:NSLocalizedString(@"获取版本号失败", nil)]) {
                    
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"设备已为当前最新版本,无需升级", nil)];
                }
            }
        }
    }else if (section == 3){//设备重启
        [self restartAlert];
    }else{//设备删除
        [self deleteAlert];
    }
    
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 15;
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    headView.backgroundColor = [UIColor clearColor];
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 15;
    }
    return 0.001;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] init];
    if (section == 1) {
        view.frame = CGRectMake(0, 0, iPhoneWidth, 15);
        UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, iPhoneWidth, 15)];
        tipLb.font = FONT(12);
        tipLb.textColor = RGB(150, 150, 150);
        tipLb.text = NSLocalizedString(@"您可以将设备转移给他人使用，转移后设备将归属他人", nil);
        [view addSubview:tipLb];
    }else{
        view.frame = CGRectMake(0, 0, iPhoneWidth, 0.001);
    }

    view.backgroundColor = [UIColor clearColor];
    return view;
}


//=========================lazy loadiing=========================
#pragma mark ----- 懒加载 -----
#pragma mark - getter&&setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, iPhoneWidth, iPhoneHeight-64) style:UITableViewStyleGrouped];
        _tv_list.backgroundColor = BG_COLOR;
        //设置代理
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
    }
    return _tv_list;
}
@end
