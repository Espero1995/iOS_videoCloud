//
//  ModifyGroupNameVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//
#define kMaxLength 10
#import "ModifyGroupNameVC.h"
//#import "ZCTabBarController.h"
#import "DeviceNameCell_t.h"
@interface ModifyGroupNameVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate,
    DeviceNameCell_tDelegete
>
@property (nonatomic,strong) UITableView *tv_list;//表视图
@end

@implementation ModifyGroupNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"分组名称", nil);
    self.view.backgroundColor = BG_COLOR;
    [self setButtonitem];
    [self.view addSubview:self.tv_list];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

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
    if (self.groupNameStr.length == 0) {
        [XHToast showCenterWithText:NSLocalizedString(@"组名不得为空", nil)];
        return;
    }
    if ([self isInputRuleAndBlank:self.groupNameStr]) {
        [Toast showLoading:self.view Tips:NSLocalizedString(@"修改中...", nil)];
        /**
         * description: GET v1/devicegroup/updateGroupName（更新设备分组的名称）
         * access_token=<令牌> & user_id =<用户ID>& group_id=< group_id 组id>& group_name=< group_name 组名>
         */
        NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [postDic setObject:self.groupID forKey:@"group_id"];
        [postDic setObject:self.groupNameStr forKey:@"group_name"];
        [[HDNetworking sharedHDNetworking] POST:@"v1/devicegroup/updateGroupName" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0) {
                [self UpDateGroupInfo];
                [[NSNotificationCenter defaultCenter]postNotificationName:GroupCreateOrDeleteSuccess_updateUI object:nil];
            }else if (ret == 1601){
                [XHToast showCenterWithText:NSLocalizedString(@"该分组名称已被占用", nil)];
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"修改分组名称失败，请稍候再试", nil)];
            }
            NSLog(@"修改名字的结果：%@",responseObject);
        } failure:^(NSError * _Nonnull error) {
            [XHToast showCenterWithText:NSLocalizedString(@"修改分组名称失败，请检查您的网络", nil)];
        }];
        
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"组名只支持字母、数字和中文", nil)];
    }
}

#pragma mark ==== 删除或添加设备之后更新设备列表。
- (void)UpDateGroupInfo
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
            WeiCloudListModel *listModel = [WeiCloudListModel mj_objectWithKeyValues:responseObject[@"body"]];
            
            NSInteger groupCount = listModel.deviceGroup.count;
            //保存组别中的组名和ID
            NSMutableArray * tempGroupArr = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < groupCount; i++) {
                NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
                [tempDic setObject:listModel.deviceGroup[i].groupName forKey:@"groupName"];
                [tempDic setObject:listModel.deviceGroup[i].groupId forKey:@"groupID"];
                [tempGroupArr addObject:tempDic];
            }
            NSString * GroupNameAndIDArr_KeyStr = [unitl getKeyWithSuffix:[unitl get_User_id] Key:GroupNameAndIDArr_key];
            [unitl saveDataWithKey:GroupNameAndIDArr_KeyStr Data:tempGroupArr];
            [unitl saveAllGroupCameraModel:[NSMutableArray arrayWithArray:listModel.deviceGroup]];
            
            [unitl saveCurrentDisplayGroupIndex:0];
            
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"查询分组 网络正在开小差...");
    }];
}


//只支持字母数字和中文
- (BOOL)isInputRuleAndBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
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
    cell.nameText.placeholder = NSLocalizedString(@"请输入设备组名", nil);
    if (self.groupNameStr.length>10) {
        cell.nameText.text = [self.groupNameStr substringToIndex:kMaxLength];//限制10位
    }else{
        cell.nameText.text = self.groupNameStr;
    }
    
    [cell.nameText addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    cell.nameText.delegate = self;
    cell.delegete = self;
    return cell;
}


//头部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = [UIColor clearColor];
    UILabel *tipLb = [[UILabel alloc]init];
    tipLb.text = NSLocalizedString(@"组名只支持字母、数字和中文（10字以内）", nil);
    tipLb.font = FONT(12);
    tipLb.numberOfLines = 0;
    tipLb.textColor = RGB(190, 190, 190);
    [headView addSubview:tipLb];
    [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView.mas_left).offset(15);
        make.right.equalTo(headView.mas_right).offset(0);
        make.centerY.equalTo(headView.mas_centerY);
    }];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}


- (void)DeviceNameCell_tChooseBtnClick:(DeviceNameCell_t *)cell{
    cell.nameText.text = @"";
    self.groupNameStr = @"";
}

- (void)textFieldEditChanged:(UITextField *)textField
{
    self.groupNameStr = [NSString stringWithString:textField.text];
    if (self.groupNameStr.length > kMaxLength) {
        textField.text = [self.groupNameStr substringToIndex:kMaxLength];
    }
    self.groupNameStr = textField.text;
}

//textField已经结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.groupNameStr = textField.text;
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
