//
//  MyViewController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MyViewController.h"
#import "ZCTabBarController.h"
#import "BaseNavigationViewController.h"
/*推送*/
#import <CloudPushSDK/CloudPushSDK.h>
/*headView*/
#import "MineHeadView.h"
#import "MineReviseView.h"
#import "UIImage+image.h"
/*四个功能块的cell*/
#import "MyFunctionCell.h"
/*增值服务cell*/
#import "ValueAddedCell.h"
/*通用cell*/
#import "myGeneralCell.h"
/*设置*/
#import "GeneralSettingVC.h"
/*我的文件*/
#import "FileImageController.h"
#import "FileVideoController.h"
#import "SegmentViewController.h"
#import "FileVC.h"
/*设备共享*/
#import "ShareViewController.h"
/*我的好友*/
/*客服中心*/
/*云存储*/
#import "MyAllCloudStorageVC.h"
/*意见反馈*/
#import "SubmitFeebackViewController.h"
/*关于我们*/
#import "AboutUsVC.h"
#import "UserInfoModifyVC.h"
/*帮助页面*/
#import "HelpVC.h"

@interface MyViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    MineHeadViewDelegate,//头像视图点击协议
    MineReviseViewDelegate,//修改用户名协议
    MyFunctionCellDelegate,//功能块的协议（我的文件、设备共享、我的好友、客服中心）
    ValueAddedCellDelegate
>
/*表视图*/
@property (strong, nonatomic) IBOutlet UITableView *tv_list;
/*头视图*/
@property (nonatomic,strong) MineHeadView *headView;

@end

@implementation MyViewController
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    
    //获取更新后的用户名
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getModifiedUserName:) name:@"modifyUserName" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//==========================init==========================
#pragma mark ------UI
- (void)setUpUI
{
    self.navigationController.title = NSLocalizedString(@"我的", nil);
    self.tv_list.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tv_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tv_list.backgroundColor = BG_COLOR;
    self.tv_list.tableHeaderView = self.headView;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

//==========================method==========================
#pragma mark ----- 更新用户名
- (void)getModifiedUserName:(NSNotification *)noti
{
//        NSLog(@"noti:%@",noti);
    NSString * userNameStr = [noti.userInfo objectForKey:@"userName"];
    self.headView.lab_name.text = userNameStr;
    [self removeNoticeCenter];
}

//移除通知
- (void)removeNoticeCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//==========================delegate==========================
//组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;//3
}
//行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1){
        return 3;
    }else{
        return 1;
    }
}

//cell样式
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;

    //section 0 功能点cell
    if (section == 0) {
        static NSString *MyFunctionCell_Identifier=@"MyFunctionCell_Identifier";
        MyFunctionCell *cell=[tableView dequeueReusableCellWithIdentifier:MyFunctionCell_Identifier];
        if (cell==nil) {
            [tableView registerNib:[UINib nibWithNibName:@"MyFunctionCell" bundle:nil] forCellReuseIdentifier:MyFunctionCell_Identifier];
            cell=[tableView dequeueReusableCellWithIdentifier:MyFunctionCell_Identifier];
        }
        cell.delegate = self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    /*
    else if (section == 1) { //section 1 增值服务cell
        static NSString *MyValueAddedCell_Identifier=@"MyValueAddedCell_Identifier";
        ValueAddedCell *cell=[tableView dequeueReusableCellWithIdentifier:MyValueAddedCell_Identifier];
        if (cell==nil) {
            [tableView registerNib:[UINib nibWithNibName:@"ValueAddedCell" bundle:nil] forCellReuseIdentifier:MyValueAddedCell_Identifier];
            cell=[tableView dequeueReusableCellWithIdentifier:MyValueAddedCell_Identifier];
        }
        cell.delegate = self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
     */
     else{//section 2 公用cell
        static NSString *MyGeneralCell_Identifier=@"MyGeneralCell_Identifier";
        myGeneralCell *cell=[tableView dequeueReusableCellWithIdentifier:MyGeneralCell_Identifier];
        if (cell==nil) {
            [tableView registerNib:[UINib nibWithNibName:@"myGeneralCell" bundle:nil] forCellReuseIdentifier:MyGeneralCell_Identifier];
            cell=[tableView dequeueReusableCellWithIdentifier:MyGeneralCell_Identifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        if (row == 0) {
            cell.tip_Img.image = [UIImage imageNamed:@"mygeneralSet"];
            cell.tip_Lb.text = NSLocalizedString(@"通用", nil);
        }else if (row == 1){
            cell.tip_Img.image = [UIImage imageNamed:@"myopinion"];
            cell.tip_Lb.text = NSLocalizedString(@"意见反馈", nil);
        }else{
            cell.tip_Img.image = [UIImage imageNamed:@"myabout"];
            cell.tip_Lb.text = NSLocalizedString(@"关于我们", nil);
        }
        return cell;
    }
}

//cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //通用cell的点击事件
    if(section == 1){
        if (row == 0) {
            GeneralSettingVC *setVC = [[GeneralSettingVC alloc]init];
            [self.navigationController pushViewController:setVC animated:YES];
        }else if (row == 1){
            SubmitFeebackViewController *subVC = [[SubmitFeebackViewController alloc]init];
            [self setUpNavBack];
            [self.navigationController pushViewController:subVC animated:YES];
        }else{
            AboutUsVC * aboutVC = [[AboutUsVC alloc]init];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
    }
}

//cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 90;
    }
    /*
    else if(indexPath.section == 1){
        return 90;
    }
    */
     else{
        return 44;
    }
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    /*
    if (section == 1) {
        return 30;
    }else{
        return 15;
    }
    */
    return 15;
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
//    if (section == 1) {
//        UILabel *tiplb = [FactoryUI createLabelWithFrame:CGRectMake(15, 10, 200, 15) text:NSLocalizedString(@"增值服务", nil) font:FONT(15)];
//        [headView addSubview:tiplb];
//    }
    return headView;
}

#pragma mark - MineHeadViewDelegate
- (void)mineHeadViewLabnameClick
{
    UserInfoModifyVC *userInfoVC = [[UserInfoModifyVC alloc]init];
    userInfoVC.userNameStr = self.headView.lab_name.text;
    userInfoVC.phoneNumStr = self.headView.lab_tel.text;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

//功能块的四个代理方法实现
#pragma mark - 我的文件点击事件
- (void)myFileViewClick{
    FileVC *fileVC = [[FileVC alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}
#pragma mark - 设备分享点击事件
- (void)myShareViewClick{
//    ShareViewController * shareVC = [[ShareViewController alloc]init];
//    [self.navigationController pushViewController:shareVC animated:YES];
}

#pragma mark - 常见问题点击事件
- (void)myHelpViewClick{
    HelpVC *helpVC = [[HelpVC alloc]init];
    BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
    helpVC.url = urlModel.appHelpUrl;
    [self.navigationController pushViewControllerFromTop:helpVC];
}

/*
#pragma mark - 客服中心点击事件
- (void)myServiceViewClick{
    [XHToast showCenterWithText:@"敬请期待~"];
}
 */

//增值服务的代理方法实现
#pragma mark -云存储点击事件
- (void)CloudStorageViewClick{
//    MyAllCloudStorageVC *cloudVC = [[MyAllCloudStorageVC alloc]init];
//    [self.navigationController pushViewController:cloudVC animated:YES];
}

//==========================lazy loading==========================
#pragma mark -----懒加载
//头视图
- (MineHeadView *)headView
{
    if (!_headView) {
        _headView = [MineHeadView viewFromXib];
        _headView.delegate = self;
    }
    return _headView;
}

@end
