//
//  AboutUsVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/20.
//  Copyright © 2018 张策. All rights reserved.
//

#import "AboutUsVC.h"
//========Model========
#import "SGQRCodeTool.h"
//========View========
#import "AboutUsHeadCell.h"
#import "AboutUsCell.h"
#import "AboutUsQRCodeCell.h"
#import "AboutUsRelatedView.h"
#import "AboutUsShareView.h"
//========VC========
#import "ZCTabBarController.h"
#import "AboutUsAgreementVC.h"
#import "NSStringEX.h"
#import "AppUpdateManager.h"

@interface AboutUsVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    AboutUsRelatedViewDelegate
>
{
    UIApplication *app;
}
@property (nonatomic,strong)UIButton * officialEnvironmentBtn;//生产环境
@property (nonatomic,strong)UIButton * testEnvironmentBtn;//测试环境
@property (nonatomic,strong)UIView * btnBgView;
@property (nonatomic,strong)UILabel * showEnvironmentInfo;//显示当前的运行的环境

@property (nonatomic,strong) UITableView *tv_list;
@property (nonatomic,strong) AboutUsRelatedView *relatedBottomView;
@property (nonatomic,strong) AboutUsShareView *shareShowView;//分享弹出框
@property (nonatomic,assign) BOOL updateFlag;

@end

@implementation AboutUsVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkAppUpdate];
    [self setUpUI];
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
- (void)setUpUI{
    self.navigationItem.title = NSLocalizedString(@"关于我们", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    app = [UIApplication sharedApplication];
    /*
    //点击手势
    UITapGestureRecognizer *r6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    r6.numberOfTapsRequired = 6;
    [self.view addGestureRecognizer:r6];
    
    UITapGestureRecognizer *r8 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ClearEnvironmentInfo:)];
    r8.numberOfTapsRequired = 8;
    [self.view addGestureRecognizer:r8];
    */
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight));
    }];
    /*
    [self.view addSubview:self.relatedBottomView];
    [self.relatedBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 70));
    }];
    */
}


//==========================method==========================
- (void)checkAppUpdate {
    // check当前app版本是否要升级
    [AppUpdateManager checkAppUpdateComplete:^{
        self.updateFlag = YES;
        [self.tv_list reloadData];
    }];
}

- (void)copytext:(NSString *)contentStr
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = contentStr;
}
#pragma mark - 切换环境方法(内测)
- (void)tapGestureAction:(UITapGestureRecognizer*)tap
{
    NSLog(@"图标点击6次，修改环境");
    [self.view addSubview:self.btnBgView];
    [self.btnBgView addSubview:self.officialEnvironmentBtn];
    [self.btnBgView addSubview:self.testEnvironmentBtn];
    [self.view addSubview:self.showEnvironmentInfo];
    [self.btnBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(self.view.frame.size.width, 70));
    }];
    [self.officialEnvironmentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.btnBgView);
        make.left.mas_equalTo(self.btnBgView.mas_left);
        make.size.mas_equalTo(CGSizeMake(self.view.frame.size.width/2, 35));
    }];
    [self.testEnvironmentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.btnBgView);
        make.right.mas_equalTo(self.btnBgView.mas_right);
        make.size.mas_equalTo(CGSizeMake(self.view.frame.size.width/2, 35));
    }];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        dispatch_async(dispatch_get_main_queue(),^{
            if ([URLStr isEqualToString:official_Environment_key]) {
                [self.showEnvironmentInfo setText:NSLocalizedString(@"当前app运行环境：生产环境", nil)];
            }else if([URLStr isEqualToString:test_Environment_key]){
                [self.showEnvironmentInfo setText:NSLocalizedString(@"当前app运行环境：测试环境", nil)];
            }
        });
    }
    [self.showEnvironmentInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.btnBgView.mas_bottom).offset(50);
        make.left.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth,50));
    }];
}

- (void)ClearEnvironmentInfo:(UITapGestureRecognizer*)tap
{
    [self.btnBgView removeFromSuperview];
    [self.officialEnvironmentBtn removeFromSuperview];
    [self.testEnvironmentBtn removeFromSuperview];
    [self.showEnvironmentInfo removeFromSuperview];
}

- (void)officialEnvironmentBtnClick
{
    NSLog(@"修改为【生产环境】");
    [XHToast showCenterWithText:NSLocalizedString(@"已经切换成【生产环境】,请杀死app重新启动！", nil)];
    [[NSUserDefaults standardUserDefaults]setObject:official_Environment_key forKey:Environment];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}
- (void)testEnvironmentBtnClick
{
    [[NSUserDefaults standardUserDefaults]setObject:test_Environment_key forKey:Environment];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"修改为【测试环境】");
    [XHToast showCenterWithText:NSLocalizedString(@"已经切换成【测试环境】,请杀死app重新启动！", nil)];
}


//==========================delegate==========================
//组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return 1;
    }else{
        return 3;
    }
}

//cell样式
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;

    if (section == 0) {
        static NSString* AboutUsHeadCell_Identifier = @"AboutUsHeadCell_Identifier";
        AboutUsHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:AboutUsHeadCell_Identifier];
        if(!cell){
            cell = [[AboutUsHeadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AboutUsHeadCell_Identifier];
        }
//        if (isSimplifiedChinese) {
//            cell.logoIcon.image = [UIImage imageNamed:@"AboutUsLogo"];
//        }else{
//            cell.logoIcon.image = [UIImage imageNamed:@"EAboutUsLogo"];
//        }
        cell.logoIcon.image = [UIImage imageNamed:@"loginLogo"];
        cell.versionLb.text = APPVERSION;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (section == 1){
        static NSString* AboutUsCell_Identifier = @"AboutUsCell_Identifier";
        AboutUsCell *cell = [tableView dequeueReusableCellWithIdentifier:AboutUsCell_Identifier];
        if(!cell){
            cell = [[AboutUsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AboutUsCell_Identifier];
        }
        
        if (row == 0) {
            cell.titleLb.text = NSLocalizedString(@"视频云眼介绍", nil);
            cell.detailLb.text = NSLocalizedString(@"股票代码:300270", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell configRedDotShow:NO];
        }else if (row == 1){
            cell.titleLb.text = NSLocalizedString(@"版本更新", nil);
            if (self.updateFlag) {
                cell.detailLb.text = NSLocalizedString(@"发现新版本", nil);
            }
            [cell configRedDotShow:self.updateFlag];
        }else{
            cell.titleLb.text = NSLocalizedString(@"去评分", nil);
            [cell configRedDotShow:NO];
        }
        return cell;
    }else{
        static NSString* AboutUsQRCodeCell_Identifier = @"AboutUsQRCodeCell_Identifier";
        AboutUsQRCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:AboutUsQRCodeCell_Identifier];
        if(!cell){
            cell = [[AboutUsQRCodeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AboutUsQRCodeCell_Identifier];
        }
        BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
        NSString *urlStr = urlModel.appDownloadUrl;
        cell.QRCodeImg.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:urlStr imageViewWidth:300.f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if (section == 0) {
    }else if(section == 1){
        if (row == 0) {
            if (isSimplifiedChinese) {
                [self copytext:@"300270"];
                [XHToast showCenterWithText:NSLocalizedString(@"已复制", nil)];
            }
        }else if (row == 1){
            //版本更新
            NSString *urlStr = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@",shiguangyushipingAPPID];//APPID
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }else{
            //评分
            NSString *urlStr = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@?action=write-review",shiguangyushipingAPPID];//APPID
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }
    }else{
        AboutUsQRCodeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.view addSubview:self.shareShowView];
        self.shareShowView.shareImg = cell.QRCodeImg.image;
        [self.shareShowView setAboutUsShareViewShow];
    }
}

//cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 100;
    }else if (indexPath.section == 1){
        return 44;
    }else{
        return 150;
    }
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = [UIColor clearColor];
    return headView;
}
#pragma mark - 底部相关按钮的代理方法
//服务协议
- (void)agreementBtnAction
{
    AboutUsAgreementVC *agreementVC = [[AboutUsAgreementVC alloc]init];
    BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
    agreementVC.url = urlModel.userAgreementUrl;
    [self.navigationController pushViewController:agreementVC animated:YES];
}
//官网
- (void)websiteBtnAction
{
    NSString *urlStr = @"http://www.joyware.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}
//微信号
- (void)WeChatBtnAction
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"已复制公众号，去关注", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"继续", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
    [self copytext:NSLocalizedString(@"joywarevcloud中威视云", nil)];
    NSString *urlStr = @"weixin://";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                                                        }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//电话
- (void)telBtnAction
{
    NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", @"4008265826"];
    if (iOS_10_OR_LATER) {
        /// 10及其以上系统
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone] options:@{} completionHandler:nil];
    } else {
        /// 10以下系统
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
    }
}

//==========================lazy loading==========================
#pragma mark - getter&&setter
//表视图
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.backgroundColor = [UIColor clearColor];
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tv_list.scrollEnabled = NO;
        _tv_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tv_list;
}
//底部View
- (AboutUsRelatedView *)relatedBottomView
{
    if (!_relatedBottomView) {
        _relatedBottomView = [AboutUsRelatedView viewFromXib];
        _relatedBottomView.delegate = self;
    }
    return _relatedBottomView;
}

- (UIButton *)officialEnvironmentBtn
{
    if (!_officialEnvironmentBtn) {
        _officialEnvironmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_officialEnvironmentBtn setTitle:NSLocalizedString(@"生产环境", nil) forState:UIControlStateNormal];
        [_officialEnvironmentBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [_officialEnvironmentBtn addTarget:self action:@selector(officialEnvironmentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _officialEnvironmentBtn;
}
- (UIButton *)testEnvironmentBtn
{
    if (!_testEnvironmentBtn) {
        _testEnvironmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_testEnvironmentBtn setTitle:NSLocalizedString(@"测试环境", nil) forState:UIControlStateNormal];
        [_testEnvironmentBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [_testEnvironmentBtn addTarget:self action:@selector(testEnvironmentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testEnvironmentBtn;
}
- (UIView *)btnBgView
{
    if (!_btnBgView) {
        _btnBgView = [[UIView alloc]initWithFrame:CGRectZero];
        _btnBgView.backgroundColor = [UIColor yellowColor];
    }
    return _btnBgView;
}
- (UILabel *)showEnvironmentInfo
{
    if (!_showEnvironmentInfo) {
        _showEnvironmentInfo = [FactoryUI createLabelWithFrame:CGRectZero text:NSLocalizedString(@"当前app运行环境：生产环境（默认）", nil) font:FONT(17)];
        _showEnvironmentInfo.textAlignment =  NSTextAlignmentCenter;
        [_showEnvironmentInfo setTextColor:[UIColor purpleColor]];
    }
    return _showEnvironmentInfo;
}

- (AboutUsShareView *)shareShowView
{
    if (!_shareShowView) {
        _shareShowView = [[AboutUsShareView alloc]initWithframe:CGRectZero];
    }
    return _shareShowView;
}

@end
