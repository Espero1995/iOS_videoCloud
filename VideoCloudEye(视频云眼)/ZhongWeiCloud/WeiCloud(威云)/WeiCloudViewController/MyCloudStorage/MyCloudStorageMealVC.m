//
//  MyCloudStorageMealVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/26.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MyCloudStorageMealVC.h"
#import "ZCTabBarController.h"
/*我的云存套餐的cell*/
#import "MyCloudMealCell.h"
/**我的云存套餐头部提示的cell*/
#import "MyCloudMealTipCell.h"
/*套餐记录model*/
#import "MealRecordModel.h"
@interface MyCloudStorageMealVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    MyCloudMealCellDelegate
>

/*表视图*/
@property (strong, nonatomic) IBOutlet UITableView *tv_list;

@end

@implementation MyCloudStorageMealVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"我的云存套餐", nil);
    [self cteateNavBtn];
    self.view.backgroundColor = BG_COLOR;
    self.tv_list.backgroundColor = BG_COLOR;
    self.tv_list.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//==========================init==========================

//==========================method==========================
/**
 * description 输入字符串返回时间格式化的时间字符串方法
 * 默认:返回的是以秒为单位，若为毫秒:则进行interval/1000操作。
 */
- (NSString *)backFormatterTime:(NSString *)time{
    NSTimeInterval interval = [time doubleValue];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *newTimeStr = [formatter stringFromDate:startDate];
    return newTimeStr;
}
//==========================delegate==========================
//组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orderRecordArr.count+1;
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
    if (section == 0) {
        static NSString *MyCloudMealTipCell_Identifier=@"MyCloudMealTipCell_Identifier";
        MyCloudMealTipCell *cell=[tableView dequeueReusableCellWithIdentifier:MyCloudMealTipCell_Identifier];
        if (cell==nil) {
            [tableView registerNib:[UINib nibWithNibName:@"MyCloudMealTipCell" bundle:nil] forCellReuseIdentifier:MyCloudMealTipCell_Identifier];
            cell=[tableView dequeueReusableCellWithIdentifier:MyCloudMealTipCell_Identifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (_orderRecordArr.count == 0) {
            cell.tipInfo_lb.text = NSLocalizedString(@"暂无可用的套餐", nil);
        }else{
            cell.tipInfo_lb.text = NSLocalizedString(@"当前“第一个套餐”已生效", nil);//'立即使用'仅针对第一个待生效套餐开放
        }

        return cell;
    }else{
        static NSString *MyCloudMealCell_Identifier=@"MyCloudMealCell_Identifier";
        MyCloudMealCell *cell=[tableView dequeueReusableCellWithIdentifier:MyCloudMealCell_Identifier];
        if (cell==nil) {
            [tableView registerNib:[UINib nibWithNibName:@"MyCloudMealCell" bundle:nil] forCellReuseIdentifier:MyCloudMealCell_Identifier];
            cell=[tableView dequeueReusableCellWithIdentifier:MyCloudMealCell_Identifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (section == 1) {
            cell.extendedUserBtn.hidden = YES;
            cell.cellDelegate = self;
        }else{
            cell.extendedUserBtn.hidden = YES;
        }
        MealRecordModel *model = [_orderRecordArr objectAtIndex:indexPath.section-1];
        cell.mealPlan_lb.text = model.plan_info;
        NSString *startTime = [NSString stringWithFormat:@"%d",model.start_date];
        cell.effectiveDate_lb.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"生效时间", nil),[self backFormatterTime:startTime]];
        return cell;
    }
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    if (section == 0) {
        return 44;
    }else{
        return 70;
    }
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else if(section == 1){
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
    return headView;
}

#pragma maek ----- 立即使用点击按钮
-(void)MyCloudMealCellExtendedUserClick{
    [XHToast showCenterWithText:NSLocalizedString(@"已使用", nil)];
}
//==========================lazy loading==========================
#pragma mark ------懒加载成员变量
@end
