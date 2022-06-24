//
//  DeviceNameController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/3/1.
//  Copyright © 2017年 张策. All rights reserved.
//
#define kMaxLength 16
#import "DeviceNameController.h"
#import "DeviceNameCell_t.h"
#import "GeneralDeviceSettingVC.h"
#import "SpecialDeviceSettingVC.h"
@interface DeviceNameController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate,
    DeviceNameCell_tDelegete
>
{
    /*修改的设备名*/
    NSMutableString * changedName;
    UIButton * _editButton;
    BOOL isOpenKeyBoard;//是否开启过键盘
}

@property (nonatomic,strong) UITableView * tableView;

@end

@implementation DeviceNameController
//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"修改名称", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = BG_COLOR;
    [self createData];
    [self createTableView];
    [self setButtonitem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//=========================init=========================
#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 22.5)];
    headView.backgroundColor = BG_COLOR;

    self.tableView.tableHeaderView = headView;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    
    [self.view addSubview:self.tableView];
}


//=========================method=========================
#pragma mark ------生成数据源
//数据源
- (void)createData{
    changedName = [NSMutableString string];
}

#pragma mark ------设置导航栏按钮和响应事件
- (void)setButtonitem{
    UIButton * backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 40, 15)];
    [backButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.highlighted = YES;
    backButton.userInteractionEnabled = YES;
    [backButton addTarget:self action:@selector(cancelName) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIBarButtonItem * leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    self.navigationItem.leftBarButtonItems = @[leftSpace,leftItem];
    
    _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_editButton setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(reserveName) forControlEvents:UIControlEventTouchUpInside];
    _editButton.highlighted = YES;
    _editButton.userInteractionEnabled = YES;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editButton];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -10;
    self.navigationItem.rightBarButtonItems = @[rightItem,rightSpace];
    
}

//取消返回
- (void)cancelName{
    if (self.listModel.device_class == 1) {
        GeneralDeviceSettingVC* setVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        [self.navigationController popToViewController:setVC animated:YES];
    }else{
        SpecialDeviceSettingVC* setVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        [self.navigationController popToViewController:setVC animated:true];
    }
}

//更改设备名
- (void)reserveName{
    NSString *limitNameLenthStr;
    if(isOpenKeyBoard == NO){
        limitNameLenthStr = self.deviceName;
    }else{
        if (changedName.length > kMaxLength) {
            limitNameLenthStr= [changedName substringToIndex:kMaxLength];
        }else{
            limitNameLenthStr= changedName;
        }
    }
    
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    NSLog(@"limitNameLenthStr:%@",limitNameLenthStr);
    if (![NSString isNull:limitNameLenthStr]) {
        [changeDic setObject:limitNameLenthStr forKey:@"name"];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"设备名不能为空", nil)];
        return;
    }
    

    [[HDNetworking sharedHDNetworking]POST:@"v1/device/changename" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            
            if (self.listModel.device_class == 1) {
                GeneralDeviceSettingVC* setVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
//                setVC.nameString = [NSMutableString stringWithString:limitNameLenthStr];
                //发送修改后的名字的通知
                NSDictionary * dic = @{@"deviceName":limitNameLenthStr,@"selectedIndex":self.currentIndex};
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshCell" object:nil userInfo:dic];
                
                
                //修改本地的model
                NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
                tempAllGroupArr = [unitl getAllGroupCameraModel];
                NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
                devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
                
                for (int i = 0; i < devListArr.count; i++) {
                    if ([((dev_list *)devListArr[i]).ID isEqualToString:self.listModel.ID]) {
                        dev_list * appointDevModel = devListArr[i];
                        appointDevModel.name = limitNameLenthStr;
                    }
                }
                [unitl saveAllGroupCameraModel:tempAllGroupArr];

                [self.navigationController popToViewController:setVC animated:YES];
            }else{
                SpecialDeviceSettingVC* setVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
                
                //修改本地的model
                NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
                tempAllGroupArr = [unitl getAllGroupCameraModel];
                NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
                devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
                
                for (int i = 0; i < devListArr.count; i++) {
                    if ([((dev_list *)devListArr[i]).ID isEqualToString:self.listModel.ID]) {
                        dev_list * appointDevModel = devListArr[i];
                        appointDevModel.name = limitNameLenthStr;
                    }
                }
                [unitl saveAllGroupCameraModel:tempAllGroupArr];
                
//                setVC.nameString = [NSMutableString stringWithString:limitNameLenthStr];
                
                //发送修改后的名字的通知
                NSDictionary * dic = @{@"deviceName":limitNameLenthStr,@"selectedIndex":self.currentIndex};
                NSLog(@"更新设备名字的dic：%@",dic);
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshCell" object:nil userInfo:dic];
                
                [self.navigationController popToViewController:setVC animated:YES];
            }

            
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"修改设备名称失败，请稍候再试", nil)];
        }
        
    } failure:^(NSError * _Nonnull error) {
         [XHToast showCenterWithText:NSLocalizedString(@"修改设备名称失败，请检查您的网络", nil)];
    }];
}



//=========================delegate=========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
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
    cell.nameText.placeholder = NSLocalizedString(@"请输入设备名称", nil);

    //获取本地的model
    NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
    tempAllGroupArr = [unitl getAllGroupCameraModel];
    NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
    devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
    
    for (int i = 0; i < devListArr.count; i++) {
        if ([((dev_list *)devListArr[i]).ID isEqualToString:self.listModel.ID]) {
            dev_list * appointDevModel = devListArr[i];
            cell.nameText.text = appointDevModel.name;
        }
    }
    
//    cell.nameText.text = self.deviceName;
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
    tipLb.text = NSLocalizedString(@"设备仅支持中文、数字、字母和符号。(16字以内)", nil);//请输入10字以内的设备名称
    tipLb.font = FONT(12);
    tipLb.textColor = RGB(190, 190, 190);
    tipLb.numberOfLines = 0;
    [headView addSubview:tipLb];
    [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView.mas_left).offset(15);
        make.centerY.equalTo(headView.mas_centerY);
        make.right.equalTo(headView.mas_right).offset(0);
    }];
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}


- (void)DeviceNameCell_tChooseBtnClick:(DeviceNameCell_t *)cell{
    cell.nameText.text = @"";
    isOpenKeyBoard = YES;
    NSLog(@"清空设备名");
}

- (void)textFieldEditChanged:(UITextField *)textField
{
    
    isOpenKeyBoard = YES;
    changedName = [NSMutableString stringWithString:textField.text];
//    NSString *toBeString = textField.text;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage; //ios7之前使用[UITextInputMode currentInputMode].primaryLanguage
    if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (changedName.length > kMaxLength) {
                textField.text = [changedName substringToIndex:kMaxLength];
            }
        }
        else{//有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (changedName.length > kMaxLength) {
            textField.text = [changedName substringToIndex:kMaxLength];
        }
    }
    
}

//textField已经结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField{
    changedName = [NSMutableString stringWithString:textField.text];
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    //默认YES 可以清空textField里的内容
    return YES;
}




//=========================lazy loading=========================
#pragma mark ----- 懒加载部分

@end
