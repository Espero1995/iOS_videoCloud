//
//  PeriodTimeController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/19.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "PeriodTimeController.h"
#import "ZCTabBarController.h"
#import "SetChirldCell.h"//星期cell
#import "SetScopeTimeCell.h"//设置时间范围
#import "RemindTimeController.h"
@interface PeriodTimeController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    //数据源数组
    NSMutableArray * _array;
    //传值数组
    NSMutableArray * _dataArray;
}
@property (nonatomic,strong) UITableView* tv_list;
@end

@implementation PeriodTimeController
//=========================system=========================
#pragma mark ----- 生命周期 -----
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"重复周期", nil);
    [self cteateNavBtn];
    [self createData];
    [self.view addSubview:self.tv_list];
//    NSLog(@"P周期：%@",self.periodStr);

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//=========================init=========================
#pragma mark ----- 页面初始化的一些方法 -----
- (void)createData
{
    NSArray * timeArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    _array = [[NSMutableArray alloc]initWithArray:timeArray];
    _dataArray = [NSMutableArray arrayWithCapacity:0];
}


//七天全选
- (void)selectAlldays
{
//    [XHToast showCenterWithText:@"七天全选"];
    [_dataArray removeAllObjects];
    for (int i = 1; i <= 7; i++) {
        [_dataArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self.tv_list reloadData];
}

//选择工作日
- (void)selectWeekdays
{
//    [XHToast showCenterWithText:@"选择工作日"];
    [_dataArray removeAllObjects];
    for (int i = 1; i <= 5; i++) {
        [_dataArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self.tv_list reloadData];
}

//选择周末
- (void)selectWeekends
{
//    [XHToast showCenterWithText:@"选择周末"];
    [_dataArray removeAllObjects];
    for (int i = 6; i <= 7; i++) {
        [_dataArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self.tv_list reloadData];
}

//=========================method=========================
#pragma mark ----- 方法 -----
#pragma mark - 返回方法
- (void)returnVC
{
    if (_dataArray.count == 0) {
        [self createAlert];
    }else{
        //对时间进行排序
        [_dataArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *a = (NSString *)obj1;
            NSString *b = (NSString *)obj2;
            int aNum = [a intValue];
            int bNum = [b intValue];
            if (aNum > bNum) {
                return NSOrderedDescending;
            }
            else if (aNum < bNum){
                return NSOrderedAscending;
            }
            else {
                return NSOrderedSame;
            }
        }];
        RemindTimeController *remindVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        remindVC.periodStr = [_dataArray componentsJoinedByString:@","];
        NSLog(@"remindVC.periodStr:%@",_dataArray);
        [self.navigationController popToViewController:remindVC animated:YES];
    }
   
}
//警告框
- (void)createAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"重复周期至少选择一天", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:btnAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    return 2;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }else{
        return 7;
    }
}
//cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        NSArray *selectLargeScopeArr = @[NSLocalizedString(@"每天", nil),NSLocalizedString(@"工作日", nil),NSLocalizedString(@"周末", nil)];
        NSArray *selectdetailScopeArr = @[NSLocalizedString(@"(星期一 ~ 星期天)", nil),NSLocalizedString(@"(星期一 ~ 星期五)", nil),NSLocalizedString(@"(星期六、天)", nil)];
        static NSString* SetScopeTimeCell_Identifier = @"SetScopeTimeCell_Identifier";
        SetScopeTimeCell *scopePeriodCell = [tableView dequeueReusableCellWithIdentifier:SetScopeTimeCell_Identifier];
        if(!scopePeriodCell){
            scopePeriodCell = [[SetScopeTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SetScopeTimeCell_Identifier];
        }

        scopePeriodCell.scopeTimeLb.text = selectLargeScopeArr[row];
        scopePeriodCell.scopeTipLb.text = selectdetailScopeArr[row];

        
        if (row == 0) {
            
            if (self.periodStr.length != 0) {
                NSArray* arr = [self.periodStr componentsSeparatedByString:@","];
                _dataArray = [NSMutableArray arrayWithArray:arr];
                //判断是否有勾选7天_dataArray
                if (_dataArray.count == 7) {
                    scopePeriodCell.isChoosedImg.hidden = NO;
                }else{
                    scopePeriodCell.isChoosedImg.hidden = YES;
                }
            }else{
                //判断是否有勾选7天_dataArray
                if (_dataArray.count == 7) {
                    scopePeriodCell.isChoosedImg.hidden = NO;
                }else{
                    scopePeriodCell.isChoosedImg.hidden = YES;
                }
            }
           
        }else if (row == 1){
            //判断是否是工作日
            if ([self judgeisWeekday]) {
                scopePeriodCell.isChoosedImg.hidden = NO;
            }else{
                scopePeriodCell.isChoosedImg.hidden = YES;
            }
            
        }else{
            //判断是否是周末
            if ([self judgeisWeekends]) {
                scopePeriodCell.isChoosedImg.hidden = NO;
            }else{
                scopePeriodCell.isChoosedImg.hidden = YES;
            }
    
        }
        

        return scopePeriodCell;
        

        
    }else{
        NSArray* weekArray = @[NSLocalizedString(@"星期一", nil),NSLocalizedString(@"星期二", nil),NSLocalizedString(@"星期三", nil),NSLocalizedString(@"星期四", nil),NSLocalizedString(@"星期五", nil),NSLocalizedString(@"星期六", nil),NSLocalizedString(@"星期日", nil)];
        static NSString* periodCell_Identifier = @"periodCell_Identifier";
        SetChirldCell *periodCell = [tableView dequeueReusableCellWithIdentifier:periodCell_Identifier];
        if(!periodCell){
            periodCell = [[SetChirldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:periodCell_Identifier];
        }
        periodCell.titleLb.text = weekArray[row];
        
        if (self.periodStr.length != 0) {
            NSArray* arr = [self.periodStr componentsSeparatedByString:@","];
            if (_dataArray.count == 7) {
                periodCell.chooseBtn.selected = YES;
            }else{
                _dataArray = [NSMutableArray arrayWithArray:arr];
                for (NSString* str in arr) {
                    if ([str integerValue] ==  row+1) {
                        periodCell.chooseBtn.selected = YES;
                    }
                }
            }
            self.periodStr = @"";
        }else{

            if (_dataArray.count == 7) {
                periodCell.chooseBtn.selected = YES;
            }else{
                periodCell.chooseBtn.selected = NO;
                for (NSString* str in _dataArray) {
                    if ([str integerValue] ==  row+1) {
                        periodCell.chooseBtn.selected = YES;
                    }
                }
            }
            
        }
           return periodCell;
    }
    
 
}

#pragma mark - 判断是否是工作日
- (BOOL)judgeisWeekday
{
    if (self.periodStr.length != 0) {
        NSArray* arr = [self.periodStr componentsSeparatedByString:@","];
        _dataArray = [NSMutableArray arrayWithArray:arr];
        int i = 0;
        for (NSString *str in _dataArray) {
            if ([str intValue] == 1 || [str intValue] == 2 || [str intValue] == 3 || [str intValue] == 4 || [str intValue] == 5) {
                i++;
                }
            
        }
        
        //判断是否有勾选7天_dataArray
        if (_dataArray.count == 5 && i == 5) {
            return YES;
        }else{
            return NO;
        }
    }else{
        int i = 0;
        for (NSString *str in _dataArray) {
            if ([str intValue] == 1 || [str intValue] == 2 || [str intValue] == 3 || [str intValue] == 4 || [str intValue] == 5) {
                i++;
            }
        }
        
        //判断是否有勾选7天_dataArray
        if (_dataArray.count == 5 && i == 5) {
            return YES;
        }else{
            return NO;
        }
    }
}



#pragma mark - 判断是否是周末
- (BOOL)judgeisWeekends
{
    if (self.periodStr.length != 0) {
        NSArray* arr = [self.periodStr componentsSeparatedByString:@","];
        _dataArray = [NSMutableArray arrayWithArray:arr];
        int i = 0;
        for (NSString *str in _dataArray) {
            if ([str intValue] == 6 || [str intValue] == 7) {
                i++;
            }

        }
        
        //判断是否有勾选7天_dataArray
        if (_dataArray.count == 2 && i == 2) {
            return YES;
        }else{
            return NO;
        }
    }else{
        int i = 0;
        for (NSString *str in _dataArray) {
            if ([str intValue] == 6 || [str intValue] == 7) {
                i++;
            }
        }
        
        //判断是否有勾选7天_dataArray
        if (_dataArray.count == 2 && i == 2) {
            return YES;
        }else{
            return NO;
        }
    }
}


//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (section == 0) {
        if (row == 0) {
            [self selectAlldays];//选择7天
        }else if (row == 1){
            [self selectWeekdays];//选择工作日
        }else{
            [self selectWeekends];//选择周末
        }
    }else{
        SetChirldCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.chooseBtn.selected == NO) {
            cell.chooseBtn.selected = YES;
            [_dataArray addObject:_array[row]];
            //        NSLog(@"%@",_dataArray);
            [self.tv_list reloadData];//每次点击cell后都更新下数据源
        }else{
            cell.chooseBtn.selected = NO;
            [_dataArray removeObject:_array[row]];
            [self.tv_list reloadData];//每次点击cell后都更新下数据源
        }
    }

    
}





//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }else{
        return 20;
    }
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    if (section == 0) {
        UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 30)];
        tipLb.text = NSLocalizedString(@"快捷选择：", nil);
        tipLb.font = FONT(16);
        tipLb.textColor = RGB(100, 100, 100);
        [headView addSubview:tipLb];
    }else{
        UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 20)];
        tipLb.text = NSLocalizedString(@"时间选择：", nil);
        tipLb.font = FONT(16);
        tipLb.textColor = RGB(100, 100, 100);
        [headView addSubview:tipLb];
    }
    
    return headView;
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
