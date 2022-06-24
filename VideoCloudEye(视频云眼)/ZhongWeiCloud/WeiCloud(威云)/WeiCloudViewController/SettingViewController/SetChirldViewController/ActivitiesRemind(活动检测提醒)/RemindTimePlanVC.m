//
//  RemindTimePlanVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/30.
//  Copyright © 2018年 张策. All rights reserved.
//

#define WorkDay NSLocalizedString(@"08:00 ~ 20:00(工作日)", nil)
#define NonWorkDays NSLocalizedString(@"23:00 ~ 09:00(周末)", nil)
#define EveryDay NSLocalizedString(@"00:00 ~ 23:59(每天)", nil)
#import "RemindTimePlanVC.h"
#import "ZCTabBarController.h"

#import "FilerDateCell.h"
#import "AddRemindPlanCell.h"
#import "CustomRemindPlanCell.h"
#import "RemindTimeController.h"
#import "CircleSuccessLoading.h"
@interface RemindTimePlanVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    /*记录是选择了哪一个时间点*/
    NSInteger dateRow;
    /*记录第一次选择的时间点*/
    NSInteger firstRow;
     /*记录有没有开启自定义时间选择*/
    BOOL isOpenCustomCell;
}
@property (nonatomic,strong) UITableView *tv_list;
@property (nonatomic,strong) UIButton *completeBtn;//完成按钮
@property (nonatomic,strong) NSArray *dateArr;//时限选项
@property(nonatomic,strong)NSIndexPath *lastPath;//***主要是用来接收用户上一次所选的cell的indexpath
@end

@implementation RemindTimePlanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"活动检测提醒计划", nil);
    self.dateArr = @[WorkDay,NonWorkDays,EveryDay];
    [self setPeriodStatus];
    [self setUpUI];
    [self setNavBtnItem];
    self.view.backgroundColor = BG_COLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    if (self.isRefresh == YES) {
        [self setPeriodStatus];
        self.isRefresh = NO;
    }
    
}

- (void)setUpUI
{
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 270));
    }];
   
}


//=========================method======================
- (void)returnVC
{
    [self cancelGuardPlan];
}

#pragma mark - 判断选择勾选的选择项状态
- (void)setPeriodStatus
{
    NSString *periodStr = [self.periodStr stringByReplacingOccurrencesOfString:@"," withString:@""];//去掉空格
    
    if ([self.startTime isEqualToString:@"08:00"] && [self.endTime isEqualToString:@"20:00"] && [periodStr isEqualToString:@"12345"]) {
        self.lastPath = [NSIndexPath indexPathForRow:0 inSection:0];
        isOpenCustomCell = NO;
    }else if ([self.startTime isEqualToString:@"23:00"] && [self.endTime isEqualToString:@"09:00"] && [periodStr isEqualToString:@"67"]){
        self.lastPath = [NSIndexPath indexPathForRow:1 inSection:0];
        isOpenCustomCell = NO;
    }else if ([self.startTime isEqualToString:@"00:00"] && ([self.endTime isEqualToString:@"00:00"] || [self.endTime isEqualToString:@"24:00"] ||[self.endTime isEqualToString:@"23:59"]) && [periodStr isEqualToString:@"1234567"]){
        self.lastPath = [NSIndexPath indexPathForRow:2 inSection:0];
        isOpenCustomCell = NO;
    }else{
         isOpenCustomCell = YES;
    }
    
    if (isOpenCustomCell == YES) {//打开了自定义，此时dateRow将选择的是自定义为-1
        dateRow = -1;
    }else{
        dateRow = [self.lastPath row];
    }
    [self.tv_list reloadData];

}



#pragma mark - 编辑按钮和相应事件
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

    NSMutableDictionary* postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:[unitl get_User_id] forKey:@"user_id"];
    [postDic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [postDic setObject:@"1"forKey:@"alarmType"];
    [postDic setObject:@"1" forKey:@"enable"];
    NSNumber* sensitivityNum = @([self.sensibility integerValue]);
    [postDic setObject:sensitivityNum forKey:@"sensibility"];
    
    if (dateRow == -1) {
        [postDic setObject:self.startTime forKey:@"start_time"];
        [postDic setObject:self.endTime forKey:@"stop_time"];
        [postDic setObject:self.periodStr forKey:@"period"];
    }else{
        NSString *resultStr = [NSString stringWithFormat:@"%@",self.dateArr[dateRow]];
        if ([resultStr isEqualToString:WorkDay]) {
            [postDic setObject:@"08:00" forKey:@"start_time"];
            [postDic setObject:@"20:00" forKey:@"stop_time"];
            [postDic setObject:@"1,2,3,4,5" forKey:@"period"];
        }else if ([resultStr isEqualToString:NonWorkDays]){
            [postDic setObject:@"23:00" forKey:@"start_time"];
            [postDic setObject:@"09:00" forKey:@"stop_time"];
            [postDic setObject:@"6,7" forKey:@"period"];
        }else if ([resultStr isEqualToString:EveryDay]){
            [postDic setObject:@"00:00" forKey:@"start_time"];
            [postDic setObject:@"00:00" forKey:@"stop_time"];
            [postDic setObject:@"1,2,3,4,5,6,7" forKey:@"period"];
        }
    }
    
     [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在设置提醒时间", nil)];
     /*
     * description : POST v1/device/setguardplan(设置布防信息)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & alarmType=<告警类型>
     & enable= <启用还是停止> & start_time<开始时间> & stop_time<结束时间> & period<周期>
     &sensibility=<灵敏度 int>
     
     * alarmType：告警类型，目前只支持1（活动检测），不填默认为1
     enable:  布防/撤防，1是布防 0是撤防，撤防的话，后面start_time, stop_time以及period可以不填
     start_time:布防开始时间，如08:30
     stop_time:布防结束时间，如 17:00
     period: 重复周期，如”1,2,3,4,5”， 表示周一到周五
     sensibility: 灵敏度 1~100
     */
     NSLog(@"灵敏度：%@,开始时间：%@，结束时间：%@，周期：%@",self.sensibility,self.startTime,self.endTime,self.periodStr);
     
     [[HDNetworking sharedHDNetworking]POST:@"v1/device/setguardplan" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
         NSLog(@"responseObject:%@",responseObject);
         int ret = [responseObject[@"ret"]intValue];
         if (ret == 0) {
            [CircleSuccessLoading showSucInView:self.view andTip:NSLocalizedString(@"提醒时间设置成功", nil)];
             dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
             dispatch_after(time, dispatch_get_main_queue(), ^(void){
                 [self.navigationController popViewControllerAnimated:YES];
             });
         }else{
             [XHToast showCenterWithText:NSLocalizedString(@"提醒时间段设置失败，请稍候再试", nil)];
         }
         [CircleLoading hideCircleInView:self.view];
     } failure:^(NSError * _Nonnull error) {
         [CircleLoading hideCircleInView:self.view];
          [XHToast showCenterWithText:NSLocalizedString(@"提醒时间段设置失败，请检查您的网络", nil)];
     }];
     
   
}

#pragma mark - 比较两个时间段【判断同一天还是第二天】
- (BOOL)compareTime:(NSString *)min andMaxTime:(NSString *)max
{
    if ([min length] != 0  && [max length] != 0) {
        //小时间的小时部分
        NSRange minrH = {0,2};
        NSString *minStrH = [min substringWithRange:minrH];
        int minH = [minStrH intValue];
        //大时间的小时部分
        NSRange maxrH = {0,2};
        NSString *maxStrH = [max substringWithRange:maxrH];
        int maxH = [maxStrH intValue];
        //小时间的分钟部分
        NSString *minStrM = [min substringFromIndex:3];
        int minM = [minStrM intValue];
        //大时间的小时部分
        NSString *maxStrM = [max substringFromIndex:3];
        int maxM = [maxStrM intValue];
        //    NSLog(@"%d:%d;%d:%d",minH,minM,maxH,maxM);
        if (maxH > minH) {
            return NO;
        }else if(maxH < minH){
            return YES;
        }else{
            if (maxM > minM) {
                return NO;
            }else{
                return YES;
            }
        }
    }else{
        return NO;
    }
}

#pragma mark - 取消设置布防
- (void)cancelGuardPlan
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"提醒时间段尚未保存，是否退出编辑？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"否", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"是", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

//=========================delegate=========================
#pragma mark - tableview的代理方法
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }else{
        return 1;
    }
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44;
    }else{
        return 55;
    }
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
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
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }else{
        if (isOpenCustomCell == YES) {
            static NSString* CustomRemindPlanCell_Identifier = @"CustomRemindPlanCell_Identifier";
            CustomRemindPlanCell* cell = [tableView dequeueReusableCellWithIdentifier:CustomRemindPlanCell_Identifier];
            if(!cell){
                cell = [[CustomRemindPlanCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CustomRemindPlanCell_Identifier];
            }
            
            if ([self compareTime:self.startTime andMaxTime:self.endTime]) {
                cell.titleLb.text = [NSString stringWithFormat:@"%@~%@(%@)",self.startTime,self.endTime,NSLocalizedString(@"第二天", nil)];
            }else{
                cell.titleLb.text = [NSString stringWithFormat:@"%@~%@",self.startTime,self.endTime];
            }
            
            NSArray * titleArr = @[NSLocalizedString(@"星期一,", nil),NSLocalizedString(@"星期二,", nil),NSLocalizedString(@"星期三,", nil),NSLocalizedString(@"星期四,", nil),NSLocalizedString(@"星期五,", nil),NSLocalizedString(@"星期六,", nil),NSLocalizedString(@"星期日,", nil)];
            NSMutableString* titleStr = [[NSMutableString alloc]init];
            NSArray* tempArr;
            if (self.periodStr.length!=0) {
                tempArr = [self.periodStr componentsSeparatedByString:@","];
            }
            if (tempArr.count < 7){
                for (int i = 0; i<tempArr.count; i++) {
                    [titleStr appendFormat:@"%@", titleArr[[tempArr[i] integerValue]-1]];
                }
                NSString* resultTitle = [titleStr substringWithRange:NSMakeRange(0, [titleStr length] - 1)];
                cell.subTitleLb.text = [NSString stringWithFormat:@"%@",resultTitle];
                [cell.subTitleLb setFont:FONT(11)];
            }else if(tempArr.count == 7){
                cell.subTitleLb.text = NSLocalizedString(@"每天", nil);
                [cell.subTitleLb setFont:FONT(13)];
            }
        
            if (self.lastPath) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }else{
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
            return cell;
        }else{
            static NSString* AddRemindPlanCell_Identifier = @"AddRemindPlanCell_Identifier";
            AddRemindPlanCell* cell = [tableView dequeueReusableCellWithIdentifier:AddRemindPlanCell_Identifier];
            if(!cell){
                cell = [[AddRemindPlanCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddRemindPlanCell_Identifier];
            }
            cell.addImg.image = [UIImage imageNamed:@"addRemindPlan"];
            cell.titleLb.text = NSLocalizedString(@"自定义时间段", nil);
            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
            return cell;
        }
        
    }
    
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
        
        [self.tv_list reloadData];
    }else{
        if (isOpenCustomCell == YES) {
            CustomRemindPlanCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            RemindTimeController *remindTimeVC = [[RemindTimeController alloc]init];
            remindTimeVC.dev_mList = self.dev_mList;
            remindTimeVC.sensibility = self.sensibility;
            remindTimeVC.startTime = self.startTime;
            remindTimeVC.endTime = self.endTime;
            remindTimeVC.periodStr = self.periodStr;
            [self.navigationController pushViewController:remindTimeVC animated:YES];
        }
        dateRow = -1;
        _lastPath = nil;
//        [self.tv_list reloadData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        return NO;
    }else{
        if (isOpenCustomCell == YES) {
            return YES;
        }else{
            return NO;
        }
    }
}
/**
 *  左滑cell时出现什么按钮
 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        return nil;
    }else{
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"编辑", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            NSLog(@"编辑");
            RemindTimeController *remindTimeVC = [[RemindTimeController alloc]init];
            remindTimeVC.dev_mList = self.dev_mList;
            remindTimeVC.sensibility = self.sensibility;
            remindTimeVC.startTime = self.startTime;
            remindTimeVC.endTime = self.endTime;
            remindTimeVC.periodStr = self.periodStr;
            [self.navigationController pushViewController:remindTimeVC animated:YES];
            [self.tv_list reloadData];
        }];
        editAction.backgroundColor = MAIN_COLOR;

        UITableViewRowAction *deleteaction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"删除", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            NSLog(@"删除");
            
            if (dateRow == -1) {
                self.lastPath = [NSIndexPath indexPathForRow:2 inSection:0];
                dateRow = [self.lastPath row];
                self.startTime = @"00:00";
                self.endTime = @"23:59";
                self.periodStr = @"1,2,3,4,5,6,7";
            }
            
            isOpenCustomCell = NO;
            [self.tv_list reloadData];
        }];
        return @[deleteaction,editAction];
    }
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }else{
        return 5;
    }
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    if (section == 0) {
        headView.frame = CGRectMake(0, 0, iPhoneWidth, 10);
    }else{
        headView.frame = CGRectMake(0, 0, iPhoneWidth, 5);
    }
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        if (isOpenCustomCell == YES) {
            return 20;
        }
    }
    return 0.001;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    if (section == 1) {
        if (isOpenCustomCell == YES) {
            view.frame = CGRectMake(0, 0, iPhoneWidth, 20);
            UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, iPhoneWidth, 20)];
            tipLb.font = FONT(12);
            tipLb.textColor = RGB(180, 180, 180);
            tipLb.text = NSLocalizedString(@"左滑可“编辑”或者“删除”自定义时间段", nil);
            [view addSubview:tipLb];
        }
    }else{
        view.frame = CGRectMake(0, 0, iPhoneWidth, 0.001);
    }
    return view;
}

#pragma mark - getter && setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.scrollEnabled = NO;
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
    }
    return _tv_list;
}

@end
