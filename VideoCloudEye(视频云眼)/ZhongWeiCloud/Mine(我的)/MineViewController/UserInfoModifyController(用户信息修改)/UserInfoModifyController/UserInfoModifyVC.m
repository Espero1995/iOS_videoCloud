//
//  UserInfoModifyVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/4.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "UserInfoModifyVC.h"
#import "ZCTabBarController.h"
#import "BaseNavigationViewController.h"
#import "ScottAlertViewController.h"
#import "MineReviseView.h"
#import "uploadHeadCell.h"//头像上传
#import "UserInfoModifyCell.h"//用户信息修改cell
#import "nopushImgCell.h"//用户手机号cell
#import "logoutCell.h"//退出登录的cell
#import "ModifyPwdVC.h"//修改密码
#import "ModifyUserNameVC.h"//修改用户名
#import <CloudPushSDK/CloudPushSDK.h>//推送
/*登录页面*/
#import "AccountLoginNewVC.h"
#import <YZBaseSDK/YZBaseSDK.h>
@interface UserInfoModifyVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    MineReviseViewDelegate//修改用户名协议
>
{
    NSInteger RowCount;//是否显示微信绑定
}
@property (nonatomic,strong) UITableView* tv_list;
@property (strong, nonatomic) UIWindow *window;

@end

@implementation UserInfoModifyVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"个人资料", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
    UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"用户的微信id：%@",userModel.wechat_id);
    if (userModel.wechat_id && ![userModel.wechat_id isEqualToString:@""]) {
        RowCount = 2;
    }else{
        RowCount = 1;
    }
    [self.view addSubview:self.tv_list];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    //获取更新后的用户名
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getModifiedUserName:) name:@"modifyUserName" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

#pragma mark ----- 更新用户名
- (void)getModifiedUserName:(NSNotification *)noti
{
    NSString * userNameStr = [noti.userInfo objectForKey:@"userName"];
    self.userNameStr = userNameStr;
    [self.tv_list reloadData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 微信登录绑定解除警告框
- (void)WeChatRelieveAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"解绑后，下次无法再使用微信进行登录，确定要解除微信绑定吗？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self relieveWeChatLogin];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 设置微信登录绑定解除
- (void)relieveWeChatLogin
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"微信解绑中，请稍候...", nil)];
    /**
     * description: 微信的解绑
     * POST v1/user/wechat/unbindinfo
     * access_token=<令牌>& user_id=<用户ID>
     */
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [[HDNetworking sharedHDNetworking] POST:@"v1/user/wechat/unbindinfo" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"成功了：%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
                UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                userModel.wechat_id = @"";
                NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:userModel];
                [[NSUserDefaults standardUserDefaults]setObject:saveData forKey:USERMODEL];
                RowCount = 1;
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"解绑成功", nil)];
                [self.tv_list reloadData];
            });
        }else{
            [Toast dissmiss];
            [XHToast showCenterWithText:NSLocalizedString(@"解绑失败", nil)];
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
        [Toast dissmiss];
        [XHToast showCenterWithText:NSLocalizedString(@"解绑失败，请检查您的网络", nil)];
    }];
}

#pragma mark - 退出登录
- (void)logoutAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"退出登录", nil) message:NSLocalizedString(@"确定注销登录？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self logout];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logout
{
    NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
    if ([URLStr isEqualToString:official_Environment_key]) {
        NSLog(@"【本次启动---正式环境 UserInfoModify】");
        //退出视频云眼
        NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [postDic setValue:app_type forKey:@"app_type"];
        [[HDNetworking sharedHDNetworking]POST:@"v1/user/logoutNew" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            NSLog(@"退出登录ResponseObject:%@",responseObject);
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0) {
                [self logoutView];
            }
            
        } failure:^(NSError * _Nonnull error) {
            [XHToast showCenterWithText:NSLocalizedString(@"退出失败，请检查网络", nil)];
        }];
            
            
    }else if([URLStr isEqualToString:test_Environment_key]){
        NSLog(@"【本次启动---测试环境 UserInfoModify】");
        //退出视频云眼
        NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [postDic setValue:app_type forKey:@"app_type"];
        [[HDNetworking sharedHDNetworking]POST:@"v1/user/logoutNew" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            NSLog(@"退出登录ResponseObject:%@",responseObject);
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0) {
                [self logoutView];
            }
        } failure:^(NSError * _Nonnull error) {
            [XHToast showCenterWithText:NSLocalizedString(@"退出失败，请检查网络", nil)];
        }];
    }
}

- (void)logoutView
{
    //退出有赞商城登录
    NSMutableDictionary *youzandic = [NSMutableDictionary dictionary];
    [[HDNetworking sharedHDNetworking]POST:@"v1/youzan/open/logout" parameters:youzandic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"有赞退出登录：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSString * userID = [unitl get_User_id];
            NSString * yzlonginKey = [unitl getKeyWithSuffix:userID Key:youzanLoginModel];
            [unitl clearDataWithKey:yzlonginKey];
            [YZSDK.shared logout];//有赞退出登录。
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    //解除绑定
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        NSLog(@"推送解除绑定：%@",res.success?@"YES":@"NO");
    }];
    
    ZCTabBarController *tab = (ZCTabBarController *)self.tabBarController;
    [tab stopTimer];
    [tab deallocVideoSdk];
    BOOL isLogin = NO;
    NSNumber *isLoginNum = [NSNumber numberWithBool:isLogin];
    [[NSUserDefaults standardUserDefaults]setObject:isLoginNum forKey:ISLOGIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [unitl saveDataWithKey:NAV_Status Data:@"NAV_Status_DOWN"];
    
    //判断根式图是哪一个
    UIWindow *window =  [[UIApplication sharedApplication] keyWindow];
    if ([window.rootViewController isKindOfClass:[BaseNavigationViewController class]]) {
        
        //        [self.tabBarController dismissViewControllerAnimated:YES completion:^{
        //            AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
        //            BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
        //            window.rootViewController = NVC;
        //        }];
        AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
        BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
        self.window.rootViewController = NVC;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    }else{
        AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
        BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
        window.rootViewController = NVC;
    }
}


#pragma mark - UITableView代理协议
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            return 80;
        }
    }
    return 44;
}
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else if (section == 1){
        return RowCount;
    }else{
        return 1;
    }
}
//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {//用户头像
            //加载自定义的Cell
            static NSString *uploadHeadCell_Identifier = @"uploadHeadCell_Identifier";
            uploadHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:uploadHeadCell_Identifier];
            if(!cell){
                cell = [[uploadHeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uploadHeadCell_Identifier];
            }
            cell.nameLb.text = NSLocalizedString(@"头像", nil);
            cell.headImg.image = [UIImage imageNamed:@"myhead"];
            return cell;
            
        }else if (row == 1){//昵称
            //加载自定义的Cell
            static NSString *UserInfoModifyCell_Identifier = @"UserInfoModifyCell_Identifier";
            UserInfoModifyCell* cell = [tableView dequeueReusableCellWithIdentifier:UserInfoModifyCell_Identifier];
            if(!cell){
                cell = [[UserInfoModifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserInfoModifyCell_Identifier];
            }
            cell.nameLb.text = NSLocalizedString(@"用户名", nil);
            cell.tipLb.text = self.userNameStr;
            return cell;
        }else{//手机号码
            //加载自定义的Cell
            static NSString *nopushImgCell_Identifier = @"nopushImgCell_Identifier";
            nopushImgCell* cell = [tableView dequeueReusableCellWithIdentifier:nopushImgCell_Identifier];
            if(!cell){
                cell = [[nopushImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nopushImgCell_Identifier];
            }
            if ([unitl isEmailAccountType]) {
                cell.nameLb.text = NSLocalizedString(@"邮箱", nil);
            }else{
                cell.nameLb.text = NSLocalizedString(@"手机号码", nil);
            }
            cell.tipLb.text = self.phoneNumStr;
            return cell;
        }
        
    }else if (section == 1){
        if (row == 0) {
            //加载自定义的Cell
            static NSString *UserInfoModifyCell_Identifier = @"UserInfoModifyCell_Identifier";
            UserInfoModifyCell* cell = [tableView dequeueReusableCellWithIdentifier:UserInfoModifyCell_Identifier];
            if(!cell){
                cell = [[UserInfoModifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserInfoModifyCell_Identifier];
            }
            cell.nameLb.text = NSLocalizedString(@"修改密码", nil);
            return cell;
        }else{
            //加载自定义的Cell
            static NSString *relieveWeChatLoginCell_Identifier = @"relieveWeChatLoginCell_Identifier";
            UserInfoModifyCell* cell = [tableView dequeueReusableCellWithIdentifier:relieveWeChatLoginCell_Identifier];
            if(!cell){
                cell = [[UserInfoModifyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:relieveWeChatLoginCell_Identifier];
            }
            cell.nameLb.text = NSLocalizedString(@"微信绑定解除", nil);
            return cell;
        }
        
    }else{
        static NSString *logoutCell_Identifier=@"logoutCell_Identifier";
        logoutCell *cell=[tableView dequeueReusableCellWithIdentifier:logoutCell_Identifier];
        if (cell==nil) {
            [tableView registerNib:[UINib nibWithNibName:@"logoutCell" bundle:nil] forCellReuseIdentifier:logoutCell_Identifier];
            cell=[tableView dequeueReusableCellWithIdentifier:logoutCell_Identifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

//区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return 10;
    }else{
        return 15;
    }
}

//区高
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, iPhoneWidth, 15);
    return backView;
}

//区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

//区尾
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView* backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    return backView;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (section == 0) {//修改用户名
        if (row == 0) {
        }else if (row == 1){
            ModifyUserNameVC *modifyVC = [[ModifyUserNameVC alloc]init];
            modifyVC.userNameStr = self.userNameStr;
            [self.navigationController pushViewController:modifyVC animated:YES];
        }else{
           //微信登录绑定解除
        }
    }else if (section == 1){
        if (row == 0) {
            //修改密码
            ModifyPwdVC *modifyVC = [[ModifyPwdVC alloc]init];
            modifyVC.phoneNumStr = self.phoneNumStr;
            [self.navigationController pushViewController:modifyVC animated:YES];
        }else{
            [self WeChatRelieveAlert];
        }
    }else{
        [self logoutAlert];
    }
}

#pragma mark ------MineReviseViewDelegate
- (void)mineReviseBtnOkClick:(NSString *)nameStr
{
    self.userNameStr = nameStr;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:nameStr forKey:@"user_name"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/profile" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self.tv_list reloadData];
            //修改用户名
            NSDictionary * dic = @{@"userName":nameStr};
            [[NSNotificationCenter defaultCenter]postNotificationName:@"modifyUserName" object:nil userInfo:dic];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


#pragma mark - getter&setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, iPhoneWidth, iPhoneHeight) style:UITableViewStylePlain];
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _tv_list;
}

@end
