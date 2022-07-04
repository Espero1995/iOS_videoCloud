//
//  WeiCloudVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/15.
//  Copyright © 2018年 张策. All rights reserved.
//
#define LeftSpace 10
#define searchBarHeight 44
#define headViewHeight 160
#define placeHolderWidth 170
#define switchShowStyleView_height (iPhone_X_?188:170)

#define KMargin_sc 80
#define groupBtnEdge (iPhoneWidth - 2 * KMargin_sc - 3 * groupBtnWidth)/4
#define groupBetweenEdge  2*groupBtnEdge + 10
#define groupBtnWidth  61
#define groupBtnHeight  61
//iPhoneHeight/4
#import "WeiCloudVC.h"
#import "ZCTabBarController.h"
/*二维码*/
#import "SGGenerateQRCodeVC.h"
#import "SGScanningQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "SGAlertView.h"
/*轮播图*/
#import "SDCycleScrollView.h"
/*设备展示的VC*/
#import "myDeviceDisplayVC.h"//小屏VC
#import "DeviceDisplayVC.h"//大屏VC
#import "fourScreenDisplayVC.h"//四分屏VC
/*广告页面VC*/
#import "AdvertiseViewController.h"
#import "Update_View.h"
#import "AppDelegate.h"
//apptabbar标签的开关model
#import "AppSettingsModel.h"
#import "nav_userDefine.h"
#import "SwitchShowStyleView.h"
#import "userDefine_bg_view.h"
#import "GroupChoosingVC.h"

#import "groupModel.h"//临时使用下而已
#import "GroupSettingVC.h"//分组设置VC
#import "SwitchModeView.h"
#import "AppUpdateManager.h"

@interface WeiCloudVC ()
<
    SDCycleScrollViewDelegate,
    Update_View_Delegete,
    nav_userDefine_delegate,
    SwitchShowStyleViewDelegate,
    userDefine_bg_view_Delegate,
    definePageWidthRoundScDelegate
>
{
    NSMutableArray *groupArr;//创建选择展示模式上面的tabV的数据源
    BOOL isStatus;
}

@property (nonatomic,strong) UIView * backLightView;
/*判断是否要升级APP*/
@property (nonatomic,assign) int force;

@property (nonatomic, strong) nav_userDefine* nav_view;/**< 自定义的nav */
@property (nonatomic, strong) SwitchShowStyleView* switchShowStyleView;/**< 用来选择视频展示模式 */
@property (nonatomic, strong) userDefine_bg_view* bgView;/**< 自定义控件的背景view */
@property (nonatomic, strong) NSMutableArray* GroupNameAndIDArr;/**< 用来新建导航条的参数 */
@property (nonatomic, strong) SwitchModeView *switchView;//切换模式View

@end

@implementation WeiCloudVC
//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    groupArr = [NSMutableArray arrayWithCapacity:0];
    //广告页
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushToAd) name:@"pushtoAd" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(nav_change_up) name:tableviewScrollow_up object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(nav_change_down) name:tableviewScrollow_down object:nil];
    //创建组别成功
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CreateOrDeleteGroupSuccess) name:GroupCreateOrDeleteSuccess_updateUI object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadGroupSC) name:reloadGroupSCBtn object:nil];

    //设置导航栏上的按钮
//    [self setupNavBar];
    //设置头视图
   // [self setupHeadView];
    //设置添加子视图
    [self setupAllChildViewController];
    //版本信息
//    [self getVersion];
    [self checkAppUpdate];
    //向服务器上传当前语言环境
    [self setLanguageType:isSimplifiedChinese];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    [self getGroupInfoCreateGroupSuccess:NO];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //HDNetworking *manager = [[HDNetworking alloc] init];
   // [manager canleAllHttp];//暂时注释
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
//临时的数据源
- (void)createData
{
    groupArr = [groupModel  mj_objectArrayWithKeyValuesArray:self.GroupNameAndIDArr];
}

//组别创建成功之后
- (void)CreateOrDeleteGroupSuccess
{
    [self getGroupInfoCreateGroupSuccess:YES];
}
//更新groupSC
- (void)reloadGroupSC
{
    [self.nav_view.sc CreateGroupSuccess];
    [self createData];
}
//=========================init=========================
#pragma mark ==== 自定义 nav 的代理方法
#pragma mark - 菜单列表
- (void)leftItemBtnClick
{
    [self createData];
    if (self.bgView.hidden == YES) {//已经创建了
        self.bgView.hidden = NO;
        dispatch_async(dispatch_get_main_queue(),^{
            [self.switchShowStyleView updateUIAfterGroupCreatedGroupData:groupArr];
        });
    }else{
        UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
        [currentWindow addSubview:self.bgView];
        [UIView animateWithDuration:1.0f animations:^{
            [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.mas_equalTo(currentWindow);
            }];
               
        } completion:^(BOOL finished) {
            [self.bgView addSubview:self.switchShowStyleView];
            if (groupArr.count <= 5) {
                self.switchShowStyleView.frame = CGRectMake(0, 0, iPhoneWidth, switchShowStyleView_height+50*groupArr.count);
            }else{
                self.switchShowStyleView.frame = CGRectMake(0, 0, iPhoneWidth, switchShowStyleView_height+50*5);
            }
            
        }];
    }
}
#pragma mark = 根据tabview的滑动，改变nav的形态
- (void)nav_change_up
{
    [self.nav_view changeNavFrameAnimation:NavBarHeightChangge_duringTime IsUp:YES compeleteBlock:nil];
}
- (void)nav_change_down
{
    [self.nav_view changeNavFrameAnimation:NavBarHeightChangge_duringTime IsUp:NO compeleteBlock:nil];
}

#pragma mark - 添加设备

- (void)rightItemBtnClick
{
    [self showQrcode];
}
#pragma mark - 分组按钮点击方法
- (void)groupBtnClick:(UIButton *)btn
{
    
    btn.selected = !btn.selected;
    NSInteger selectedBtnTag = btn.tag - groupBtnTag;

    //获取所有组别
    NSArray *allGroup = [[unitl getAllGroupCameraModel] copy];

    deviceGroup *groupModel = allGroup[selectedBtnTag];
    //当前选中的组的状态
    if ([groupModel.enableSensibility intValue] == 1) {
        [btn setImage:[UIImage imageNamed:@"selected_Protected"] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"selected_Unprotected"] forState:UIControlStateNormal];
    }
    
    UILabel * selectedLabel = self.nav_view.sc.groupBtnLabelArr[selectedBtnTag];
    [selectedLabel setTextColor:MAIN_COLOR];
    
    NSArray * btnArr = self.nav_view.sc.groupBtnArr;
    for (int i = 0; i < btnArr.count; i++) {
        if (i != selectedBtnTag) {
            UIButton * tempBtn = btnArr[i];
            deviceGroup *tempGroupModel = allGroup[i];
            //当前选中的组的状态
            if ([tempGroupModel.enableSensibility intValue] == 1) {
                [tempBtn setImage:[UIImage imageNamed:@"unselected_protected"] forState:UIControlStateNormal];
            }else{
                [tempBtn setImage:[UIImage imageNamed:@"unselected_Unprotected"] forState:UIControlStateNormal];
            }
        }
    }

    NSArray * btnLabelArr = self.nav_view.sc.groupBtnLabelArr;
    for (int i = 0; i < btnLabelArr.count; i++) {
        if (i != selectedBtnTag) {
            UILabel * tempBtnLabel = btnLabelArr[i];
            [tempBtnLabel setTextColor:COLOR_TEXT];
        }
    }
    NSInteger currentShowIndex = [unitl getCurrentDisplayGroupIndex];
    NSInteger btnCount = self.GroupNameAndIDArr.count;
    NSMutableArray * tempGroupIDArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0 ; i < btnCount; i++) {
        [tempGroupIDArr addObject:self.GroupNameAndIDArr[i][@"groupID"]];
    }
    
    if (currentShowIndex == selectedBtnTag) {
        NSLog(@"分组按钮点击方法,点击了相同的分组，直接返回！！！");
        
        deviceGroup *currentGroupModel = allGroup[selectedBtnTag];
        
        if ([currentGroupModel.enableSensibility intValue] == 1) {
            isStatus = YES;
        }else{
            isStatus = NO;
        }
        
        NSArray *currentGroupDevList = [[unitl getCameraGroupDeviceModelIndex:selectedBtnTag] copy];
        if (currentGroupDevList.count != 0) {
            
        [self.switchView switchModeViewShow:isStatus andGroupID:currentGroupModel.groupId];
            
         self.switchView.block = ^(BOOL isStatus){
             isStatus = !isStatus;
             if (isStatus == YES) {//布防开启
                [btn setImage:[UIImage imageNamed:@"selected_Protected"] forState:UIControlStateNormal];
                currentGroupModel.enableSensibility = @"1";
             }else{//布防关闭
                 [btn setImage:[UIImage imageNamed:@"selected_Unprotected"] forState:UIControlStateNormal];
                 currentGroupModel.enableSensibility = @"0";
             }
             
             [unitl saveAllGroupCameraModel:[allGroup mutableCopy]];
             //发送活动检测状态的通知
             NSDictionary * dic = @{@"isActivity":[NSString stringWithFormat:@"%d",isStatus],@"DeviceCount":[NSString stringWithFormat:@"%lu",(unsigned long)currentGroupModel.dev_list.count]};
             NSLog(@"更新活动检测状态的dic：%@",dic);
             [[NSNotificationCenter defaultCenter]postNotificationName:allDeviceisActivity object:nil userInfo:dic];
         };
        
        
            
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"组内无设备，无法一键布防", nil)];
        }
        
        return;
    }else
    {
        [unitl saveCurrentDisplayGroupIndex:selectedBtnTag];
        // [XHToast showTopWithText:[NSString stringWithFormat:@"点击了分组功能de btnID是：%@",tempGroupIDArr[selectedBtnTag]]];
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:[NSNumber numberWithInteger:selectedBtnTag] forKey:chooseGroup];
        [[NSNotificationCenter defaultCenter]postNotificationName:chooseGroup object:nil userInfo:dic];
    }
}
#pragma mark 自定义view的背景view ==关闭功能
- (void)bg_view_TapAction:(UITapGestureRecognizer*)tap
{
     self.bgView.hidden = YES;    
}

#pragma mark ==== 自定义 展示模式选择view 的代理方法
- (void)SwitchShowStyleBtnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case TAG_CLOSEBTN://关闭
        {
            self.bgView.hidden = YES;
        }
            break;
        case TAG_ADDGROUPBTN://添加小组
        {
            self.bgView.hidden = YES;
            GroupChoosingVC * chooseVC = [[GroupChoosingVC alloc]init];
            chooseVC.chooseWay = 1;//通过添加组时顺便添加设备
            ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
            tabVC.tabHidden = YES;
            [self.navigationController pushViewController:chooseVC animated:YES];
        }
            break;
        case TAG_LITTLEMODE://小屏模式
        {
            btn.selected = YES;
            self.switchShowStyleView.largeMode.selected = NO;
            self.switchShowStyleView.fourScreenMode.selected = NO;
            self.bgView.hidden = YES;
            [self changeVC:CameraListDisplayMode_littleMode];
        }
            break;
        case TAG_LARGEMODE://大屏模式
        {
            btn.selected = YES;
            self.switchShowStyleView.fourScreenMode.selected = NO;
            self.switchShowStyleView.littleMode.selected = NO;
            self.bgView.hidden = YES;
            [self changeVC:CameraListDisplayMode_largeMode];
        }
            break;
        case TAG_FOURSCREENMODE://瀑布流，4分屏模式
        {
            btn.selected = YES;
            self.switchShowStyleView.largeMode.selected = NO;
            self.switchShowStyleView.littleMode.selected = NO;
            self.bgView.hidden = YES;
            [self changeVC:CameraListDisplayMode_fourScreenMode];
        }
            break;
            
        default:
            break;
    }
}

-(void)changeVC:(CameraListDisplayMode)selectedMode
{

//     NSLog(@"当前是什么展示模式：isLargeMode：%d===isLittleMode：%d==isfourScreenMode：%d==self.childViewControllers：%@",isLargeMode,isLittleMode,isfourScreenMode,self.childViewControllers);
    
    [self transferVC:selectedMode];
    
    switch (selectedMode) {
        case CameraListDisplayMode_largeMode://大图模式
        {
            [unitl saveDataWithKey:CURRENTDISPLAYMODE Data:@"CameraListDisplayMode_largeMode"];
        }
            break;
        case CameraListDisplayMode_littleMode://小图模式
        {
            [unitl saveDataWithKey:CURRENTDISPLAYMODE Data:@"CameraListDisplayMode_littleMode"];
        }
            break;
        case CameraListDisplayMode_fourScreenMode://瀑布流，四分屏
        {
            [unitl saveDataWithKey:CURRENTDISPLAYMODE Data:@"CameraListDisplayMode_fourScreenMode"];
        }
            break;
            
        default:
            break;
    }
}

- (void)transferVC:(CameraListDisplayMode)mode
{
    UIViewController * vc = [self.childViewControllers lastObject];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
    
    BOOL IsNav_up = NO;
    CGFloat navCurrentHeight = CGRectGetHeight(self.nav_view.frame);
    NSLog(@"切换视图展示模式的时候，navCurrentHeight：%f",navCurrentHeight);
    if (navCurrentHeight == NavBarHeight_UserDefined) {
        IsNav_up = NO;
        NSLog(@"切换视图展示模式的时候，IsNav_up：%@",IsNav_up?@"YES":@"NO");
    }else
    {
        IsNav_up = YES;
    }
    switch (mode) {
        case CameraListDisplayMode_littleMode:
        {
            myDeviceDisplayVC * myDdVC = [[myDeviceDisplayVC alloc]init];
            myDdVC.view.frame = CGRectMake(0,IsNav_up?NavBarHeight_UserDefined_Up:NavBarHeight_UserDefined, iPhoneWidth, iPhoneHeight - NavBarHeight_UserDefined);
            [self addChildViewController:myDdVC];
            [self.view addSubview:myDdVC.view];
           
            [myDdVC didMoveToParentViewController:self];
        }
            break;
        case CameraListDisplayMode_largeMode:
        {
            DeviceDisplayVC * myDdVC = [[DeviceDisplayVC alloc]init];
            myDdVC.view.frame = CGRectMake(0,IsNav_up?NavBarHeight_UserDefined_Up:NavBarHeight_UserDefined, iPhoneWidth, iPhoneHeight - NavBarHeight_UserDefined);
            [self addChildViewController:myDdVC];
            [self.view addSubview:myDdVC.view];
            [myDdVC didMoveToParentViewController:self];
        }
            break;
        case CameraListDisplayMode_fourScreenMode:
        {
            fourScreenDisplayVC * myDdVC = [[fourScreenDisplayVC alloc]init];
            myDdVC.view.frame = CGRectMake(0,IsNav_up?NavBarHeight_UserDefined_Up:NavBarHeight_UserDefined, iPhoneWidth, iPhoneHeight - NavBarHeight_UserDefined);
            [self addChildViewController:myDdVC];
            [self.view addSubview:myDdVC.view];
            [myDdVC didMoveToParentViewController:self];
        }
            break;
            
        default:
            break;
    }
}


//添加所有的子控制器
- (void)setupAllChildViewController
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([unitl CameraListDisplayMode] == CameraListDisplayMode_littleMode) {
        myDeviceDisplayVC * myDdVC = [[myDeviceDisplayVC alloc]init];
        myDdVC.view.frame = CGRectMake(0,NavBarHeight_UserDefined, iPhoneWidth, iPhoneHeight);
        [self addChildViewController:myDdVC];
        [self.view addSubview:myDdVC.view];
        [myDdVC didMoveToParentViewController:self];
    }else if([unitl CameraListDisplayMode] == CameraListDisplayMode_largeMode){
        DeviceDisplayVC * bigVC = [[DeviceDisplayVC alloc]init];
        bigVC.view.frame = CGRectMake(0,NavBarHeight_UserDefined, iPhoneWidth, iPhoneHeight);
        [self addChildViewController:bigVC];
        [self.view addSubview:bigVC.view];
        [bigVC didMoveToParentViewController:self];
    }else if ([unitl CameraListDisplayMode] == CameraListDisplayMode_fourScreenMode)
    {
        fourScreenDisplayVC * fourVC = [[fourScreenDisplayVC alloc]init];
        fourVC.view.frame = CGRectMake(0,NavBarHeight_UserDefined, iPhoneWidth, iPhoneHeight);
        [self addChildViewController:fourVC];
        [self.view addSubview:fourVC.view];
        [fourVC didMoveToParentViewController:self];
    }
}

//=========================method=========================
#pragma mark == 获取当前groupinfo
//createSucess 组别创建成功或者删除成功 重新请求数据，更新UI
- (void)getGroupInfoCreateGroupSuccess:(BOOL)createSucess
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSNumber *languageType;
    if (isSimplifiedChinese) {
        languageType = [NSNumber numberWithInt:1];
    }else{
        languageType = [NSNumber numberWithInt:2];
    }
    [dic setObject:languageType forKey:@"languageType"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/devicegroup/listGroup" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
//        NSLog(@"查询分组信息:%@",responseObject);
        
        if (ret == 0) {
            [self.GroupNameAndIDArr removeAllObjects];
            WeiCloudListModel *listModel = [WeiCloudListModel mj_objectWithKeyValues:responseObject[@"body"]];
            
            NSInteger groupCount_netData = listModel.deviceGroup.count;
            //保存组别中的组名和ID
            NSMutableArray * tempGroupArr = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < groupCount_netData; i++) {
                NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
                [tempDic setObject:listModel.deviceGroup[i].groupName forKey:@"groupName"];
                [tempDic setObject:listModel.deviceGroup[i].groupId forKey:@"groupID"];
                [tempGroupArr addObject:tempDic];
            }
            [self.GroupNameAndIDArr addObjectsFromArray:tempGroupArr];
            NSString * GroupNameAndIDArr_KeyStr = [unitl getKeyWithSuffix:[unitl get_User_id] Key:GroupNameAndIDArr_key];
            [unitl saveDataWithKey:GroupNameAndIDArr_KeyStr Data:tempGroupArr];
            

            if ([[unitl getAllGroupCameraModel] count] == 0) {
                [unitl saveAllGroupCameraModel:[NSMutableArray arrayWithArray:listModel.deviceGroup]];
            }else
            {
              /*
                NSMutableArray * tempNetData = [NSMutableArray arrayWithCapacity:0];
                tempNetData = [NSMutableArray arrayWithArray:listModel.deviceGroup[[unitl getCurrentDisplayGroupIndex]].dev_list];
                NSMutableArray *videoListArr = [((deviceGroup *)[unitl getCameraGroupModelIndex:[unitl getCurrentDisplayGroupIndex]]).dev_list mutableCopy];
                if (videoListArr.count != 0) {
                    tempNetData = [self sortWithAlreadyHaveOrderNetworkData:tempNetData OrderlyData:videoListArr];
                }
                */
                NSMutableArray * groupAll_locatalData = [NSMutableArray arrayWithCapacity:0];
                groupAll_locatalData = [unitl getAllGroupCameraModel];
                NSInteger groupCount_loacalData = [groupAll_locatalData count];
                
                NSInteger SortCount = groupCount_loacalData < groupCount_netData ? groupCount_loacalData : groupCount_netData;
                
                NSMutableArray * SortSucceedArr = [NSMutableArray arrayWithCapacity:0];
                for (int i = 0 ; i < SortCount ; i++) {
                    NSMutableArray * tempNetData = [NSMutableArray arrayWithCapacity:0];
                    tempNetData = [NSMutableArray arrayWithArray:listModel.deviceGroup[i].dev_list];
                    NSMutableArray *videoListArr = [((deviceGroup *)[unitl getCameraGroupModelIndex:i]).dev_list mutableCopy];
                    if (videoListArr.count != 0) {
                        tempNetData = [self sortWithAlreadyHaveOrderNetworkData:tempNetData OrderlyData:videoListArr];
                    }
                    [SortSucceedArr addObject:(NSArray *)tempNetData];
                }

                [unitl saveAllGroupCameraModel:[NSMutableArray arrayWithArray:listModel.deviceGroup]];
                
//                NSMutableArray * tempArr_all1 = [NSMutableArray arrayWithCapacity:0];
//                tempArr_all1 = [unitl getAllGroupCameraModel];

                for (int i = 0; i < SortCount ; i++) {
                   [unitl saveCameraGroupDeviceModelData:SortSucceedArr[i] Index:i];
                }

//                NSMutableArray * tempArr_all = [NSMutableArray arrayWithCapacity:0];
//                tempArr_all = [unitl getAllGroupCameraModel];
                
            }
            if (createSucess) {
                [self.nav_view.sc CreateGroupSuccess];
                [self createData];
            }
             [self.view addSubview:self.nav_view];
            
            if (groupCount_netData < 3) {
                [UIView animateWithDuration:0.1 animations:^{
                    [self.nav_view.sc setScContentOffset:CGPointMake(-(groupBtnEdge + groupBtnWidth),0)];
                }];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"查询分组 网络正在开小差...");
    }];
}
// 检查APP版本更新
- (void)checkAppUpdate {
    [AppUpdateManager checkAppUpdateComplete:^{
        [self showUpdateAlert];
    }];
}

// 升级框提示
- (void)showUpdateAlert {
    NSString *message = NSLocalizedString(@"检测到新版本", nil);
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"版本更新", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"马上更新", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSURL *appleURL = [NSURL URLWithString:[NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@",shiguangyushipingAPPID]];
        if([[UIApplication sharedApplication] canOpenURL:appleURL]) {
            [[UIApplication sharedApplication] openURL:appleURL options:@{} completionHandler:nil];
        }
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:okAction];
    [alertCtrl addAction:setAction];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}


- (void)getVersion{
    NSLog(@"【检查】当前app版本是否要升级");
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:app_type forKey:@"app_type"];
    [dic setObject:APPVERSION forKey:@"app_ver"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/app/checkversion" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
//        int ret = [responseObject[@"ret"]intValue];
        NSMutableDictionary * updataBody = responseObject[@"body"];
        NSLog(@"版本升级new:%@===updataBody：%@",responseObject,updataBody);
        BOOL bodyIsNull;
        if(!updataBody)
        {
            bodyIsNull = YES;
        }else
        {
            bodyIsNull = NO;
        }
        if (bodyIsNull) {//如果body为空，则不需要升级。
            NSLog(@"当前app版本不要升级");
        }else{
            _backLightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,iPhoneWidth,iPhoneHeight)];
            _backLightView.backgroundColor = [UIColor colorWithWhite:0.3f alpha:0.35f];

            [self.view addSubview:_backLightView];
            Update_View * updateView = [Update_View viewFromXib];
            if (_force == 0) {
                updateView.lab_topTitle.text = NSLocalizedString(@"发现新版本,是否要升级?", nil);
                [updateView.btn_right setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
            }

            updateView.delegete = self;
            updateView.center = _backLightView.center;
            updateView.backgroundColor = [UIColor whiteColor];

            [_backLightView addSubview:updateView];
            [self.view bringSubviewToFront:_backLightView];
            ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
            tabVC.tabHidden = YES;
        }
 
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"网络正在开小差...");
    }];
}

- (void)Update_View_LeftBtnClick:(Update_View *)view{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:shiguangyushipingAPPStroeURL] options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"跳转appStroe成功");
        }
    }];
}

- (void)Update_View_RightBtnClick:(Update_View *)view{
    if (_force == 1) {
        AppDelegate *app = (id)[UIApplication sharedApplication].delegate;
        UIWindow *window = app.window;
        
        [UIView animateWithDuration:1.0f animations:^{
            window.alpha = 0;
            window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
        } completion:^(BOOL finished) {
            exit(0);
        }];
        
    }else{
        ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
        tabVC.tabHidden = NO;
        [_backLightView removeFromSuperview];
    }
}
#pragma mark - 网络获取的视频列表【未排序】和本地【已经拍排序列表】进行排序操作
- (NSMutableArray * )sortWithAlreadyHaveOrderNetworkData:(NSMutableArray *)netData OrderlyData:(NSMutableArray *)orderlydata
{
    NSMutableArray * NetArr = [netData mutableCopy];
    //    NSMutableArray * tempNetArr = [netData mutableCopy];//和网络数据一致，用来删除和已有数据一样的，留下新增的数据。
    NSMutableArray * orderlyArr = [orderlydata mutableCopy];
    NSMutableArray * tempReturnArr = [NSMutableArray arrayWithCapacity:0];
    //NSMutableArray * tempNewArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < orderlyArr.count; i++) {
        for (int j = 0; j < NetArr.count ; j++) {
            NSString * netModelID = ((dev_list *)NetArr[j]).ID;
            NSString * orderlyModelID = ((dev_list *)orderlyArr[i]).ID;
            if ([netModelID isEqualToString:orderlyModelID]) {
                //[tempReturnArr insertObject:NetArr[j] atIndex:i];//这种如果网络数据中有删除，则会空下这个删除的位置。
                [tempReturnArr addObject:NetArr[j]];
                [NetArr removeObjectAtIndex:j];
            }
        }
    }
    if (NetArr.count > 0) {
        [tempReturnArr addObjectsFromArray:NetArr];
    }
    //    NSLog(@"排序好的数组是：%@ 个数：%ld",tempReturnArr,tempReturnArr.count);
    return tempReturnArr;
}

#pragma mark ------点击右上角加号方法扫描二维码
- (void)showQrcode
{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SGScanningQRCodeVC *scanningQRCodeVC = [[SGScanningQRCodeVC alloc] init];
                        [self.navigationController pushViewController:scanningQRCodeVC animated:YES];
                        NSLog(@"主线程 - - %@", [NSThread currentThread]);
                    });
                    NSLog(@"当前线程 - - %@", [NSThread currentThread]);
                    
                    // 用户第一次同意了访问相机权限
                    NSLog(@"用户第一次同意了访问相机权限");
                } else {
                    // 用户第一次拒绝了访问相机权限
                    NSLog(@"用户第一次拒绝了访问相机权限");
                }
            }];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
            [self setUpNavBack];
            SGScanningQRCodeVC *scanningQRCodeVC = [[SGScanningQRCodeVC alloc] init];
            [self.navigationController pushViewController:scanningQRCodeVC animated:YES];
        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            [unitl createAlertActionWithTitle:NSLocalizedString(@"已为“视频云眼”关闭相机", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开相机", nil) andController:self];
        } else if (status == AVAuthorizationStatusRestricted) {
            NSLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"未检测到您的摄像头", nil)];
    }
}

#pragma mark -----进入广告页面的通知方法
- (void)pushToAd {
    NSLog(@"广告链接页面");
}

#pragma mark - 警告框
- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

//=========================delegate=========================
#pragma mark ======= 切换不同视图的代理方法  cell点击方法 分组cell点击
//切换组别
- (void)SwitchGroupClick:(NSInteger)index
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:[NSNumber numberWithInteger:index] forKey:chooseGroup];
    [[NSNotificationCenter defaultCenter]postNotificationName:chooseGroup object:nil userInfo:dic];
    
    [unitl saveCurrentDisplayGroupIndex:index];
    
    UILabel * selectedLabel = self.nav_view.sc.groupBtnLabelArr[index];
    [selectedLabel setTextColor:MAIN_COLOR];
    NSArray * btnArr = self.nav_view.sc.groupBtnArr;
    //获取所有组别
    NSArray *allGroup = [[unitl getAllGroupCameraModel] copy];
    for (int i = 0; i < btnArr.count; i++) {
        deviceGroup *tempGroupModel = allGroup[i];
        if (i != index) {
            UIButton * tempBtn = btnArr[i];
            //其他组的状态
            if ([tempGroupModel.enableSensibility intValue] == 1) {
                [tempBtn setImage:[UIImage imageNamed:@"unselected_protected"] forState:UIControlStateNormal];
            }else{
                [tempBtn setImage:[UIImage imageNamed:@"unselected_Unprotected"] forState:UIControlStateNormal];
            }
        }
        if (i == index) {
            UIButton * tempBtn = btnArr[i];
            //当前选中的组的状态
            if ([tempGroupModel.enableSensibility intValue] == 1) {
                [tempBtn setImage:[UIImage imageNamed:@"selected_Protected"] forState:UIControlStateNormal];
            }else{
                [tempBtn setImage:[UIImage imageNamed:@"selected_Unprotected"] forState:UIControlStateNormal];
            }
        }
    }
    NSArray * btnLabelArr = self.nav_view.sc.groupBtnLabelArr;
    for (int i = 0; i < btnLabelArr.count; i++) {
        if (i != index) {
            UILabel * tempBtnLabel = btnLabelArr[i];
            [tempBtnLabel setTextColor:COLOR_TEXT];
        }
    }

    self.bgView.hidden = YES;
    groupModel *model = groupArr[index];

//    [UIView animateWithDuration:0.2 animations:^{
//        [self.nav_view.sc setScContentOffset:CGPointMake(-(groupBtnEdge + groupBtnWidth),0)];
//    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.nav_view.sc setScContentOffset:CGPointMake(groupBtnEdge + (index-1) * (groupBtnWidth + groupBtnEdge),0)];
    }];


//    NSString *str = [NSString stringWithFormat:@"我现在切换到%@",model.name];
//    [XHToast showCenterWithText:str];
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<groupArr.count; i++) {
        groupModel *tempModel = groupArr[i];
        if ([model.groupName isEqualToString:tempModel.groupName]) {
            tempModel.isCurrent = YES;
        }else{
            tempModel.isCurrent = NO;
        }
        [tempArr addObject:tempModel];
    }
    groupArr = [[NSMutableArray alloc]initWithArray:tempArr];
}
//对组别进行设置
- (void)GroupSettingClick:(NSInteger)index
{
    self.bgView.hidden = YES;
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    groupModel *model = groupArr[index];
    GroupSettingVC *setVC = [[GroupSettingVC alloc]init];
    setVC.groupModel = model;
    setVC.groupIndex = index;
    [self.navigationController pushViewController:setVC animated:YES];
}

#pragma 向服务器上传当前语言环境
- (void)setLanguageType:(BOOL)isChinese
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSNumber *languageType;
    if (isChinese) {
        languageType = [NSNumber numberWithInt:1];
    }else{
        languageType = [NSNumber numberWithInt:2];
    }
    [postDic setObject:languageType forKey:@"languageType"];
    [[HDNetworking sharedHDNetworking] POST:@"v1/user/setAppLanguage" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"语言服务器上传：%@",responseObject);
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//=========================lazy loading=========================
#pragma mark ----- 懒加载部分
//自定义的nav
- (nav_userDefine *)nav_view
{
    if (!_nav_view) {
        _nav_view = [[nav_userDefine alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, NavBarHeight_UserDefined) GroupNameAndIDArr:self.GroupNameAndIDArr];
        _nav_view.delegate = self;
        _nav_view.sc.delegate = self;
    }
    return _nav_view;
}

- (SwitchShowStyleView *)switchShowStyleView
{
    if (!_switchShowStyleView) {
        _switchShowStyleView = [[SwitchShowStyleView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, switchShowStyleView_height)GroupData:groupArr];
        _switchShowStyleView.delegate = self;
    }
    return _switchShowStyleView;
}
- (userDefine_bg_view *)bgView
{
    if (!_bgView) {
        _bgView = [[userDefine_bg_view alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
        _bgView.backgroundColor = RGBA(0, 0, 0, 0.5);
        _bgView.delegate = self;
    }
    return _bgView;
}
- (NSMutableArray *)GroupNameAndIDArr
{
    if (!_GroupNameAndIDArr) {
        _GroupNameAndIDArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _GroupNameAndIDArr;
}

//点击设置按钮弹出框
- (SwitchModeView *)switchView
{
    if (!_switchView) {
        _switchView = [[SwitchModeView alloc]initWithframe:CGRectZero];
    }
    return _switchView;
}


@end
