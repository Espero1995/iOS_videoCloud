//
//  FilerDeviceVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "FilerDeviceVC.h"
#import "FilerDeviceNameCell.h"//cell
#import "AlarmMsgVC.h"
#import "WeiCloudListModel.h"
@interface FilerDeviceVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    //传值数组
    NSMutableArray * _dataArray;
}
@property (nonatomic,strong) UITableView* tv_list;
@property (nonatomic,strong) NSMutableArray* deviceArr;
@property (nonatomic,strong) NSMutableArray *btnArr;//按钮选择状态的数组
@end

@implementation FilerDeviceVC
//=========================system=========================
#pragma mark ----- 生命周期 -----
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    [self setButtonitem];
    [self cteateNavBtn];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //移除多通道设备后的总设备列表
    NSArray *arr = [[unitl getAllDeviceCameraModel] copy];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < arr.count; i++) {
        dev_list *model = arr[i];
        if (model.device_class == 1) {
            [tempArr addObject:model];
        }
    }
    arr = [tempArr copy];
    
    NSString* userID = [unitl get_User_id];
    for (dev_list * dev_mList in arr) {
        
        if ([dev_mList.owner_id isEqualToString:userID]) {//判断是否是自己的设备 -> 改成 分享设备的alarm是否为1
            NSDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            [dic setValue:dev_mList.ID forKey:@"deviceID"];
            if ([dev_mList.name isEqualToString:@""]) {
                [dic setValue:dev_mList.type forKey:@"deviceName"];
            }else{
                [dic setValue:dev_mList.name forKey:@"deviceName"];
            }
            
            [self.deviceArr addObject:dic];
            
            
        }else{
            shareFeature *shareModel = dev_mList.ext_info.shareFeature;
                if ([shareModel.alarm intValue] == 1) {
                    NSDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                    [dic setValue:dev_mList.ID forKey:@"deviceID"];
                    if ([dev_mList.name isEqualToString:@""]) {
                        [dic setValue:dev_mList.type forKey:@"deviceName"];
                    }else{
                        [dic setValue:dev_mList.name forKey:@"deviceName"];
                    }
                    [self.deviceArr addObject:dic];
                }

        }
    
    }
    
//    NSLog(@"mydevice:%@",self.deviceArr);
    
    if (self.myResultDeviceArr.count == 0) {
        self.navigationItem.title = NSLocalizedString(@"选择设备", nil);
        //按钮的选择状态
        for (int i = 0; i<self.deviceArr.count; i++) {
            NSString * btnStr = [NSString stringWithFormat:@"NO"];
            [self.btnArr addObject:btnStr];
        }
        
    }else{
        self.navigationItem.title = [NSString stringWithFormat:@"%@%lu)",NSLocalizedString(@"选择设备", nil),(unsigned long)self.myResultDeviceArr.count];
        [self.btnArr removeAllObjects];
        
        
        NSMutableArray *totalArr = [NSMutableArray arrayWithCapacity:0];
        //按钮的选择状态
        for (int i = 0; i<self.deviceArr.count; i++) {
            [totalArr addObject:self.deviceArr[i][@"deviceName"]];
        }
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
       for (int i = 0; i<self.myResultDeviceArr.count; i++) {
           [tempArr addObject:self.myResultDeviceArr[i][@"deviceName"]];
        }
        [self compareArr:totalArr and:tempArr];
    
        _dataArray = [NSMutableArray arrayWithArray:self.myResultDeviceArr];
        
    }
    
    [self.view addSubview:self.tv_list];
}

//对应取出已经有筛选了数组
- (void)compareArr:(NSMutableArray *)totalArr and:(NSMutableArray *)tempArr
{
    for (NSString *str in totalArr) {
        if ([tempArr containsObject: str]) {
            [self.btnArr addObject:@"YES"];
        }else{
            [self.btnArr addObject:@"NO"];
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//=========================init=========================
#pragma mark ----- 页面初始化的一些方法 -----
#pragma mark - 设置导航栏按钮和响应事件
- (void)setButtonitem
{
    UIButton* saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [saveBtn setTitle:NSLocalizedString(@"完成了", nil) forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveDevice) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.userInteractionEnabled = YES;
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItems = @[rightItem];
}
//=========================method=========================
#pragma mark ----- 方法 -----
#pragma mark - 保存设备名称并传值回筛选界面
- (void)saveDevice
{
    if (_dataArray.count == 0) {
        [XHToast showCenterWithText:NSLocalizedString(@"请选择一种设备!", nil)];
    }else{
        AlarmMsgVC* alarmNewVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        alarmNewVC.myResultDeviceArr = _dataArray;
        [self.navigationController popToViewController:alarmNewVC animated:YES];
    }
}



//=========================delegate=========================
#pragma mark ----- 代理协议 -----
#pragma mark - tableview的代理方法
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArr.count;
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString* filerDeviceCell_Identifier = @"filerDeviceCell_Identifier";
    FilerDeviceNameCell* filerDeviceCell = [tableView dequeueReusableCellWithIdentifier:filerDeviceCell_Identifier];
    if(filerDeviceCell == nil){
        filerDeviceCell = [[FilerDeviceNameCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:filerDeviceCell_Identifier];
    }
    
    filerDeviceCell.deviceNameLb.text = self.deviceArr[indexPath.row][@"deviceName"];
    
    //判断是否打钩
    if ([self.btnArr[row] isEqualToString:@"YES"]) {
        filerDeviceCell.chooseBtn.selected = YES;
    }else{
         filerDeviceCell.chooseBtn.selected = NO;
    }
    
   
    return filerDeviceCell;
}
//cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    FilerDeviceNameCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.chooseBtn.selected == NO) {
        cell.chooseBtn.selected = YES;
        [_dataArray addObject:self.deviceArr[indexPath.row]];
        self.navigationItem.title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"选择设备", nil),(unsigned long)_dataArray.count];
    }else{
        cell.chooseBtn.selected = NO;
        [_dataArray removeObject:self.deviceArr[indexPath.row]];
        if (_dataArray.count == 0) {
            self.navigationItem.title = NSLocalizedString(@"选择设备", nil);
        }else{
            self.navigationItem.title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"选择设备", nil),(unsigned long)_dataArray.count];
        }
    }
    
    if ([self.btnArr[row] isEqualToString:@"NO"]) {
        NSString * btnStr = [NSString stringWithFormat:@"YES"];
        [self.btnArr replaceObjectAtIndex:row withObject:btnStr];
    }else{
        NSString * btnStr = [NSString stringWithFormat:@"NO"];
        [self.btnArr replaceObjectAtIndex:row withObject:btnStr];
    }
}


//=========================lazy loadiing=========================
#pragma mark - getter&&setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-64) style:UITableViewStylePlain];
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        //设置代理
        self.tv_list.delegate = self;
        self.tv_list.dataSource = self;
    }
    return _tv_list;
}

-(NSMutableArray *)deviceArr
{
    if (!_deviceArr) {
        _deviceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _deviceArr;
}
//按钮选择状态的数组
- (NSMutableArray *)btnArr
{
    if (!_btnArr) {
        _btnArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _btnArr;
}
@end
