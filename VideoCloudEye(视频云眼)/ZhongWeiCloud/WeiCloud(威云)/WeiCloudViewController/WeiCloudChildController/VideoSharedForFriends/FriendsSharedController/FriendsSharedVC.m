//
//  FriendsSharedVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/27.
//  Copyright © 2018年 张策. All rights reserved.
//
#define MAXLENGTH 11
#import "FriendsSharedVC.h"

//========Model========
#import "UIImage+image.h"
//#import "ShareFeatureModel.h"
#import "MyShareModel.h"
/*通讯录*/
#import "SXAddressBookManager.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
//========View========
#import "RowView.h"
#import "ShareDetailCell.h"
//========VC========
/*工具栏*/
#import "ZCTabBarController.h"
/*权限*/
#import "SharePermissionVC.h"
/*时段限制*/
#import "SharetimeLimitVC.h"
/*分享时段*/
#import "SharePeriodVC.h"
/*对个人进行权限设置*/
#import "FriendShareDetailVC.h"

@interface FriendsSharedVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ShareDetailCellDelegate,
    rowViewDelegate,
    CNContactPickerDelegate,
    UITextFieldDelegate
>
{
    NSString *startTime;
    NSString *endTime;
}
/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
/*权限View*/
@property (nonatomic,strong) RowView *headRowFirstView;
/*分享时限View*/
@property (nonatomic,strong) RowView *headRowSecondView;
/*分享时段View*/
@property (nonatomic,strong) RowView *headRowThirdView;
/*添加联系人View*/
@property (nonatomic,strong) UIView *shareFriendsView;
/*联系人数组*/
@property (nonatomic,strong) NSMutableArray *dataArr;
/*手机号*/
@property (nonatomic,copy) NSString *iphoneNumberStr;
/*分享设备能力集model*/
@property (nonatomic,strong) shareFeature *shareModel;
/*手机文本信息*/
@property (nonatomic,strong) UITextField *phonetf;
@property (nonatomic,copy) NSString *remarkNameStr;
@end

@implementation FriendsSharedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"设备分享", nil);
    //找到本地的model
    NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
    tempAllGroupArr = [unitl getAllGroupCameraModel];
    NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
    devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
    
    for (int i = 0; i < devListArr.count; i++) {
        if ([((dev_list *)devListArr[i]).ID isEqualToString:self.dev_mList.ID]) {
            dev_list *testDevModel = devListArr[i];
            NSLog(@"我看看结果：%@",testDevModel.ext_info.shareFeature.startTime);
            self.dev_mList = testDevModel;
        }
    }
    
    [self cteateNavBtn];
    self.view.backgroundColor = BG_COLOR;
    [self setUpUI];
    [self.view addSubview:self.tv_list];
    [self pullMethod];
}

- (void)pullMethod
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getShareDeviceList)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    [self getDevPermissions];
    //刷新下列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullMethod) name:@"friendShareCancel" object:nil];
}

#pragma mark - UI
- (void)setUpUI
{
    UILabel *phoneTipLb = [[UILabel alloc]init];
    if (isOverSeas) {
        phoneTipLb.text = NSLocalizedString(@"邮箱分享", nil);
    }else{
       phoneTipLb.text = NSLocalizedString(@"手机号/邮箱分享", nil);
    }
    phoneTipLb.font = FONT(16);
    phoneTipLb.textColor = RGB(50, 50, 50);
    [self.view addSubview:phoneTipLb];
    [phoneTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(15);
        make.top.equalTo(self.view.mas_top).offset(20);
    }];
    
    [self.view addSubview:self.shareFriendsView];
    [self.shareFriendsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(phoneTipLb.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 50));
    }];
    
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    if ([unitl isEmailAccountType]) {
        [addBtn setImage:[UIImage imageNamed:@"emailIcon"] forState:UIControlStateNormal];
        addBtn.userInteractionEnabled = NO;
    }else{
        [addBtn setImage:[UIImage imageNamed:@"addressBook"] forState:UIControlStateNormal];
        addBtn.userInteractionEnabled = YES;
    }
    [addBtn addTarget:self action:@selector(addContacts) forControlEvents:UIControlEventTouchUpInside];
    [self.shareFriendsView addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shareFriendsView.mas_centerY);
        make.left.equalTo(self.shareFriendsView.mas_left).offset(0);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    UIButton *shareBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [shareBtn setTitle:NSLocalizedString(@"分享", nil) forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareFriendsClick) forControlEvents:UIControlEventTouchUpInside];
    shareBtn.titleLabel.font = FONT(16);
    [shareBtn setTitleColor:RGB(50, 50, 50) forState:UIControlStateNormal];
    [self.shareFriendsView addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shareFriendsView.mas_centerY);
        make.right.equalTo(self.shareFriendsView.mas_right).offset(-15);
    }];
    UILabel *leftLb = [[UILabel alloc]init];
    leftLb.backgroundColor = RGB(200, 200, 200);
    [self.shareFriendsView addSubview:leftLb];
    [leftLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shareFriendsView.mas_centerY);
        make.left.equalTo(addBtn.mas_right).offset(0);
        make.width.mas_equalTo(@1);
        make.top.equalTo(self.shareFriendsView.mas_top).offset(10);
        make.bottom.equalTo(self.shareFriendsView.mas_bottom).offset(-10);
    }];
    
    UILabel *rightLb = [[UILabel alloc]init];
    rightLb.backgroundColor = RGB(200, 200, 200);
    [self.shareFriendsView addSubview:rightLb];
    [rightLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shareFriendsView.mas_centerY);
        make.right.equalTo(shareBtn.mas_left).offset(-15);
        make.width.mas_equalTo(@1);
        make.top.equalTo(self.shareFriendsView.mas_top).offset(10);
        make.bottom.equalTo(self.shareFriendsView.mas_bottom).offset(-10);
    }];
    
    [self.shareFriendsView addSubview:self.phonetf];
    [self.phonetf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.shareFriendsView.mas_centerX);
        make.centerY.equalTo(self.shareFriendsView.mas_centerY);
        make.left.equalTo(self.shareFriendsView.mas_left).offset(60);
        make.right.equalTo(self.shareFriendsView.mas_right).offset(-75);
    }];
    
    UILabel *configTipLb = [[UILabel alloc]init];
    configTipLb.text = NSLocalizedString(@"分享配置", nil);
    configTipLb.font = FONT(16);
    configTipLb.textColor = RGB(50, 50, 50);
    [self.view addSubview:configTipLb];
    [configTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(15);
        make.top.equalTo(self.shareFriendsView.mas_bottom).offset(20);
    }];
    
    [self.view addSubview:self.headRowFirstView];
    [self.headRowFirstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(configTipLb.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
    }];

    [self.view addSubview:self.headRowSecondView];
    [self.headRowSecondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.headRowFirstView.mas_bottom).offset(1);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
    }];
    [self.view addSubview:self.headRowThirdView];
    [self.headRowThirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.headRowSecondView.mas_bottom).offset(1);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
    }];
    
}


//==================method========================
#pragma mark - 获取设备权限
- (void)getDevPermissions
{
    if (self.modifyPermissionArr.count == 0) {
        //给其初始化（其他）能力集
        if (self.dev_mList.ext_info.shareFeature) {
            self.shareModel = self.dev_mList.ext_info.shareFeature;
            NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
            [tempArr addObject:NSLocalizedString(@"预览", nil)];
            [tempArr addObject:NSLocalizedString(@"声音", nil)];
            if ([self.shareModel.hp intValue] == 1) {
                [tempArr addObject:NSLocalizedString(@"回放", nil)];
            }
            if ([self.shareModel.alarm intValue] == 1) {
                [tempArr addObject:NSLocalizedString(@"告警", nil)];
            }
            if ([self.shareModel.talk intValue]== 1) {
                [tempArr addObject:NSLocalizedString(@"对讲", nil)];
            }
            if ([self.shareModel.ptz intValue]== 1) {
                [tempArr addObject:NSLocalizedString(@"云台", nil)];
            }
            self.headRowFirstView.subTitleLb.text = [tempArr componentsJoinedByString:@"、"];
        }else{
            //权限
            self.headRowFirstView.subTitleLb.text = NSLocalizedString(@"预览、声音", nil);
        }
    }else{
        //权限
        self.headRowFirstView.subTitleLb.text = [self.modifyPermissionArr componentsJoinedByString:@"、"];
    }
    
    
    if (self.modifyPermissionDic) {
        //这种显示方式有歧义，故先不显示【时限】
        NSNumber *tempLimtNum = [self.modifyPermissionDic objectForKey:@"timeLimit"];
        if ([tempLimtNum intValue] == 0) {//默认为0 设置即永久
            self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"永久", nil);
        }else if ([tempLimtNum intValue] == 1){
            self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"1天", nil);
        }else if ([tempLimtNum intValue] == 3){
            self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"3天", nil);
        }else if ([tempLimtNum intValue] == 7){
            self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"7天", nil);
        }else{
            self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"永久", nil);
        }
        
        //时段
       startTime = [self.modifyPermissionDic objectForKey:@"startTime"];
       endTime = [self.modifyPermissionDic objectForKey:@"endTime"];
        if (!startTime) {
            startTime = @"00:00";
        }
        if (!endTime) {
            endTime = @"23:59";
        }
        
        //时间
        if ([self compareTime:startTime andMaxTime:endTime]) {
            self.headRowSecondView.subTitleLb.text = [NSString stringWithFormat:@"%@~%@(%@)",startTime,endTime,NSLocalizedString(@"第二天", nil)];
        }else{
            self.headRowSecondView.subTitleLb.text = [NSString stringWithFormat:@"%@~%@",startTime,endTime];
        }
  
        
    }else{
        //给其初始化（其他）能力集
        if (self.dev_mList.ext_info.shareFeature) {
            //这种显示方式有歧义，故先不显示【时限】
            if (self.shareModel.timeLimit == 0) {//默认为0 设置即永久
                self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"永久", nil);
            }else if ([self.shareModel.timeLimit intValue] == 1){
                self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"1天", nil);
            }else if ([self.shareModel.timeLimit intValue] == 3){
                self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"3天", nil);
            }else if ([self.shareModel.timeLimit intValue] == 7){
                self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"7天", nil);
            }else{
                self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"永久", nil);
            }
        }else{
            self.headRowThirdView.subTitleLb.text = NSLocalizedString(@"永久", nil);
        }
        
        //时段
        startTime = self.shareModel.startTime;
        endTime = self.shareModel.endTime;
        if (!startTime) {
            startTime = @"00:00";
        }
        if (!endTime) {
            endTime = @"23:59";
        }
        if ([self compareTime:startTime andMaxTime:endTime]) {
            self.headRowSecondView.subTitleLb.text = [NSString stringWithFormat:@"%@~%@(%@)",startTime,endTime,NSLocalizedString(@"第二天", nil)];
        }else{
            self.headRowSecondView.subTitleLb.text = [NSString stringWithFormat:@"%@~%@",startTime,endTime];
        }
    }
    
    
}

#pragma mark - 获取分享的用户
- (void)getShareDeviceList{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/share/device-shared-info" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self.dataArr removeAllObjects];
            MyShareModel *listModel = [MyShareModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.dataArr = [shared mj_objectArrayWithKeyValuesArray:listModel.userList];
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }
        else{
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.tv_list.mj_header endRefreshing];
    }];
    
}
#pragma mark - 添加分享联系人
- (void)addContacts
{
    [self checkStatus2];
}

#pragma mark - 比较两个时间段【判断同一天还是第二天】
- (BOOL)compareTime:(NSString *)min andMaxTime:(NSString *)max
{
    if ([min length] != 0  && [max length] != 0) {
        //小时间的小时部分
        NSRange minrH = {0,2};
        NSString *minStrH = [min substringWithRange:minrH];
        int minH = [minStrH intValue];
        //大时间的小时部分
        NSRange maxrH = {0,2};
        NSString *maxStrH = [max substringWithRange:maxrH];
        int maxH = [maxStrH intValue];
        //小时间的分钟部分
        NSString *minStrM = [min substringFromIndex:3];
        int minM = [minStrM intValue];
        //大时间的小时部分
        NSString *maxStrM = [max substringFromIndex:3];
        int maxM = [maxStrM intValue];
        //    NSLog(@"%d:%d;%d:%d",minH,minM,maxH,maxM);
        if (maxH > minH) {
            return NO;
        }else if(maxH < minH){
            return YES;
        }else{
            if (maxM > minM) {
                return NO;
            }else{
                return YES;
            }
        }
    }else{
        return NO;
    }
}

//========================delegate========================
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}


//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return 40;
    }else{
        return 0.001;
    }
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    if (section == 0) {
        if (self.dataArr.count != 0) {
            UILabel *tiplb = [FactoryUI createLabelWithFrame:CGRectMake(15, 20, 100, 15) text:NSLocalizedString(@"分享用户", nil) font:FONT(16)];
            tiplb.textColor = RGB(50, 50, 50);
            [headView addSubview:tiplb];
        }
    }
    return headView;
}


//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ShareDetailCell_Identifier = @"ShareDetailCell_Identifier";
    ShareDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:ShareDetailCell_Identifier];
    if(!cell){
        cell = [[ShareDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ShareDetailCell_Identifier];
    }
    shared *listModel = self.dataArr[indexPath.row];
    if (![listModel.remarks isEqualToString:@""]) {
        cell.remarkNameLb.text = listModel.remarks;
    }else{
        cell.remarkNameLb.text = listModel.name;
    }
    
    if ([NSString isNull:listModel.mobile]) {
        cell.mobileLb.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"邮箱", nil),listModel.mail];
    }else{
        cell.mobileLb.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"手机号码", nil),[listModel.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
    }

    cell.delegate = self;
    cell.headImage.image = [UIImage imageNamed:@"myhead"];
    return cell;
}


#pragma mark - 点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    shared *listModel = self.dataArr[indexPath.row];
    FriendShareDetailVC *detailVC = [[FriendShareDetailVC alloc]init];
    detailVC.sharedPersonID = listModel.ID;
    detailVC.dev_mList = self.dev_mList;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}


#pragma mark - headRowHead点击事件
- (void)didSelectRowView:(NSInteger )row
{
    [self.phonetf resignFirstResponder];
        if (row == 1) {//分享权限
            SharePermissionVC *spVC = [[SharePermissionVC alloc]init];
            spVC.dev_mList = self.dev_mList;
            spVC.modifyPermissionDic = self.modifyPermissionDic;
            [self.navigationController pushViewController:spVC animated:YES];
        }else if (row == 2){
            SharePeriodVC *spVC = [[SharePeriodVC alloc]init];
            spVC.startTime = startTime;
            spVC.endTime = endTime;
            spVC.dev_mList = self.dev_mList;
            spVC.modifyPermissionDic = self.modifyPermissionDic;
            [self.navigationController pushViewController:spVC animated:YES];
        }else if (row == 3){
            SharetimeLimitVC *slVC = [[SharetimeLimitVC alloc]init];
            slVC.dev_mList = self.dev_mList;
            slVC.modifyPermissionDic = self.modifyPermissionDic;
            [self.navigationController pushViewController:slVC animated:YES];
        }
}

#pragma mark - 备注名称代理方法
- (void) ShareDetailRemarkClick:(ShareDetailCell *)cell
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"请输入备注名", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleDestructive handler:nil]];
    
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *contentTextField = alertController.textFields.firstObject;
        if ([contentTextField.text isEqualToString:@""]) {
        }else{
            cell.remarkNameLb.text = contentTextField.text;
            self.remarkNameStr = contentTextField.text;
            [self modifyRemarkName:cell];
        }
        
    }]];
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"请输入备注名", nil);
        textField.text = cell.remarkNameLb.text;
    }];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)modifyRemarkName:(ShareDetailCell *)cell
{
    NSIndexPath *indexPath = [self.tv_list indexPathForCell:cell];
    shared *listModel = self.dataArr[indexPath.row];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:listModel.ID forKey:@"to_userId"];
    [postDic setObject:self.remarkNameStr forKey:@"remarks"];
    /*
     * description: POST v1/user/setupRemarks(用户备注修改)
     *  access_token=<令牌> & user_id =<用户ID>&to_userId=<被分享用户ID>&remarks =<被分享用户昵称>
     */
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/setupRemarks" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"post:%@ \nresponseObject:%@",postDic,responseObject);
        self.remarkNameStr = @"";
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败");
    }];
}


- (void)checkStatus2
{
    WeakSelf(self);
    [[SXAddressBookManager manager]checkStatusAndDoSomethingSuccess:^{
        
        NSLog(@"已经有权限，做相关操作，可以做读取通讯录等操作");
        [weakSelf openAddressPhone];
    } failure:^{
        NSLog(@"未得到权限，做相关操作，可以做弹窗询问等操作");
        [unitl createAlertActionWithTitle:NSLocalizedString(@"已为“视频云眼”关闭通讯录", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开通讯录", nil) andController:self];
    }];
}

- (void)openAddressPhone
{
    [[SXAddressBookManager manager]presentPageOnTarget:self chooseAction:^(SXPersonInfoEntity *person) {
        NSLog(@"%@---%@",person.fullname,person.phoneNumber);
//        NSString *nameStr = [NSString stringWithFormat:@"（%@）",person.fullname];
        self.remarkNameStr = person.fullname;
        //处理86号码
        self.iphoneNumberStr = [NSString formatPhoneNum:person.phoneNumber];
        NSString *newString = [NSString stringWithFormat:@"%@",self.iphoneNumberStr];
        [self performSelector:@selector(openNewShareViewWithPhoneStr:) withObject:newString afterDelay:0.05];
    }];
}

- (void)openNewShareViewWithPhoneStr:(NSString *)newString
{
    self.phonetf.text = newString;
    NSLog(@"这个名字是：%@",newString);
}



//打开通讯录
-(void)pressBtn{
    //让用户给权限,没有的话会被拒的各位
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error) {
                NSLog(@"weishouquan");
            }else
            {
                NSLog(@"chenggong ");//用户给权限了
                CNContactPickerViewController * picker = [CNContactPickerViewController new];
                picker.delegate = self;
                picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];//只显示手机号
                [self presentViewController: picker  animated:YES completion:nil];
            }
        }];
    }
    
    if (status == CNAuthorizationStatusAuthorized) {//有权限时
        CNContactPickerViewController * picker = [CNContactPickerViewController new];
        picker.delegate = self;
        picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
        [self presentViewController: picker  animated:YES completion:nil];
    }
    else{
        NSLog(@"您未开启通讯录权限,请前往设置中心开启");
    }
}


//分享的网络请求
- (void)shareHttpFuncPhoneStr:(NSString *)phoneStr
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"请稍候...", nil)];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:self.dev_mList.ID forKey:@"dev_id"];
    if (self.remarkNameStr) {
        [postDic setObject:self.remarkNameStr forKey:@"remarks"];
    }else{
        [postDic setObject:@"" forKey:@"remarks"];
    }
    
    if ([NSString isValidateEmail:phoneStr]) {
        [postDic setObject:[NSNumber numberWithInt:2] forKey:@"accountType"];
        [postDic setObject:phoneStr forKey:@"mail"];
    }else{
        [postDic setObject:[NSNumber numberWithInt:1] forKey:@"accountType"];
        [postDic setObject:phoneStr forKey:@"mobile"];
    }
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/shareNew" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"postDic:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"分享成功", nil)];
                self.phonetf.text = @"";
                self.remarkNameStr = @"";
                [self.phonetf resignFirstResponder];
                [self pullMethod];
            });
            
            
        }
        else if (ret == 1102){
            [XHToast showCenterWithText:NSLocalizedString(@"分享失败，您不是设备拥有者", nil)];
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//[CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在发送重启指令...", nil)];
- (void)shareFriendsClick
{
    
    if (self.dataArr.count >= 10) {//self.dev_mList.shraedLimit
        [XHToast showCenterWithText:NSLocalizedString(@"当前最多可分享10人", nil)];
        return ;
    }
    
    for (int i = 0; i<self.dataArr.count; i++) {
        shared *shareModel = self.dataArr[i];
        NSString *phoneStr = shareModel.mobile;
        
        if ([phoneStr isEqualToString:self.phonetf.text]) {
            [XHToast showCenterWithText:NSLocalizedString(@"该用户已分享", nil)];
            return;
        }
    }
    
    UserModel *userModel = [unitl getUserModel];
    
    if (isOverSeas) {
        if (![NSString isValidateEmail:self.phonetf.text]) {
            //请输入正确的邮箱
            [XHToast showCenterWithText:NSLocalizedString(@"请输入正确的邮箱", nil)];
        }else{
            if (![userModel.mobile isEqualToString:self.phonetf.text]) {
                [self shareHttpFuncPhoneStr:self.phonetf.text];
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"自己设备无法分享给自己", nil)];
            }
        }
    }else{
        //1如果有通讯录电话号码
        if (self.iphoneNumberStr.length>0) {
            //如果电话号码合法
            if ([NSString validateMobile:self.phonetf.text]) {
                if (![userModel.mobile isEqualToString:self.iphoneNumberStr]) {
                    [self shareHttpFuncPhoneStr:self.iphoneNumberStr];
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"自己设备无法分享给自己", nil)];
                }
            }
            //如果选择通讯录后又重新输入号码合法
            else if ([NSString validateMobile:self.phonetf.text]){
                if (![userModel.mobile isEqualToString:self.phonetf.text]) {
                    [self shareHttpFuncPhoneStr:self.phonetf.text];
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"自己设备无法分享给自己", nil)];
                }
            }
            else{
                [XHToast showCenterWithText:NSLocalizedString(@"请输入正确的手机号", nil)];
            }
            self.iphoneNumberStr = nil;
        }else{
            
            if ((![NSString isValidateEmail:self.phonetf.text]) && (![NSString validateMobile:self.phonetf.text]) ) {
                [XHToast showCenterWithText:NSLocalizedString(@"请输入正确的邮箱或手机号", nil)];
            }else{
                if ([unitl isEmailAccountType]) {
                    if (![userModel.mail isEqualToString:self.phonetf.text]) {
                        [self shareHttpFuncPhoneStr:self.phonetf.text];
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"自己设备无法分享给自己", nil)];
                    }
                }else{
                    if (![userModel.mobile isEqualToString:self.phonetf.text]) {
                        [self shareHttpFuncPhoneStr:self.phonetf.text];
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"自己设备无法分享给自己", nil)];
                    }
                }
            }
            
        }
    }
    
  
}



//==========================delegate==========================
#pragma mark - textfield Delegate
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.phonetf) {
        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        //so easy
        else if (self.phonetf.text.length >= MAXLENGTH) {
            self.phonetf.text = [textField.text substringToIndex:MAXLENGTH];
            return NO;
        }
        
    }
    return [self validateNumber:string];
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

*/

#pragma mark - getter&&setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 270, iPhoneWidth, iPhoneHeight-64-270) style:UITableViewStylePlain];
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0)];
        _tv_list.tableHeaderView = headView;
    }
    return _tv_list;
}
//权限View
- (RowView *)headRowFirstView
{
    if (!_headRowFirstView) {
        _headRowFirstView = [[RowView alloc]init];
        _headRowFirstView.row = 1;
        _headRowFirstView.rowViewDelegate = self;
        _headRowFirstView.backgroundColor = [UIColor whiteColor];
        _headRowFirstView.titleLb.text = NSLocalizedString(@"分享权限", nil);
        _headRowFirstView.subTitleLb.text = NSLocalizedString(@"预览、声音", nil);
    }
    return _headRowFirstView;
}
//分享时限
- (RowView *)headRowSecondView
{
    if (!_headRowSecondView) {
        _headRowSecondView = [[RowView alloc]init];
        _headRowSecondView.row = 2;
        _headRowSecondView.rowViewDelegate = self;
        _headRowSecondView.backgroundColor = [UIColor whiteColor];
        _headRowSecondView.titleLb.text = NSLocalizedString(@"分享时段", nil);
    }
    return _headRowSecondView;
}
//分享时段
- (RowView *)headRowThirdView
{
    if (!_headRowThirdView) {
        _headRowThirdView = [[RowView alloc]init];
        _headRowThirdView.row = 3;
        _headRowThirdView.rowViewDelegate = self;
        _headRowThirdView.backgroundColor = [UIColor whiteColor];
        _headRowThirdView.titleLb.text = NSLocalizedString(@"分享时限", nil);
    }
    return _headRowThirdView;
}

//添加联系人View
- (UIView *)shareFriendsView
{
    if (!_shareFriendsView) {
        _shareFriendsView = [[UIView alloc]init];
        _shareFriendsView.backgroundColor = [UIColor whiteColor];
    }
    return _shareFriendsView;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

- (NSMutableArray *)modifyPermissionArr
{
    if (!_modifyPermissionArr) {
        _modifyPermissionArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _modifyPermissionArr;
}
//手机文本信息
- (UITextField *)phonetf
{
    if (!_phonetf) {
        _phonetf = [[UITextField alloc]init];
        _phonetf.font =FONT(16);
        if (isOverSeas) {
            _phonetf.placeholder = NSLocalizedString(@"输入想分享的人的邮箱", nil);
        }else{
            _phonetf.placeholder = NSLocalizedString(@"输入想分享的人手机号码或邮箱", nil);
        }
        
        _phonetf.keyboardType = UIKeyboardTypeEmailAddress;
        _phonetf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _phonetf;
}

#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"content_not"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"该设备还未分享给任何人", nil);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
