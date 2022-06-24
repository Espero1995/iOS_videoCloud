//
//  MyAllCloudStorageVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/11.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MyAllCloudStorageVC.h"
#import "ZCTabBarController.h"
/*云存储cell*/
#import "CloudStorageCell.h"
/*云存储展示的cell*/
#import "showCloudStorageCell.h"
/*我的设备的model*/
#import "WeiCloudListModel.h"
/*有套餐的设备的model*/
#import "CloudStorageValueModel.h"
/*无设备时的cell*/
#import "NoDataCell.h"
/*续费界面*/
#import "CloudStorageController.h"
#import "CloudStorageNewVC.h"
#import "OrderRecordController.h"//订单界面
//套餐记录model
#import "MealRecordModel.h"
@interface MyAllCloudStorageVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    CloudStorageCellDelegate
>
/*表视图*/
@property (strong, nonatomic) IBOutlet UITableView *tv_list;
/*TableView头部的提示信息*/
@property (nonatomic,strong) UILabel *tipTitleLb;
/*我的设备列表*/
@property (nonatomic,strong) NSArray *myDeviceListArr;
/*云存套餐列表Arr*/
@property (nonatomic,strong) NSMutableArray *devicePlanedArr;
@end

@implementation MyAllCloudStorageVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"设备云存储", nil);
    [self cteateNavBtn];
    self.view.backgroundColor = BG_COLOR;
    
    
    //拿到我的有云存功能的设备数组【不包括多通道设备】
    self.myDeviceListArr = [[unitl getAllDeviceCameraModel] copy];
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.myDeviceListArr.count; i++) {
        dev_list *model = self.myDeviceListArr[i];
        if (model.device_class == 1) {
            [tempArr addObject:model];
        }
    }
    self.myDeviceListArr = [tempArr copy];
    
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getCloudStorageList)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
    self.tv_list.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

//==========================init==========================

//==========================method==========================
#pragma mark - 获取云存数据
- (void)getCloudStorageList
{
    [self.devicePlanedArr removeAllObjects];
    NSMutableDictionary * postDic = [[NSMutableDictionary alloc]initWithCapacity:0];
    [postDic setObject:@"" forKey:@"device_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/cloudplans/batchdevice" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"获取云存数据responseObejct:%@",responseObject);
        
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
            tempDic = responseObject[@"body"];
            [self getMyAllCloudStorageList:tempDic];//获取我的云存列表
        }
        
        if ([_tv_list.mj_header isRefreshing]) {
            [_tv_list.mj_header endRefreshing];
        }

        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
        [self.tv_list.mj_header endRefreshing];
    }];
}

#pragma mark - 获取我的云存列表
- (void)getMyAllCloudStorageList:(NSMutableDictionary *)tempDic
{
//    NSLog(@"tempDic:%@",tempDic);
    for (int i = 0 ; i < self.myDeviceListArr.count; i++) {
        dev_list *deviceModel = self.myDeviceListArr[i];
//        NSLog(@"ID:%@",deviceModel.ID);
        if (tempDic[deviceModel.ID]) {
            NSLog(@"tempDic[deviceModel.ID]：%@",tempDic[deviceModel.ID]);
            NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
            tempArr = tempDic[deviceModel.ID];
            
            if (tempArr.count == 0) {
                CloudStorageValueModel *cloudModel = [[CloudStorageValueModel alloc]init];
                cloudModel.device_id = deviceModel.ID;
                cloudModel.dev_name = deviceModel.name;
                cloudModel.dev_image = [NSString stringWithFormat:@"%@2.png",deviceModel.ext_info.dev_img];
                cloudModel.plan_info = NSLocalizedString(@"未开通", nil);
                [self.devicePlanedArr addObject:cloudModel];
            }else{
//                CloudStorageValueModel *cloudModel = [CloudStorageValueModel mj_objectWithKeyValues:tempArr[0]];
                CloudStorageValueModel *cloudModel = [self compareTimeGetCurrentCloudPlan:tempArr];
                cloudModel.dev_image = [NSString stringWithFormat:@"%@2.png",deviceModel.ext_info.dev_img];
                [self.devicePlanedArr addObject:cloudModel];
            }
            
        }
        
    }
    
    [self.tv_list reloadData];
}


//比较时间戳获取当前处于的套餐
- (CloudStorageValueModel *)compareTimeGetCurrentCloudPlan:(NSArray *)tempArr
{
    NSArray *modelArr = [CloudStorageValueModel mj_objectArrayWithKeyValuesArray:tempArr];
    CloudStorageValueModel *model = [[CloudStorageValueModel alloc]init];
    if (tempArr.count == 1) {
        CloudStorageValueModel *cloudModel = modelArr[0];
        model = cloudModel;
    }else{
 
        for (CloudStorageValueModel *cloudModel in modelArr) {
            NSLog(@"时间戳：%@时间戳：%@，当前时间戳：%@",cloudModel.start_date,cloudModel.stop_date,[unitl getNowTimeTimestamp]);
            
            if ([[unitl getNowTimeTimestamp] longLongValue] > [cloudModel.start_date longLongValue] && [[unitl getNowTimeTimestamp] longLongValue] < [cloudModel.stop_date longLongValue]) {
                model = cloudModel;
            }

        }
    }
    
    return model;
    
}




//==========================delegate==========================
//组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.devicePlanedArr.count == 0) {
        return 2;
    }else{
        return self.devicePlanedArr.count+1;
    }
}
//行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//cell样式
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (self.devicePlanedArr.count == 0) {//无设备时
        if (section == 0) {
            static NSString *NoDataCell_Identifier=@"NoDataCell_Identifier";
            NoDataCell *cell=[tableView dequeueReusableCellWithIdentifier:NoDataCell_Identifier];
            if (cell==nil) {
                [tableView registerNib:[UINib nibWithNibName:@"NoDataCell" bundle:nil] forCellReuseIdentifier:NoDataCell_Identifier];
                cell=[tableView dequeueReusableCellWithIdentifier:NoDataCell_Identifier];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            static NSString *showCloudStorageCell_Identifier=@"showCloudStorageCell_Identifier";
            showCloudStorageCell *cell=[tableView dequeueReusableCellWithIdentifier:showCloudStorageCell_Identifier];
            if (cell==nil) {
                [tableView registerNib:[UINib nibWithNibName:@"showCloudStorageCell" bundle:nil] forCellReuseIdentifier:showCloudStorageCell_Identifier];
                cell=[tableView dequeueReusableCellWithIdentifier:showCloudStorageCell_Identifier];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        
    }else{//有设备时
        if (section == self.devicePlanedArr.count) {
            static NSString *showCloudStorageCell_Identifier=@"showCloudStorageCell_Identifier";
            showCloudStorageCell *cell=[tableView dequeueReusableCellWithIdentifier:showCloudStorageCell_Identifier];
            if (cell==nil) {
                [tableView registerNib:[UINib nibWithNibName:@"showCloudStorageCell" bundle:nil] forCellReuseIdentifier:showCloudStorageCell_Identifier];
                cell=[tableView dequeueReusableCellWithIdentifier:showCloudStorageCell_Identifier];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            
            static NSString *CloudStorageCell_Identifier=@"CloudStorageCell_Identifier";
            CloudStorageCell *cell=[tableView dequeueReusableCellWithIdentifier:CloudStorageCell_Identifier];
            if (cell==nil) {
                [tableView registerNib:[UINib nibWithNibName:@"CloudStorageCell" bundle:nil] forCellReuseIdentifier:CloudStorageCell_Identifier];
                cell=[tableView dequeueReusableCellWithIdentifier:CloudStorageCell_Identifier];
            }
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            CloudStorageValueModel *planModel = self.devicePlanedArr[section];
            if ([planModel.plan_info isEqualToString:NSLocalizedString(@"未开通", nil)]) {
                cell.currentStausTip_lb.hidden = YES;
                cell.toDateTip_lb.text = NSLocalizedString(@"当前状态:", nil);
                cell.mealType_lb.hidden = YES;
                cell.mealTime_lb.text = NSLocalizedString(@"未开通", nil);
                [cell.openCloud_btn setTitle:NSLocalizedString(@"立即开通", nil) forState:UIControlStateNormal];
            }else{
                cell.mealType_lb.hidden = NO;
                cell.mealType_lb.text = planModel.plan_info;
                cell.currentStausTip_lb.text = NSLocalizedString(@"当前套餐:", nil);
                cell.toDateTip_lb.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"到期时间", nil)];
                cell.currentStausTip_lb.hidden = NO;
                [cell.openCloud_btn setTitle:NSLocalizedString(@"立即续费", nil) forState:UIControlStateNormal];
                
                //到期时间
                NSTimeInterval time=[planModel.stop_date doubleValue];//因为时差问题要加8小时 == 28800 sec
                NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
                //实例化一个NSDateFormatter对象
                NSDateFormatter * timeWeek = [[NSDateFormatter alloc]init];
                //设定时间格式,这里可以设置成自己需要的格式
                [timeWeek setDateFormat:@"yyyy-MM-dd"];
                NSString *currentWeekStr = [timeWeek stringFromDate: detaildate];
                cell.mealTime_lb.text = currentWeekStr;
            }

            cell.deviceName_lb.text = planModel.dev_name;
            [cell.device_Img sd_setImageWithURL:[NSURL URLWithString:planModel.dev_image] placeholderImage:[UIImage imageNamed:@"smallCloudPic"]];
            
            cell.cellDelegate = self;
            return cell;
            
        }
    
        
    }

}

//cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.devicePlanedArr.count == 0) {
        if (indexPath.section == 0) {
            return 50;
        }else{
            if (iPhoneWidth<=320) {
                return 540;
            }else if (iPhoneWidth == 375){
                return 590;
            }else{
                return 640;
            }
            
        }
    }else{
        if(indexPath.section == self.devicePlanedArr.count){
            if (iPhoneWidth<=320) {
                return 540;
            }else if (iPhoneWidth == 375){
                return 590;
            }else{
                return 640;
            }
        }else{
            return 105;
        }
    }
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.devicePlanedArr.count == 0) {
        return 0;
    }else{
        if (section == 0) {
            return 30;
        }else if(section == self.devicePlanedArr.count){
            return 10;
        }else{
            return 5;
        }
    }
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    if (section == 0) {
        //提示信息
        self.tipTitleLb.frame = CGRectMake(10, 0, self.view.frame.size.width, 30);
        self.tipTitleLb.text = NSLocalizedString(@"支持云存储设备列表", nil);
        self.tipTitleLb.font = FONT(14);
        [headView addSubview:self.tipTitleLb];
    }
    return headView;
}


//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 1 && self.devicePlanedArr.count == 0) {
        return;
    }
    
    if (section == self.devicePlanedArr.count) {
        return;
    }else{
        CloudStorageValueModel *deviceModel = self.devicePlanedArr[indexPath.section];
        [self getCloudStorageListID:deviceModel.device_id];
    }
    
}


#pragma mark ----- 续费或者开通的按钮
- (void)CloudStorageCellOpenCloudClick:(CloudStorageCell *)cell
{
    NSIndexPath * indexPath = [self.tv_list indexPathForCell:cell];
    CloudStorageNewVC *cloud=[[CloudStorageNewVC alloc]init];
    CloudStorageValueModel *deviceModel = self.devicePlanedArr[indexPath.section];
//    NSLog(@"deviceModel:%@",deviceModel.device_id);
    cloud.deviceID = deviceModel.device_id;
    [self.navigationController pushViewController:cloud animated:YES];
}


- (void)getCloudStorageListID:(NSString *)ID{
    NSMutableDictionary * postDic = [[NSMutableDictionary alloc]initWithCapacity:0];
    [postDic setObject:ID forKey:@"device_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/cloudplans/device" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObejct:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSArray *tempArr = responseObject[@"body"][@"recording_plans"];
            NSMutableArray *newTempArr = [NSMutableArray arrayWithCapacity:0];
            newTempArr=[MealRecordModel mj_objectArrayWithKeyValuesArray:tempArr];
            OrderRecordController *order = [[OrderRecordController alloc]init];
            order.orderRecordArr = newTempArr;
            [self.navigationController pushViewController:order animated:YES];
        }else{
            NSLog(@"失败了");
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
        
    }];
    
}

//==========================lazy loading==========================
#pragma mark ----- 懒加载
- (UILabel *)tipTitleLb{
    if (!_tipTitleLb) {
        _tipTitleLb = [[UILabel alloc]init];
    }
    return _tipTitleLb;
}

//我的设备列表
-(NSArray *)myDeviceListArr{
    if (!_myDeviceListArr) {
        _myDeviceListArr = [NSArray array];
    }
    return _myDeviceListArr;
}

//云存套餐列表Arr
- (NSMutableArray *)devicePlanedArr
{
    if (!_devicePlanedArr) {
        _devicePlanedArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _devicePlanedArr;
}


@end
