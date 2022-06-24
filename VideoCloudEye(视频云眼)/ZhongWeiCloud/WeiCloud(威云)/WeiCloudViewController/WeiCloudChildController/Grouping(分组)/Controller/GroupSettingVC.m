//
//  GroupSettingVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/27.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupSettingVC.h"
//========Model========
//========View========
#import "GroupDeleteCell.h"
#import "GroupCommonCell.h"
#import "SettingCellTwo_t.h"
#import "AddorDelCell.h"//设备的添加删除cell
#import "GroupnoDevCell.h"//无设备时cell的样式
//========VC========
/*修改组名*/
#import "ModifyGroupNameVC.h"
/*防护模式设置*/
#import "ProtectionModeVC.h"
/*增删设备*/
#import "GroupChoosingVC.h"
#define AddorDel_Cell @"AddorDel_Cell"
@interface GroupSettingVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    AddorDelCellDelegate,
    GroupnoDevCellDelegate
>
{
    BOOL isMydevGroup;//判断是否是我的设备这个组
    BOOL isTop;//是否置顶
    BOOL isOpenProtect;//是否开启防护模式
}
@property (nonatomic,strong) UITableView *tv_list;
@end

@implementation GroupSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.groupModel.groupName;
    [self cteateNavBtn];
    self.view.backgroundColor = BG_COLOR;
    //需要判断是否是我的设备进入的，是的话就没有分组定置的功能
    if ([self.groupModel.groupName isEqualToString:NSLocalizedString(@"我的设备", nil)]) {
        isMydevGroup = YES;
    }else{
        isMydevGroup = NO;
    }
    [self.view addSubview:self.tv_list];
    
    //测试下分组的查询
    [self groupDeviceSearch];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//=========================method=========================

- (void)getData
{
    //更新当前组信息
    self.devModelArr = [unitl getCameraGroupDeviceModelIndex:self.groupIndex];
    NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
    tempArr = [unitl getCameraGroupModelIndex:self.groupIndex];
    isTop = ((deviceGroup *)tempArr).top;
    self.groupModel.groupName = ((deviceGroup *)tempArr).groupName;
    self.navigationItem.title = self.groupModel.groupName;
    [self.tv_list reloadData];
}


//测试下分组的查询
- (void)groupDeviceSearch
{
    /**
     * description：GET v1/devicegroup/queryDeviceGroup（只查询组）
     * access_token=<令牌> & user_id =<用户ID>
     */
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [[HDNetworking sharedHDNetworking]GET:@"v1/devicegroup/queryDeviceGroup" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"测试下分组的查询:%@",responseObject);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
    }];
}


#pragma mark - 一键布防
- (void)groupingSetGuard:(UISwitch *)switchBtn
{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        isOpenProtect = YES;
        [XHToast showCenterWithText:NSLocalizedString(@"已开启布防", nil)];
    }else{
        switchBtn.on = NO;
        [XHToast showCenterWithText:NSLocalizedString(@"已关闭布防", nil)];
        isOpenProtect = NO;
    }
    
    
    /**
     * description：v1/devicegroup/updateGroupSensibility（设备分组一键布防）
     *access_token=<令牌> & user_id =<用户ID>& group_id=< group_id 组id>& enableSensibility=< enableSensibility布防(意义同设备)> & alarmType=<告警类型>
     & enable= <启用还是停止> & start_time<开始时间> & stop_time<结束时间> & period<周期>&sensibility=<灵敏度 int>
     */
    /*
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:@"92cf68b6-32d5-4217-bcfc-4718cfbb27b8" forKey:@"group_id"];//测试一下的组ID
    [postDic setObject:@"1" forKey:@"alarmType"];
    
    if (isOpenProtect == YES) {
        [postDic setObject:@"1" forKey:@"enableSensibility"];
        [postDic setObject:@"1" forKey:@"enable"];
    }else{
        [postDic setObject:@"0" forKey:@"enableSensibility"];
        [postDic setObject:@"0" forKey:@"enable"];
    }
    
    
    [postDic setObject:@"00:00" forKey:@"startTime"];
    [postDic setObject:@"23:59" forKey:@"stopTime"];
    [postDic setObject:@"1,2,3,4,5,6,7" forKey:@"period"];
    [postDic setObject:[NSNumber numberWithInt:50] forKey:@"sensibility"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/devicegroup/updateGroupSensibility" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"一键布防的结果:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            
        }else{
            [XHToast showCenterWithText:@"一键布防设置失败，请稍后再试"];
            isOpenProtect = !isOpenProtect;
            [self.tv_list reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:@"一键布防设置失败，请检查您的网络"];
        isOpenProtect = !isOpenProtect;
        [self.tv_list reloadData];
    }];
    */
}

#pragma mark - 分组置顶
- (void)groupingSettop:(UISwitch *)switchBtn
{
    NSLog(@"我现在置顶的是第几个：%ld",(long)self.groupIndex);
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        isTop = YES;
        [Toast showLoading:self.view Tips:NSLocalizedString(@"正在置顶，请稍候...", nil)];
    }else{
        switchBtn.on = NO;
        isTop = NO;
        [Toast showLoading:self.view Tips:NSLocalizedString(@"正在取消置顶，请稍候...", nil)];
    }
    /**
     * description: GET v1/devicegroup/updateGroupTop（设备分组是否置顶）
     * access_token=<令牌> & user_id =<用户ID>& group_id=< group_id 组id>& is_top=< is_top 组是否置顶（true，false）>
     */
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.groupModel.groupID forKey:@"group_id"];
    [postDic setObject:[NSNumber numberWithBool:isTop] forKey:@"is_top"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/devicegroup/updateGroupTop" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self UpDateGroupInfoIsTopAction:YES];
        }else{
            isTop = !isTop;
            [XHToast showCenterWithText:NSLocalizedString(@"置顶设置失败，请稍候再试", nil)];
            [self.tv_list reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
       // NSLog(@"失败了");
        isTop = !isTop;
        [XHToast showCenterWithText:NSLocalizedString(@"置顶设置失败，请检查您的网络", nil)];
        [self.tv_list reloadData];
    }];
    
}

#pragma mark - 删除分组
- (void)deleteGroup
{
    /**
     * description:GET v1/devicegroup/delete （删除设备分组）
     * access_token=<令牌> & user_id =<用户ID>& group_id=<group_id 组id>
     */
   [Toast showLoading:self.view Tips:NSLocalizedString(@"正在删除分组，请稍候...", nil)];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.groupModel.groupID forKey:@"group_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/devicegroup/delete" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"删除分组：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"删除成功", nil)];
               // [[NSNotificationCenter defaultCenter]postNotificationName:GroupCreateOrDeleteSuccess_updateUI object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];//需要刷新设备列表
                [self UpDateGroupInfoIsTopAction:NO];
            });
 
        }else{
            [Toast dissmiss];
            [XHToast showCenterWithText:NSLocalizedString(@"删除分组失败，请稍候再试", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
        [Toast dissmiss];
        [XHToast showCenterWithText:NSLocalizedString(@"删除分组失败，请检查您的网络", nil)];
    }];
}
#pragma mark ==== 删除或添加设备之后更新设备列表。

/**
 删除、置顶等操作之后更新设备列表

 @param isTopAction isTopAction 是表示置顶调用 反之：删除操作
 */
- (void)UpDateGroupInfoIsTopAction:(BOOL)isTopAction
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSNumber *languageType;
    if (isSimplifiedChinese) {
        languageType = [NSNumber numberWithInt:1];
    }else{
        languageType = [NSNumber numberWithInt:2];
    }
    [dic setObject:languageType forKey:@"languageType"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/devicegroup/listGroup" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        //        NSLog(@"查询分组信息:%@",responseObject);
        if (ret == 0) {
            WeiCloudListModel *listModel = [WeiCloudListModel mj_objectWithKeyValues:responseObject[@"body"]];
            
            NSInteger groupCount = listModel.deviceGroup.count;
            //保存组别中的组名和ID
            NSMutableArray * tempGroupArr = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < groupCount; i++) {
                NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
                [tempDic setObject:listModel.deviceGroup[i].groupName forKey:@"groupName"];
                [tempDic setObject:listModel.deviceGroup[i].groupId forKey:@"groupID"];
                [tempGroupArr addObject:tempDic];
            }
            NSString * GroupNameAndIDArr_KeyStr = [unitl getKeyWithSuffix:[unitl get_User_id] Key:GroupNameAndIDArr_key];
            [unitl saveDataWithKey:GroupNameAndIDArr_KeyStr Data:tempGroupArr];
            [unitl saveAllGroupCameraModel:[NSMutableArray arrayWithArray:listModel.deviceGroup]];
            
            [unitl saveCurrentDisplayGroupIndex:0];
            [[NSNotificationCenter defaultCenter]postNotificationName:GroupCreateOrDeleteSuccess_updateUI object:nil];

            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                if (isTopAction) {
                    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
                    [dic setObject:[NSNumber numberWithInteger:0] forKey:chooseGroup];
                    [[NSNotificationCenter defaultCenter]postNotificationName:chooseGroup object:nil userInfo:dic];
                }else
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            });
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"查询分组 网络正在开小差...");
    }];
}



//警告框
- (void)deleteGroupAlert
{
    UIAlertController *alert;
    if (self.devModelArr.count == 0) {
        alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"确定要删除该分组？", nil) preferredStyle:UIAlertControllerStyleAlert];
    }else
    {
       alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"若该分组下还有设备存在，删除后设备将转移至“我的设备”，确定要删除？", nil) preferredStyle:UIAlertControllerStyleAlert];
    }
   
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteGroup];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}



//=========================delegate=========================
#pragma mark -----tableViewDelegate
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isMydevGroup) {
        return 1;
    }else{
        return 2;
    }
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isMydevGroup) {
        if (section == 0) {
            return 3;//5
        }else{
            return 1;
        }
    }else{
        return 2;//4
    }
}
//每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (self.devModelArr.count == 0) {
        if (section == 0) {
            if (row == 0) {
                return 0.3*iPhoneHeight;
            }
        }else{
            return 44;
        }
    }else{
        
        float width = (iPhoneWidth - 30)/3.f;
        float height = width*13/23+20;
        NSInteger count;//设备个数
        if (isMydevGroup) {
            count = self.devModelArr.count;//【我的设备组没有添加和删除功能】
        }else{
            count = self.devModelArr.count +2;//【个数：设备个数+添加+删除】
        }
        if (section == 0) {
            if (row == 0) {//第一行放添加设备
                if (count % 3 == 0) {
                    return (count/3)*height+50;
                }else{
                    return (count/3+1)*height+50;
                }
            }
        }else{
            return 44;
        }
        
    }
    return 44;
}

//区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return 0.001;
    }else{
        return 30;
    }
}

//区高
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, iPhoneWidth, 30);
    return backView;
}

//每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            
            if (self.devModelArr.count == 0) {
                //加载自定义的Cell
                static NSString *GroupnoDevCell_Identifier = @"GroupnoDevCell_Identifier";
                GroupnoDevCell* cell = [tableView dequeueReusableCellWithIdentifier:GroupnoDevCell_Identifier];
                if(!cell){
                    cell = [[GroupnoDevCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupnoDevCell_Identifier];
                }
                cell.delegate = self;
                if (isMydevGroup) {
                    cell.isMydevGroup = YES;
                    cell.tipLb.text = NSLocalizedString(@"分组内无设备\n添加新设备后，设备会默认出现在这里", nil);
                }else{
                    cell.isMydevGroup = NO;
                    cell.tipLb.text = NSLocalizedString(@"添加设备", nil);
                }
                cell.backgroundColor = BG_COLOR;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                
            }else{
                [tableView registerClass:[AddorDelCell class] forCellReuseIdentifier:AddorDel_Cell];
                AddorDelCell *cell = [tableView dequeueReusableCellWithIdentifier:AddorDel_Cell forIndexPath:indexPath];
                cell.delegate = self;
                cell.isMyDevGroup = isMydevGroup;
                cell.devModelArr = self.devModelArr;
                cell.backgroundColor = BG_COLOR;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            
            
        }else if (row == 1){// || row == 2
            //加载自定义的Cell
            static NSString *GroupCommonCell_Identifier = @"GroupCommonCell_Identifier";
            GroupCommonCell* cell = [tableView dequeueReusableCellWithIdentifier:GroupCommonCell_Identifier];
            if(!cell){
                cell = [[GroupCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupCommonCell_Identifier];
            }
            if (row == 1) {
                cell.titleLb.text = NSLocalizedString(@"分组名称", nil);
                cell.subtitleLb.text = self.groupModel.groupName;
                if (isMydevGroup) {
                    cell.arrowIcon.hidden = YES;
                }else{
                    cell.arrowIcon.hidden = NO;
                }
            }
//            if (row == 2){
//                cell.titleLb.text = @"防护模式设置";
//            }
             return cell;
        }
        /*
        else if (row == 3){
            static NSString *ProtectionCell_Identifier = @"ProtectionCell_Identifier";
            SettingCellTwo_t* cell = [tableView dequeueReusableCellWithIdentifier:ProtectionCell_Identifier];
            if(!cell){
                cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProtectionCell_Identifier];
            }
            cell.typeLabel.text = @"一键布防";
            cell.typeLabel.textColor = RGB(50, 50, 50);
            cell.typeLabel.font = FONT(17);
            if (isOpenProtect == YES) {
                cell.switchBtn.on = YES;
            }else{
                cell.switchBtn.on = NO;
            }
            
            [cell.switchBtn addTarget:self action:@selector(groupingSetGuard:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }*/
         else{
            static NSString *TopCell_Identifier = @"TopCell_Identifier";
            SettingCellTwo_t* cell = [tableView dequeueReusableCellWithIdentifier:TopCell_Identifier];
            if(!cell){
                cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TopCell_Identifier];
            }
            cell.typeLabel.text = NSLocalizedString(@"分组置顶", nil);
            cell.typeLabel.textColor = RGB(50, 50, 50);
            cell.typeLabel.font = FONT(17);
            if (isTop == YES) {
                cell.switchBtn.on = YES;
            }else{
                cell.switchBtn.on = NO;
            }
            
            [cell.switchBtn addTarget:self action:@selector(groupingSettop:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        
    }else{
        //加载自定义的Cell
        static NSString *GroupDeleteCell_Identifier = @"GroupDeleteCell_Identifier";
        GroupDeleteCell* cell = [tableView dequeueReusableCellWithIdentifier:GroupDeleteCell_Identifier];
        if(!cell){
            cell = [[GroupDeleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupDeleteCell_Identifier];
        }
        cell.deleteLb.text = NSLocalizedString(@"删除分组", nil);
        return cell;
    }
    
}

//每一行的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (isMydevGroup) {
        /*
        if (row == 2) {
            ProtectionModeVC *protectVC = [[ProtectionModeVC alloc]init];   
            protectVC.groupModel = self.groupModel;
            [self.navigationController pushViewController:protectVC animated:YES];
        }
        */
    }else{
        if (section == 0) {
            if (row == 1) {
                ModifyGroupNameVC *modifygroupNameVC = [[ModifyGroupNameVC alloc]init];
                modifygroupNameVC.groupNameStr = self.groupModel.groupName;
                modifygroupNameVC.groupID = self.groupModel.groupID;
                [self.navigationController pushViewController:modifygroupNameVC animated:YES];
            }
            if (row == 2){
                ProtectionModeVC *protectVC = [[ProtectionModeVC alloc]init];
                protectVC.groupModel = self.groupModel;
                [self.navigationController pushViewController:protectVC animated:YES];
            }
        }else{
            /*
             * description:  注：需要判断这个分组是否有设备，有设备警告框，无设备直接删除
             */
            [self deleteGroupAlert];
        }
    }
}



#pragma mark - 添加设备
- (void)addDevClick
{
   // [XHToast showCenterWithText:@"添加设备"];
    GroupChoosingVC *chooseVC = [[GroupChoosingVC alloc]init];
    chooseVC.chooseWay = 2;
    chooseVC.groupModel = self.groupModel;
    chooseVC.groupIndex = self.groupIndex;
    [self.navigationController pushViewController:chooseVC animated:YES];
}
#pragma mark - 删除设备
- (void)deleteDevClick
{
   // [XHToast showCenterWithText:@"移除设备"];
    GroupChoosingVC *chooseVC = [[GroupChoosingVC alloc]init];
    chooseVC.chooseWay = 3;
    chooseVC.groupModel = self.groupModel;
    chooseVC.groupIndex = self.groupIndex;
    [self.navigationController pushViewController:chooseVC animated:YES];
}
#pragma mark - 无设备时添加设备
- (void)noDevAddClick
{
//    [XHToast showCenterWithText:@"无设备时添加设备"];
    GroupChoosingVC *chooseVC = [[GroupChoosingVC alloc]init];
    chooseVC.chooseWay = 2;
    chooseVC.groupModel = self.groupModel;
    chooseVC.groupIndex = self.groupIndex;
    [self.navigationController pushViewController:chooseVC animated:YES];
}

#pragma mark - getter && setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight) style:UITableViewStylePlain];
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tv_list.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _tv_list;
}

- (NSMutableArray *)devModelArr
{
    if (!_devModelArr) {
        _devModelArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _devModelArr;
}

@end
