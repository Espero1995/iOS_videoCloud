//
//  ProtectionModeVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ProtectionModeVC.h"
//========Model========
//========View========
/*segment*/
#import "ProtectModeSegControl.h"
/*无内容是显示视图*/
#import "GroupNoDevBGView.h"
#import "ProtectionModeCell.h"
//========VC========
#import "ZCTabBarController.h"

@interface ProtectionModeVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ProtectModeSegControlDelegate,
    GroupNoDevBGViewDelegate
>
{
    BOOL isStayHome;//是否处于在家模式
}
@property (nonatomic,strong) ProtectModeSegControl *segment;
@property (nonatomic,strong) UITableView *tv_list;
@property (nonatomic,strong) GroupNoDevBGView* bgView;//无内容时背景图
@end

@implementation ProtectionModeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"防护模式设置", nil);
    self.view.backgroundColor = BG_COLOR;
    isStayHome = YES;
    [self cteateNavBtn];
    /*
     * 注意：我现在假装以modelName是否为我的设备来区分有无设备时分别的显示状态
     */
    if ([self.groupModel.groupName isEqualToString:NSLocalizedString(@"我的设备", nil)]) {
        [self.bgView removeFromSuperview];
        [self setDevUpUI];
    }else{
        [self.view addSubview:self.bgView];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setDevUpUI{
    [self.view addSubview:self.segment];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(15);
        make.size.mas_equalTo(CGSizeMake(0.95*iPhoneWidth, 50));
    }];
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.segment.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight-85));
    }];
}


//==========================delegate==========================
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  1;
}
//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }else{
        return 0.0001;
    }
}
//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    if (section == 0) {
        headView.frame = CGRectMake(0, 0, iPhoneWidth, 30);
        UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 20)];
        tipLb.font = FONT(15);
        tipLb.textColor = RGB(150, 150, 150);
        [headView addSubview:tipLb];
        if (isStayHome) {
            tipLb.text = NSLocalizedString(@"在家时的活动检测提醒设置", nil);
        }else{
            tipLb.text = NSLocalizedString(@"外出时的活动检测提醒设置", nil);
        }
    }else{
         headView.frame = CGRectMake(0, 0, iPhoneWidth, 0.0001);
    }
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //加载自定义的Cell
    static NSString *ProtectionModeCell_Identifier = @"ProtectionModeCell_Identifier";
    ProtectionModeCell* cell = [tableView dequeueReusableCellWithIdentifier:ProtectionModeCell_Identifier];
    if(!cell){
        cell = [[ProtectionModeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProtectionModeCell_Identifier];
    }
    cell.devNameLb.text = @"";
    cell.devImg.image = [UIImage imageNamed:@"img1"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}
#pragma mark - segment选择数据源的代理方法
- (void)didSelectSegmentWithIndex:(NSInteger)index{
    if (index == 0) {
        isStayHome = YES;
        NSLog(@"当前处于在家模式");
        [self.tv_list reloadData];
    }else{
        isStayHome = NO;
        NSLog(@"当前处于外出模式");
        [self.tv_list reloadData];
    }
}

#pragma mark - 无设备时点击商城的代理方法
- (void)shopBtnClick
{
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    tabVC.tabLastSelectedIndex = 0;
    tabVC.selectedIndex = 2;
    tabVC.tabSelectIndex = 2;
}

#pragma mark - getter && setter
- (ProtectModeSegControl *)segment
{
    if (!_segment) {
        _segment = [ProtectModeSegControl creatSegmentedControlWithTitle:@[NSLocalizedString(@"在家模式", nil),NSLocalizedString(@"外出模式", nil)] withRadius:5];
        _segment.delegate = self;
    }
    return _segment;
}

- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.separatorStyle = NO;
    }
    return _tv_list;
}

//无内容时的背景图
-(GroupNoDevBGView *)bgView{
    if (!_bgView) {
        _bgView = [[GroupNoDevBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"groupNoProtectDevice"] bgTip:@"没有支持防护模式的设备"];
    }
    _bgView.delegate = self;
    return _bgView;
}

@end
