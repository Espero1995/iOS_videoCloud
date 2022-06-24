//
//  MyCloudStorageVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/25.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MyCloudStorageVC.h"
#import "ZCTabBarController.h"
/*云存储cell*/
#import "MyCloudStorageCell.h"
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
/*我的云存储套餐界面(续费)*/
#import "MyCloudStorageMealVC.h"
/*套餐记录*/
#import "MealRecordModel.h"
/*未购买云存套餐的cell*/
#import "CloudStorageCell.h"
/*开通云存套餐*/
#import "CloudStorageNewVC.h"
@interface MyCloudStorageVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    MyCloudStorageCellDelegate,
    CloudStorageCellDelegate
>
{
    /*存储套餐记录*/
    NSMutableArray *_tempArr;
}
/*表视图*/
@property (strong, nonatomic) IBOutlet UITableView *tv_list;
/*有套餐信息的设备信息*/
@property (nonatomic,strong) CloudStorageValueModel *PlanedDeviceModel;
/*有套餐信息的数据源*/
@property (nonatomic,strong) NSMutableArray *PlanedDeviceDataArr;
@end

@implementation MyCloudStorageVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"设备云存储", nil);
    [self cteateNavBtn];
    self.view.backgroundColor = BG_COLOR;
    self.tv_list.backgroundColor = BG_COLOR;
    self.tv_list.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];

    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getCloudStorageList)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
    _tempArr = [NSMutableArray arrayWithCapacity:0];//初始化
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    
    if (self.isRefresh) {
        //下拉刷新
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getCloudStorageList)];
        [header beginRefreshing];
        self.tv_list.mj_header = header;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//==========================init==========================


//==========================method==========================
#pragma mark - 获取云存数据
//获取云存数据
- (void)getCloudStorageList{
    NSMutableDictionary * postDic = [[NSMutableDictionary alloc]initWithCapacity:0];
    [postDic setObject:self.deviceId forKey:@"device_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/cloudplans/device" parameters:postDic IsToken:YES success:^(id responseObject) {
//        NSLog(@"responseObejct:%@",responseObject);
        
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSArray *tempArr = responseObject[@"body"][@"recording_plans"];
            if (tempArr.count == 0) {//显示的全部都是我的设备
                
                [self.tv_list.mj_header endRefreshing];
            }else{//显示的是我的设备+有套餐的信息
                self.PlanedDeviceDataArr = [CloudStorageValueModel mj_objectArrayWithKeyValuesArray:tempArr];
                 _tempArr=[MealRecordModel mj_objectArrayWithKeyValuesArray:tempArr];
//                NSLog(@"显示的是我的设备+有套餐的信息:%@",self.PlanedDeviceDataArr);
                
                [self.tv_list reloadData];
                [self.tv_list.mj_header endRefreshing];
            }
        }
        if ([_tv_list.mj_header isRefreshing]) {
            [_tv_list.mj_header endRefreshing];
        }
       
    } failure:^(NSError *error) {
       // NSLog(@"失败了:error:%@",error);
        [self.tv_list.mj_header endRefreshing];
    }];
    
}

//==========================delegate==========================
//组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.PlanedDeviceDataArr.count == 0) {
        return 2;
    }else{
        return 2;
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
    if (self.PlanedDeviceDataArr.count == 0) {//无设备时
        if (section == 0) {
            static NSString *CloudStorageCell_Identifier=@"CloudStorageCell_Identifier";
            CloudStorageCell *cell=[tableView dequeueReusableCellWithIdentifier:CloudStorageCell_Identifier];
            if (cell==nil) {
                [tableView registerNib:[UINib nibWithNibName:@"CloudStorageCell" bundle:nil] forCellReuseIdentifier:CloudStorageCell_Identifier];
                cell=[tableView dequeueReusableCellWithIdentifier:CloudStorageCell_Identifier];
            }
            cell.deviceName_lb.text = self.deviceName;
            NSString *tempImgUrl = [NSString stringWithFormat:@"%@2.png",self.deviceImgUrl];
            [cell.device_Img sd_setImageWithURL:[NSURL URLWithString:tempImgUrl] placeholderImage:[UIImage imageNamed:@"smallCloudPic"]];
            cell.toDateTip_lb.text = NSLocalizedString(@"当前状态:", nil);
            cell.mealTime_lb.text = NSLocalizedString(@"未开通", nil);
            cell.mealType_lb.hidden = YES;
            cell.currentStausTip_lb.hidden = YES;
            
             [cell.openCloud_btn setTitle:NSLocalizedString(@"立即开通", nil) forState:UIControlStateNormal];
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.cellDelegate = self;
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
        if (section == 1) {
            static NSString *showCloudStorageCell_Identifier=@"showCloudStorageCell_Identifier";
            showCloudStorageCell *cell=[tableView dequeueReusableCellWithIdentifier:showCloudStorageCell_Identifier];
            if (cell==nil) {
                [tableView registerNib:[UINib nibWithNibName:@"showCloudStorageCell" bundle:nil] forCellReuseIdentifier:showCloudStorageCell_Identifier];
                cell=[tableView dequeueReusableCellWithIdentifier:showCloudStorageCell_Identifier];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            static NSString *MyCloudStorageCell_Identifier=@"MyCloudStorageCell_Identifier";
            MyCloudStorageCell *cell=[tableView dequeueReusableCellWithIdentifier:MyCloudStorageCell_Identifier];
            if (cell==nil) {
                [tableView registerNib:[UINib nibWithNibName:@"MyCloudStorageCell" bundle:nil] forCellReuseIdentifier:MyCloudStorageCell_Identifier];
                cell=[tableView dequeueReusableCellWithIdentifier:MyCloudStorageCell_Identifier];
            }
            
            CloudStorageValueModel *planModel = [self.PlanedDeviceDataArr objectAtIndex:section];
            cell.deviceName_lb.text = self.deviceName;
            cell.mealType_lb.text = planModel.plan_info;
            cell.mealType_lb.hidden = NO;
            cell.currentStausTip_lb.hidden = NO;
            cell.currentStausTip_lb.text = NSLocalizedString(@"当前套餐:", nil);
            NSLog(@"stop_date:%@",planModel.stop_date);
            
            NSTimeInterval time=[planModel.stop_date doubleValue];//因为时差问题要加8小时 == 28800 sec
            NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
            //实例化一个NSDateFormatter对象
            NSDateFormatter * timeWeek = [[NSDateFormatter alloc]init];
            //设定时间格式,这里可以设置成自己需要的格式
            [timeWeek setDateFormat:@"yyyy-MM-dd"];
            NSString *currentWeekStr = [timeWeek stringFromDate: detaildate];
            cell.mealTime_lb.text = currentWeekStr;
            
             NSString *tempImgUrl = [NSString stringWithFormat:@"%@2.png",self.deviceImgUrl];
            [cell.device_Img sd_setImageWithURL:[NSURL URLWithString:tempImgUrl] placeholderImage:[UIImage imageNamed:@"smallCloudPic"]];
            
            if (self.PlanedDeviceDataArr.count == 1) {
                cell.nextMealEffect_lb.text = NSLocalizedString(@"暂无多余套餐购买记录", nil);
            }else{
                cell.nextMealEffect_lb.text = [NSString stringWithFormat:@"%lu%@",(unsigned long)self.PlanedDeviceDataArr.count-1,NSLocalizedString(@"个套餐未生效", nil)];
            }
            
            if (self.PlanedDeviceDataArr.count >1) {
                CloudStorageValueModel *tempPlanModel = (CloudStorageValueModel *)self.PlanedDeviceDataArr[1];
                cell.nextMealType_lb.text = tempPlanModel.plan_info;
            }else{
                cell.nextMealType_lb.text = NSLocalizedString(@"无", nil);
            }
            
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.cellDelegate = self;
            return cell;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.PlanedDeviceDataArr.count == 0) {
        if (indexPath.section == 0) {
            return 100;
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
        if (indexPath.section == 0) {
            return 150;
        }else{
            if (iPhoneWidth<=320) {
                return 540;
            }else if (iPhoneWidth == 375){
                return 590;
            }else{
                return 640;
            }

        }
    }
   
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (self.PlanedDeviceDataArr.count == 0) {
//        return 0;
//    }else{
        if (section == 0) {
            return 20;
        }else{
            return 10;
        }
//    }
    
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    return headView;
}

//cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.PlanedDeviceDataArr.count != 0) {
        if (section == 0) {
            MyCloudStorageMealVC *myMeal = [[MyCloudStorageMealVC alloc]init];
             myMeal.orderRecordArr = _tempArr;//传入云存储购买记录
            [self.navigationController pushViewController:myMeal animated:YES];
        }
    }
    
}


#pragma mark ----- 续费或者开通的按钮
- (void)MyCloudStorageCellExtendedUserClick
{
    CloudStorageController *cloud=[[CloudStorageController alloc]init];
    cloud.deviceID = self.deviceId;
    cloud.orderRecordArr = _tempArr;//传入云存储购买记录
    [self.navigationController pushViewController:cloud animated:YES];
}

#pragma mark ----- 立即开通的按钮
- (void)CloudStorageCellOpenCloudClick:(CloudStorageCell *)cell
{
//    NSIndexPath * indexPath = [self.tv_list indexPathForCell:cell];
    CloudStorageNewVC *cloud=[[CloudStorageNewVC alloc]init];
    cloud.deviceID = self.deviceId;
    [self.navigationController pushViewController:cloud animated:YES];
}
//==========================lazy loading==========================
#pragma mark ------懒加载成员变量
//有套餐信息的数据源
-(NSMutableArray *)PlanedDeviceDataArr{
    if (!_PlanedDeviceDataArr) {
        _PlanedDeviceDataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _PlanedDeviceDataArr;
}

@end
