//
//  ModifyUserNameVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/23.
//  Copyright © 2018年 张策. All rights reserved.
//
#define kMaxLength 16
#import "ModifyUserNameVC.h"
#import "ZCTabBarController.h"
#import "DeviceNameCell_t.h"
@interface ModifyUserNameVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate,
    DeviceNameCell_tDelegete
>
@property (nonatomic,strong) UITableView *tv_list;//表视图
@end

@implementation ModifyUserNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"修改用户名", nil);
    self.view.backgroundColor = BG_COLOR;
    [self setButtonitem];
    [self.view addSubview:self.tv_list];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
}

//==========================init==========================
#pragma mark ------设置导航栏按钮和响应事件
- (void)setButtonitem{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 40, 15)];
    [backBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.highlighted = YES;
    backBtn.userInteractionEnabled = YES;
    [backBtn addTarget:self action:@selector(cancelModifyClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    self.navigationItem.leftBarButtonItems = @[leftSpace,leftItem];
    UIButton *completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [completeBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    completeBtn.highlighted = YES;
    completeBtn.userInteractionEnabled = YES;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:completeBtn];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -10;
    self.navigationItem.rightBarButtonItems = @[rightItem,rightSpace];
}


//=========================method=========================
//取消返回
- (void)cancelModifyClick{
    [self.navigationController popViewControllerAnimated:YES];
}
//确定按钮
- (void)completeClick
{
    if (self.userNameStr.length == 0) {
        [XHToast showCenterWithText:NSLocalizedString(@"用户名不得为空", nil)];
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.userNameStr forKey:@"user_name"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/profile" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self.tv_list reloadData];
            //修改用户名
            NSDictionary * dic = @{@"userName":self.userNameStr};
            [[NSNotificationCenter defaultCenter]postNotificationName:@"modifyUserName" object:nil userInfo:dic];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}



//=========================delegate=========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"MyCell";
    DeviceNameCell_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[DeviceNameCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameText.placeholder = NSLocalizedString(@"请输入用户名", nil);
    if (self.userNameStr.length>16) {
        cell.nameText.text = [self.userNameStr substringToIndex:kMaxLength];//限制16位
    }else{
        cell.nameText.text = self.userNameStr;
    }
    
    [cell.nameText addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    cell.nameText.delegate = self;
    cell.delegete = self;
    return cell;
}


//头部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[UIView alloc]init];
    footView.backgroundColor = [UIColor clearColor];
    UILabel *tipLb = [[UILabel alloc]init];
    tipLb.text = NSLocalizedString(@"用户名仅支持中文、数字、字母和符号（16字以内）", nil);//请输入16字以内的设备名称
    tipLb.font = FONT(12);
    tipLb.textColor = RGB(190, 190, 190);
    tipLb.numberOfLines = 0;
    [footView addSubview:tipLb];
    [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footView.mas_left).offset(15);
        make.right.equalTo(footView.mas_right).offset(5);
        make.centerY.equalTo(footView.mas_centerY);
    }];
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}


- (void)DeviceNameCell_tChooseBtnClick:(DeviceNameCell_t *)cell{
    cell.nameText.text = @"";
    self.userNameStr = @"";
    NSLog(@"清空用户名");
}

- (void)textFieldEditChanged:(UITextField *)textField
{
    self.userNameStr = [NSString stringWithString:textField.text];
    if (self.userNameStr.length > kMaxLength) {
        textField.text = [self.userNameStr substringToIndex:kMaxLength];
    }
    self.userNameStr = textField.text;
}

//textField已经结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.userNameStr = textField.text;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    //默认YES 可以清空textField里的内容
    return YES;
}

#pragma mark - getter && setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) style:UITableViewStylePlain];
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 20)];
        headView.backgroundColor = BG_COLOR;
        _tv_list.tableHeaderView = headView;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tv_list.scrollEnabled = NO;
    }
    return _tv_list;
}

@end
