//
//  FolderTreeVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/16.
//  Copyright © 2019 苏旋律. All rights reserved.
//
#define switchShowStyleView_height (iPhone_X_ ? 148 : 130)

#import "FolderTreeVC.h"
#import "ZCTabBarController.h"
/*二维码*/
#import "SGGenerateQRCodeVC.h"
#import "SGScanningQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
/*搜索页面*/
#import "searchVideoVC.h"
/*设备展示的VC*/
#import "smallScreenFolderVC.h"//小屏设备VC
#import "smallScreenChannelVC.h"//小屏通道VC
#import "bigScreenFolderVC.h"//大屏设备VC
#import "bigScreenChannelVC.h"//大屏通道VC
#import "fourScreenFolderVC.h"//四分屏设备VC
#import "fourScreenChannelVC.h"//四分屏通道VC

/*nav_bar*/
#import "nav_userFolder.h"
/*切换模式视图*/
#import "SwitchFolderTreeView.h"
/*切换模式时的背景图*/
#import "userDefine_bg_view.h"
/*文件树列表*/
#import "FolderTreeView.h"
#import "AppUpdateManager.h"

@interface FolderTreeVC ()
<
    nav_userFolder_delegate,
    folderTreeView_delegate,
    userDefine_bg_view_Delegate,
    SwitchFolderTreeViewDelegate
>
@property (nonatomic, strong) nav_userFolder *nav_view;/**< 自定义的nav */
@property (nonatomic, strong) SwitchFolderTreeView *switchFolderTreeView;/**< 用来选择视频展示模式 */
@property (nonatomic, strong) userDefine_bg_view *bgView;/**< 自定义控件的背景view */
@property (nonatomic, strong) FolderTreeView *treeView;/**< 文件树View */
@end

@implementation FolderTreeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpUI];
    [self checkAppUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)setUpUI
{
    [self.view addSubview:self.nav_view];
    [self.view addSubview:self.treeView];
}

// 检查APP版本更新
- (void)checkAppUpdate {
    [AppUpdateManager checkAppUpdateComplete:^{
        [self showUpdateAlert];
    }];
}

// 升级框提示
- (void)showUpdateAlert {
    NSString *message = @"检测到新版本";
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"版本更新" message:message preferredStyle:UIAlertControllerStyleAlert];
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

#pragma mark - 点击右上角加号方法扫描二维码
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

#pragma mark - 警告框
- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)changeVC:(CameraListDisplayMode)selectedMode
{
    UIViewController *vc = [self.childViewControllers lastObject];
    if ([vc isKindOfClass:[FolderTreeVC class]]) {
    } else {
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
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

    switch (selectedMode) {
        case CameraListDisplayMode_littleMode: {
            //通道模式与设备模式
            if (isChannelMode) {
                smallScreenChannelVC *myChannelVC = [[smallScreenChannelVC alloc]init];
                myChannelVC.nodeId = self.treeView.currentNodeId;
                myChannelVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
                [self addChildViewController:myChannelVC];
                [self.view addSubview:myChannelVC.view];
                [myChannelVC didMoveToParentViewController:self];
            } else {
                smallScreenFolderVC *myDdVC = [[smallScreenFolderVC alloc]init];
                myDdVC.nodeId = self.treeView.currentNodeId;
                myDdVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
                [self addChildViewController:myDdVC];
                [self.view addSubview:myDdVC.view];
                [myDdVC didMoveToParentViewController:self];
            }
        }
        break;
        case CameraListDisplayMode_largeMode: {
            if (isChannelMode) {
                bigScreenChannelVC *myChannelVC = [[bigScreenChannelVC alloc]init];
                myChannelVC.nodeId = self.treeView.currentNodeId;
                myChannelVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
                [self addChildViewController:myChannelVC];
                [self.view addSubview:myChannelVC.view];
                [myChannelVC didMoveToParentViewController:self];
            } else {
                bigScreenFolderVC *myDdVC = [[bigScreenFolderVC alloc]init];
                myDdVC.nodeId = self.treeView.currentNodeId;
                myDdVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
                [self addChildViewController:myDdVC];
                [self.view addSubview:myDdVC.view];
                [myDdVC didMoveToParentViewController:self];
            }
        }
        break;
        case CameraListDisplayMode_fourScreenMode: {
            if (isChannelMode) {
                fourScreenChannelVC *myChannelVC = [[fourScreenChannelVC alloc]init];
                myChannelVC.nodeId = self.treeView.currentNodeId;
                myChannelVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - NavBarHeight_UserDefined);
                [self addChildViewController:myChannelVC];
                [self.view addSubview:myChannelVC.view];
                [myChannelVC didMoveToParentViewController:self];
            } else {
                fourScreenFolderVC *myDdVC = [[fourScreenFolderVC alloc]init];
                myDdVC.nodeId = self.treeView.currentNodeId;
                myDdVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - NavBarHeight_UserDefined);
                [self addChildViewController:myDdVC];
                [self.view addSubview:myDdVC.view];
                [myDdVC didMoveToParentViewController:self];
            }
        }
        break;

        default:
            break;
    }
}

//=========================delegate=========================
#pragma mark - 返回按钮点击事件
- (void)backFolderTreeClick
{
    if (self.treeView.hidden == YES) {
        self.treeView.hidden = NO;
        UIViewController *vc = [self.childViewControllers lastObject];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
    self.nav_view.leftItemBtn.hidden = YES;
    [self.treeView popTableView];
}

#pragma mark - 获取当前层和节点名
- (void)getTreeIndex:(NSInteger)treeIndex andNodeName:(NSString *)nodeName
{
    self.nav_view.titleStr = nodeName;
    if (treeIndex == 1) {
        self.nav_view.backBtn.hidden = YES;
    } else {
        self.nav_view.backBtn.hidden = NO;
    }
}

#pragma mark - 首页初始化时的title 代理方法
- (void)getleafRootTitle:(NSString *)titleStr andisOnlyRoot:(BOOL)isOnlyRoot
{
    if (isOnlyRoot && self.nav_view.backBtn.hidden) {
        [self.nav_view.leftItemBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.centerY.mas_equalTo(self.nav_view.backBtn.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
    self.nav_view.titleStr = titleStr;
}

#pragma mark - 获取叶子节点下的设备列表
- (void)getleafNodeDeviceList
{
    self.nav_view.leftItemBtn.hidden = NO;
    self.treeView.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;

    if ([unitl CameraListDisplayMode] == CameraListDisplayMode_littleMode) {
        //通道模式与设备模式
        if (isChannelMode) {
            smallScreenChannelVC *myChannelVC = [[smallScreenChannelVC alloc]init];
            myChannelVC.nodeId = self.treeView.currentNodeId;
            myChannelVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
            [self addChildViewController:myChannelVC];
            [self.view addSubview:myChannelVC.view];
            [myChannelVC didMoveToParentViewController:self];
        } else {
            smallScreenFolderVC *myDdVC = [[smallScreenFolderVC alloc]init];
            myDdVC.nodeId = self.treeView.currentNodeId;
            myDdVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
            [self addChildViewController:myDdVC];
            [self.view addSubview:myDdVC.view];
            [myDdVC didMoveToParentViewController:self];
        }
    } else if ([unitl CameraListDisplayMode] == CameraListDisplayMode_largeMode) {
        if (isChannelMode) {
            bigScreenChannelVC *myChannelVC = [[bigScreenChannelVC alloc]init];
            myChannelVC.nodeId = self.treeView.currentNodeId;
            myChannelVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
            [self addChildViewController:myChannelVC];
            [self.view addSubview:myChannelVC.view];
            [myChannelVC didMoveToParentViewController:self];
        } else {
            bigScreenFolderVC *myDdVC = [[bigScreenFolderVC alloc]init];
            myDdVC.nodeId = self.treeView.currentNodeId;
            myDdVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight);
            [self addChildViewController:myDdVC];
            [self.view addSubview:myDdVC.view];
            [myDdVC didMoveToParentViewController:self];
        }
    } else if ([unitl CameraListDisplayMode] == CameraListDisplayMode_fourScreenMode) {
        if (isChannelMode) {
            fourScreenChannelVC *mychannelVC = [[fourScreenChannelVC alloc]init];
            mychannelVC.nodeId = self.treeView.currentNodeId;
            mychannelVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight);
            [self addChildViewController:mychannelVC];
            [self.view addSubview:mychannelVC.view];
            [mychannelVC didMoveToParentViewController:self];
        } else {
            fourScreenFolderVC *myDdVC = [[fourScreenFolderVC alloc]init];
            myDdVC.nodeId = self.treeView.currentNodeId;
            myDdVC.view.frame = CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight);
            [self addChildViewController:myDdVC];
            [self.view addSubview:myDdVC.view];
            [myDdVC didMoveToParentViewController:self];
        }
    }
}

#pragma mark - 模式切换按钮点击事件
- (void)leftItemBtnClick
{
    if (self.bgView.hidden == YES) {//已经创建了
        self.bgView.hidden = NO;
    } else {
        UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
        [currentWindow addSubview:self.bgView];
        [UIView animateWithDuration:1.0f animations:^{
            [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.mas_equalTo(currentWindow);
            }];
        } completion:^(BOOL finished) {
            [self.bgView addSubview:self.switchFolderTreeView];
            [self.switchFolderTreeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(self.bgView);
                make.top.mas_equalTo(self.bgView);
                make.height.mas_equalTo(switchShowStyleView_height);
            }];
        }];
    }
}

#pragma mark - 切换模式点击事件
- (void)SwitchShowStyleBtnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case TAG_CLOSEBTN://关闭
        {
            self.bgView.hidden = YES;
        }
        break;

        case TAG_LITTLEMODE://小屏模式
        {
            btn.selected = YES;
            self.switchFolderTreeView.largeMode.selected = NO;
            self.switchFolderTreeView.fourScreenMode.selected = NO;
            self.bgView.hidden = YES;
            self.switchFolderTreeView.titleLb.text = NSLocalizedString(@"小屏模式", nil);
            [self changeVC:CameraListDisplayMode_littleMode];
        }
        break;
        case TAG_LARGEMODE://大屏模式
        {
            btn.selected = YES;
            self.switchFolderTreeView.fourScreenMode.selected = NO;
            self.switchFolderTreeView.littleMode.selected = NO;
            self.bgView.hidden = YES;
            self.switchFolderTreeView.titleLb.text = NSLocalizedString(@"大屏模式", nil);
            [self changeVC:CameraListDisplayMode_largeMode];
        }
        break;
        case TAG_FOURSCREENMODE://瀑布流，4分屏模式
        {
            btn.selected = YES;
            self.switchFolderTreeView.largeMode.selected = NO;
            self.switchFolderTreeView.littleMode.selected = NO;
            self.bgView.hidden = YES;
            self.switchFolderTreeView.titleLb.text = NSLocalizedString(@"四分屏模式", nil);
            [self changeVC:CameraListDisplayMode_fourScreenMode];
        }
        break;

        default:
            break;
    }
}

#pragma mark 自定义view的背景view ==关闭功能
- (void)bg_view_TapAction:(UITapGestureRecognizer *)tap
{
    self.bgView.hidden = YES;
}

#pragma mark - 添加设备按钮点击事件
- (void)rightItemBtnClick
{
    [self showQrcode];
//    if (isChannelMode) {
//        searchVideoVC *searchVC = [[searchVideoVC alloc]init];
//        [self.navigationController pushViewController:searchVC animated:YES];
//    } else {
//        [self showQrcode];
//    }
}

//=========================lazy loading=========================
#pragma mark - getters && setters
//自定义的nav
- (nav_userFolder *)nav_view
{
    if (!_nav_view) {
        _nav_view = [[nav_userFolder alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneNav_StatusHeight)];
        _nav_view.delegate = self;
    }
    return _nav_view;
}

//切换模式时的背景图
- (userDefine_bg_view *)bgView
{
    if (!_bgView) {
        _bgView = [[userDefine_bg_view alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
        _bgView.backgroundColor = RGBA(0, 0, 0, 0.5);
        _bgView.delegate = self;
    }
    return _bgView;
}

- (SwitchFolderTreeView *)switchFolderTreeView
{
    if (!_switchFolderTreeView) {
        _switchFolderTreeView = [[SwitchFolderTreeView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, switchShowStyleView_height)];
        _switchFolderTreeView.delegate = self;
    }
    return _switchFolderTreeView;
}

//文件树View
- (FolderTreeView *)treeView
{
    if (!_treeView) {
        _treeView = [[FolderTreeView alloc]initWithFrame:CGRectMake(0, iPhoneNav_StatusHeight, iPhoneWidth, iPhoneHeight - iPhoneNav_StatusHeight - iPhoneToolBarHeight)];
        _treeView.delegate = self;
    }
    return _treeView;
}

@end
