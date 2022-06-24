//
//  MineViewController.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MineViewController.h"
#import "SubmitFeebackViewController.h"
#import "MineHeadView.h"
#import "MineCell_t.h"
#import "MineOutCell_t.h"
#import "MineReviseView.h"
#import "UIImage+image.h"
#import "SetViewController.h"
#import "ZCTabBarController.h"
#import "BaseNavigationViewController.h"
#import "LoginViewController.h"
#import "SegmentViewController.h"
#import "FileVideoController.h"
#import "FileImageController.h"
#import "ShareViewController.h"
//推送
#import <CloudPushSDK/CloudPushSDK.h>
#define CELL @"mineCell_t"
#define OUTCELL @"mineOutCell_t"
@interface MineViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    MineHeadViewDelegate,
    MineReviseViewDelegate
>

//头视图
@property (nonatomic,strong)MineHeadView *headView;
//table
@property (nonatomic,strong)UITableView *tableView;
//数组arr
@property (nonatomic,strong)NSMutableArray *dataArr;
//图标arr
@property (nonatomic,strong)NSMutableArray *imaArr;
@end

@implementation MineViewController


- (MineHeadView *)headView
{
    if (!_headView) {
        _headView = [MineHeadView viewFromXib];
        _headView.delegate = self;
    }
    return _headView;
}
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, iPhoneWidth, iPhoneHeight-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHexString:@"f1f1f1"];
        _tableView.estimatedRowHeight = 50;  //  随便设个不那么离谱的值
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableHeaderView = self.headView;
        UIView *footView = [[UIView alloc]init];
        _tableView.tableFooterView = footView;
        [_tableView registerNib:[UINib nibWithNibName:@"MineCell_t" bundle:nil] forCellReuseIdentifier:CELL];
        [_tableView registerNib:[UINib nibWithNibName:@"MineOutCell_t" bundle:nil] forCellReuseIdentifier:OUTCELL];
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpData];
    [self setUpUI];
}
#pragma mark ------UI
- (void)setUpUI
{
    self.navigationController.title = @"我的";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
}
#pragma mark ------数据
- (void)setUpData
{
    NSArray *section0Arr =[NSArray arrayWithObjects:@"我的文件",@"设备共享", nil];
    NSArray *section1Arr =[NSArray arrayWithObjects:@"通用设置",@"意见反馈", nil];
    NSArray *section2Arr =[NSArray arrayWithObjects:@"退出登录", nil];
    self.dataArr = [NSMutableArray arrayWithObjects:section0Arr,section1Arr,section2Arr,nil];
    
    NSArray *imaSection0Arr = [NSArray arrayWithObjects:@"file",@"share", nil];
    NSArray *imaSection1Arr = [NSArray arrayWithObjects:@"set up",@"fankui", nil];
    self.imaArr = [NSMutableArray arrayWithObjects:imaSection0Arr,imaSection1Arr, nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataArr[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = [UIColor colorWithHexString:@"f1f1f1"];
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section!=2) {
        MineCell_t *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
        cell.lab_name.text = self.dataArr[indexPath.section][indexPath.row];
        NSString *imaStr = self.imaArr[indexPath.section][indexPath.row];
        cell.ima_photo.image = [UIImage imageNamed:imaStr];
        return cell;
    }
    else if (indexPath.section == 2) {
        MineOutCell_t *cell = [tableView dequeueReusableCellWithIdentifier:OUTCELL];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"a"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self createAlert];
    }
    
    else if (indexPath.section == 1 &&indexPath.row == 1){
        SubmitFeebackViewController *subVC = [[SubmitFeebackViewController alloc]init];
        [self setUpNavBack];
        [self.navigationController pushViewController:subVC animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0){
    
        SetViewController * setVC = [[SetViewController alloc]init];
        [self.navigationController pushViewController:setVC animated:YES];
    }else if (indexPath.section == 0 && indexPath.row == 0){
        NSLog(@"我的文件");
        FileVideoController * videoVC = [[FileVideoController alloc]init];
        FileImageController * imageVC = [[FileImageController alloc]init];
        SegmentViewController * segmentVC = [[SegmentViewController alloc]init];
        
        [segmentVC setViewControllers:@[videoVC,imageVC]];
        [segmentVC setTitles:@[@"视频",@"图片"]];
        [self.navigationController pushViewController:segmentVC animated:YES];
        
    }else if (indexPath.section == 0 && indexPath.row == 1){
        ShareViewController * shareVC = [[ShareViewController alloc]init];
        [self.navigationController pushViewController:shareVC animated:YES];
        
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark ------MineHeadViewDelegate
- (void)mineHeadViewLabnameClick
{
    UIImage *img = [UIImage scott_screenShot];
    UIImage *bufferIma = [UIImage scott_blurImage:img blur:0.4];
    MineReviseView *customActionSheet = [MineReviseView viewFromXib];
    customActionSheet.delegate = self;
    customActionSheet.fied_name.text = self.headView.lab_name.text;
    ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:customActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:bufferIma];
    imgView.contentMode=UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds=YES;
    imgView.userInteractionEnabled = YES;
    alertController.backgroundView = imgView;
    alertController.tapBackgroundDismissEnable = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ------MineReviseViewDelegate
- (void)mineReviseBtnOkClick:(NSString *)nameStr
{
    self.headView.lab_name.text = nameStr;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:nameStr forKey:@"user_name"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/profile" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
- (void)mineReviseBtnCancelClick
{

}
- (void)createAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出登录"message:@"确定注销登录？"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消注销" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定注销" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self cancleLogin];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (void)cancleLogin{

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/logout" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        
    }];
    ZCTabBarController *tab = (ZCTabBarController *)self.tabBarController;
    [tab stopTimer];
    [tab deallocVideoSdk];
    BOOL isLogin = NO;
    NSNumber *isLoginNum = [NSNumber numberWithBool:isLogin];
    [[NSUserDefaults standardUserDefaults]setObject:isLoginNum forKey:ISLOGIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //判断根式图是哪一个
    UIWindow *window =  [[UIApplication sharedApplication] keyWindow];
    if ([window.rootViewController isKindOfClass:[BaseNavigationViewController class]]) {
        [self.tabBarController dismissViewControllerAnimated:YES completion:^{
        }];
    }
    else{
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
        window.rootViewController = NVC;
    }
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
