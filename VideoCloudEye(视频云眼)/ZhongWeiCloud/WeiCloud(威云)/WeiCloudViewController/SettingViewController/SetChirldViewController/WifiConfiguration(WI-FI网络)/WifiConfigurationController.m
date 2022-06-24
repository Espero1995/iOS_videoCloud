//
//  WifiConfigurationController.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/4/11.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WifiConfigurationController.h"
#import "wifiCell.h"
#import "confirmView.h"
#import "ScottAlertViewController.h"
#import "wifiModel.h"
#import "NSDictionaryEX.h"
#import "UIView+ScottAlertView.h"
#import "wifiOwnCell.h"
#import "BaseTableView.h"
@interface WifiConfigurationController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    confirmViewDelegate
>
/**
 * 展示wifi列表
 */
@property (nonatomic, strong) UITableView* wifiTabView;
/**
 * 数据源
 */
@property (nonatomic, strong) NSMutableArray* wifiDataArr;
/**
 * 记录点击的cell
 */
@property (nonatomic, assign) NSInteger indexRow;

@end

@implementation WifiConfigurationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cteateNavBtn];
    [self createUI];
    self.navigationItem.title = NSLocalizedString(@"设备WI-FI", nil);
    self.view.backgroundColor = BG_COLOR;
}

- (void)createUI
{
    [self.view addSubview:self.wifiTabView];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadWifiData)];
    [header beginRefreshing];
    self.wifiTabView.mj_header = header;
}

- (void)loadWifiData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/devicewifi/getWLanConfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"获取wifi设备：responseObject:%@",responseObject);
        if (ret == 0) {
            [self.wifiDataArr removeAllObjects];
            NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
            NSDictionary * tempDic = (NSDictionary *)responseObject;
            tempArr = [tempDic safeObjectForKey:@"body"];
            
            if (tempArr.count != 0) {
                for (int i = 0; i < tempArr.count; i++) {
                    wifiModel * model = [[wifiModel alloc]init];
                    model.password = tempArr[i][@"password"];
                    model.ssid = tempArr[i][@"ssid"];
                    model.intensity = tempArr[i][@"intensity"];
                    model.auth = tempArr[i][@"auth"];
                    model.inuse = tempArr[i][@"inuse"];
                    [self.wifiDataArr addObject:model];
                }
            }
            
            [self.wifiTabView reloadData];

            [self.wifiTabView.mj_header endRefreshing];
        }else{
            [self.wifiTabView.mj_header endRefreshing];
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"获取wifi设备：responseObject数据失败，关闭刷新");
        [self.wifiTabView reloadData];
        [self.wifiTabView.mj_header endRefreshing];
    }];
}

#pragma mark ==== tableviewDelegate
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.wifiDataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* wifiConfiguration_one_Identifier = @"wifiConfiguration_one_Identifier";
    wifiOwnCell* Cell_one = [_wifiTabView dequeueReusableCellWithIdentifier:wifiConfiguration_one_Identifier];
    if(Cell_one == nil){
        [_wifiTabView registerNib:[UINib nibWithNibName:@"wifiOwnCell" bundle:nil] forCellReuseIdentifier:wifiConfiguration_one_Identifier];
        Cell_one = [tableView dequeueReusableCellWithIdentifier:wifiConfiguration_one_Identifier];
    }
        if (self.wifiDataArr.count > 0) {
            wifiModel * model = self.wifiDataArr[indexPath.row];
            Cell_one.wifiName.text = model.ssid;
            if ([model.auth integerValue]== 0) {
                if ([model.intensity integerValue] == 1 || [model.intensity integerValue]== 2) {
                    Cell_one.wifiImage.image = [UIImage imageNamed:@"wifi_1"];
                }else if ([model.intensity integerValue] == 2 || [model.intensity integerValue] == 3)
                {
                    Cell_one.wifiImage.image = [UIImage imageNamed:@"wifi_2"];
                }else
                {
                    Cell_one.wifiImage.image = [UIImage imageNamed:@"wifi_image_unlock"];
                }
            }else{
                if ([model.intensity integerValue] == 1 || [model.intensity integerValue]== 2) {
                    Cell_one.wifiImage.image = [UIImage imageNamed:@"wifi_11"];
                }else if ([model.intensity integerValue] == 2 || [model.intensity integerValue] == 3)
                {
                    Cell_one.wifiImage.image = [UIImage imageNamed:@"wifi_22"];
                }else
                {
                    Cell_one.wifiImage.image = [UIImage imageNamed:@"wifi_image_lock"];
                }
            }
            
            if (model.inuse) {
                if ([model.inuse intValue] == 1) {
                    Cell_one.currentLink.hidden = NO;
                }else{
                    Cell_one.currentLink.hidden = YES;
                }
            }else{
                Cell_one.currentLink.hidden = YES;
            }
            
         
            
    }
    return Cell_one;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexRow = (NSInteger)indexPath.row;
    wifiModel * model = self.wifiDataArr[indexPath.row];
    
    
    if (model.inuse) {
        if ([model.inuse intValue] == 1) {
            
        }else{
            confirmView * confirmActionSheet = [confirmView viewFromXib];
            confirmActionSheet.delegate = self;
            wifiModel * model = self.wifiDataArr[indexPath.row];
            
            if (model.ssid.length > 15) {
                NSString *wifiNameStr = [model.ssid substringToIndex:15];
                confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"%@\"%@...\"%@",NSLocalizedString(@"请输入", nil),wifiNameStr,NSLocalizedString(@"的密码", nil)];
            }else{
                confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"%@\"%@\"%@",NSLocalizedString(@"请输入", nil),model.ssid,NSLocalizedString(@"的密码", nil)];
            }
            
            ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:confirmActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }else{
        confirmView * confirmActionSheet = [confirmView viewFromXib];
        confirmActionSheet.delegate = self;
        wifiModel * model = self.wifiDataArr[indexPath.row];
        
        if (model.ssid.length > 15) {
            NSString *wifiNameStr = [model.ssid substringToIndex:15];
            confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"%@\"%@...\"%@",NSLocalizedString(@"请输入", nil),wifiNameStr,NSLocalizedString(@"的密码", nil)];
        }else{
            confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"%@\"%@\"%@",NSLocalizedString(@"请输入", nil),model.ssid,NSLocalizedString(@"的密码", nil)];
        }
        
        ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:confirmActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
//    if (model.inuse && [model.inuse intValue] == 1) {
//
//    }else{
//        confirmView * confirmActionSheet = [confirmView viewFromXib];
//        confirmActionSheet.delegate = self;
//        wifiModel * model = self.wifiDataArr[indexPath.row];
//
//        if (model.ssid.length > 15) {
//            NSString *wifiNameStr = [model.ssid substringToIndex:15];
//            confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"请输入\"%@...\"的密码",wifiNameStr];
//        }else{
//            confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"请输入\"%@\"的密码",model.ssid];
//        }
//
//        ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:confirmActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
    
    
//    if ([model.inuse intValue] == 0) {
//        confirmView * confirmActionSheet = [confirmView viewFromXib];
//        confirmActionSheet.delegate = self;
//        wifiModel * model = self.wifiDataArr[indexPath.row];
//
//        if (model.ssid.length > 15) {
//            NSString *wifiNameStr = [model.ssid substringToIndex:15];
//            confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"请输入\"%@...\"的密码",wifiNameStr];
//        }else{
//            confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"请输入\"%@\"的密码",model.ssid];
//        }
//
//        ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:confirmActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
    /*
    if (indexPath.row != 0) {
        confirmView * confirmActionSheet = [confirmView viewFromXib];
        confirmActionSheet.delegate = self;
        wifiModel * model = self.wifiDataArr[indexPath.row];
        
        if (model.ssid.length > 15) {
            NSString *wifiNameStr = [model.ssid substringToIndex:15];
            confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"请输入\"%@...\"的密码",wifiNameStr];
        }else{
            confirmActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"请输入\"%@\"的密码",model.ssid];
        }

        ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:confirmActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    */
}

#pragma mark  ==== confirmViewDelegate
- (void)joinBtnClick:(id)sender psdStr:(NSString *)psdStr
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
   
    NSString * wifiPsdStr = psdStr;
    wifiModel * model = self.wifiDataArr[_indexRow];
    NSString * tempStr = model.ssid;


    NSString * authStr = model.auth;
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [dic setObject:wifiPsdStr forKey:@"password"];
    [dic setObject:tempStr forKey:@"ssid"];
    [dic setObject:authStr forKey:@"auth"];
    NSLog(@"设置wifi前，给后台的dic：%@===",dic);
//    [XHToast showCenterWithText:@"设备正在尝试更换网络，请稍后..."];
    [[HDNetworking sharedHDNetworking]POST:@"v1/devicewifi/setWLanConfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"设置wifi设备：responseObject:%@",responseObject);
        if (ret == 0) {
            [self.wifiTabView.mj_header beginRefreshing];
        }else{
//            [XHToast showCenterWithText:@"设备连接网络失败，请重试..."];
            [self.wifiTabView.mj_header beginRefreshing];
        }
    } failure:^(NSError * _Nonnull error) {
//        [XHToast showCenterWithText:@"设备连接网络失败，请重试..."];
        NSLog(@"设置wifi设备：responseObject数据失败");
        [self.wifiTabView.mj_header beginRefreshing];
    }];
}


#pragma mark ==== getter && setter
- (UITableView *)wifiTabView
{
    if (!_wifiTabView) {
        _wifiTabView = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, iPhoneWidth, iPhoneHeight-64) style:UITableViewStylePlain];
        _wifiTabView.backgroundColor = BG_COLOR;

        //设置代理
        _wifiTabView.delegate = self;
        _wifiTabView.dataSource = self;
        UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 20)];
        _wifiTabView.tableHeaderView = headView;
        _wifiTabView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _wifiTabView;
}

- (NSMutableArray *)wifiDataArr
{
    if (!_wifiDataArr) {
        _wifiDataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _wifiDataArr;
}

#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"noContent"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"暂无数据", nil);
}

- (UIColor *)xy_noDataViewMessageColor {
    return [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
