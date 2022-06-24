//
//  InputSerialNumVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/11.
//  Copyright © 2018年 张策. All rights reserved.
//
//文本尺寸
#define ACCOUNTWIDTH 0.9*iPhoneWidth
#define MAXLENGTH 15
#import "InputSerialNumVC.h"
#import "ZCTabBarController.h"
#import "ConfigTypeVC.h"//配置类型选择界面
#import "ConfigSuccessVC.h"//配置成功界面
#import "DeviceConfigModel.h"//设备model
#import "ConfigOccupiedVC.h"//设备被他人已占用界面
@interface InputSerialNumVC ()
<
    UITextFieldDelegate
>
/*序列号View*/
@property (nonatomic,strong) UIView *serialNumView;
/*序列号文本框*/
@property (nonatomic,strong) UITextField *serialNum_tf;
/*完成按钮*/
@property (nonatomic,strong) UIButton *completeBtn;
@end

@implementation InputSerialNumVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"输入设备序列号", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    [self setUpUI];
    [self setNavBtnItem];
    [self.serialNum_tf becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
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
//==========================init==========================
#pragma mark ----- 页面初始化 -----
- (void)setUpUI
{
    [self.view addSubview:self.serialNumView];
    [self.serialNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    //添加文本框
    [self.serialNumView addSubview:self.serialNum_tf];
    [self.serialNum_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.serialNumView.mas_centerY);
        make.left.equalTo(self.serialNumView.mas_left).offset(10);
        make.right.equalTo(self.serialNumView.mas_right);
    }];
}

#pragma mark ------编辑按钮和相应事件
//完成按钮
- (void)setNavBtnItem{
    //编辑按钮
    self.completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
    [self.completeBtn setTitle:NSLocalizedString(@"完成了", nil) forState:UIControlStateNormal];
    self.completeBtn.titleLabel.font = FONT(17);
    [self.completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.completeBtn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    self.completeBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.completeBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self cteateNavBtn];
}

#pragma mark - 完成按钮
- (void)completeClick
{
    if (self.serialNum_tf.text.length == 0) {
        [XHToast showCenterWithText:NSLocalizedString(@"序列号不能为空", nil)];
        return;
    }
    if (self.serialNum_tf.text.length != 15) {
        [XHToast showCenterWithText:NSLocalizedString(@"请输入正确的序列号", nil)];
        return;
    }

    [self.serialNum_tf resignFirstResponder];
    if (isMainAccount) {
        [self getDevMsg];
    }else{
        [self filterNotOwnerDevice];
    }
    
}


#pragma mark - 过滤并不是属于自己的设备
- (void)filterNotOwnerDevice
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.serialNum_tf.text forKey:@"deviceId"];
    [[HDNetworking sharedHDNetworking]GET:@"open/deviceTree/canOperate" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"过滤是不是属于自己的设备:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            BOOL isDirectory = [responseObject[@"body"] boolValue];
            if (isDirectory) {
                //跳转到设备配网页面
                [self getDevMsg];
            }else{
                [XHToast showCenterWithText:@"该设备不在您当前文件夹下，无法进行配置"];
            }
        }else{
            [XHToast showCenterWithText:@"设备配置失败，请稍候再试"];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [XHToast showCenterWithText:@"设备配置失败，请检查您的网络"];
    }];
}



#pragma mark - 获取设备归属
- (void)getDevMsg
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.serialNum_tf.text forKey:@"dev_id"];
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/getowner" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"后台返回，获取设备归属信息:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        
        DeviceConfigModel *model = [[DeviceConfigModel alloc]init];
        model.deviceId = self.serialNum_tf.text;
        
        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            NSString * ower_id = bodyDic[@"owner_id"];
            NSString *enableWifi = bodyDic[@"wifi_enable"];//是否是通过wifi来配置的
            
            model.deviceType = bodyDic[@"dev_type"];
            model.enableWifi = [enableWifi intValue];
            NSLog(@"ower_id:%@===%lu",ower_id,(unsigned long)[ower_id length]);
            //图片
            NSString *tempImgUrl = [NSString stringWithFormat:@"%@1.png",[bodyDic objectForKey:@"dev_img"]];
            
            model.devImgURL = tempImgUrl;
            
            if (isMainAccount) {
                
                if ((NSNull *)ower_id == [NSNull null]){
                    //查看设备状态(是否在线)
                    [self getDevStatus:model];
                }else{
                    //已经归属别人，跳转到归属别人的界面
                    ConfigOccupiedVC *occupiedVC = [[ConfigOccupiedVC alloc]init];
                    occupiedVC.configModel = model;
                    if (isMainAccount) {
                        occupiedVC.title = @"添加设备";
                    }else{
                        occupiedVC.title = @"配置设备";
                    }
                    [self.navigationController pushViewController:occupiedVC animated:YES];
                }
                
            }else{
                
                //查看设备状态(是否在线)
                [self getDevStatus:model];
                
            }
            
            
            
        }else{//ret == -1
            [XHToast showCenterWithText:@"无效的设备序列号"];
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:@"请检查您的网络"];
    }];
    
}


#pragma mark - 查看设备状态(是否在线)
- (void)getDevStatus:(DeviceConfigModel *)configModel
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:configModel.deviceId forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getstatus" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        //        NSLog(@"获取设备在线状态responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            BOOL isLine = [bodyDic[@"status"] boolValue];
            NSLog(@"查询设备是否在线：%@",isLine?@"在线":@"不在线");
            if (!isLine) {
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^(void){
                    [Toast dissmiss];
                    //跳转到配置界面
                    ConfigTypeVC *configVC = [[ConfigTypeVC alloc]init];
                    configVC.configModel = configModel;
                    [self.navigationController pushViewController:configVC animated:YES];
                });
                
            }else{
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^(void){
                    [Toast dissmiss];
                    
                    if (isMainAccount) {
                        //跳转到添加界面
                        ConfigSuccessVC *configVC = [[ConfigSuccessVC alloc]init];
                        configVC.configModel = configModel;
                        configVC.title = @"添加设备";
                        [self.navigationController pushViewController:configVC animated:YES];
                    }else{
                        [XHToast showCenterWithText:@"设备已在您当前目录下"];
                    }
                    
                });
                
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        [XHToast showCenterWithText:@"请检查您的网络"];
    }];
}

//==========================delegate==========================

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.serialNum_tf) {
        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        //so easy
        else if (self.serialNum_tf.text.length >= MAXLENGTH) {
            self.serialNum_tf.text = [textField.text substringToIndex:MAXLENGTH];
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

//==========================lazy loading==========================
#pragma mark ----- getter&setter
//序列号View
-(UIView *)serialNumView{
    if (!_serialNumView) {
        _serialNumView = [[UIView alloc] init];
        _serialNumView.backgroundColor = [UIColor whiteColor];
        _serialNumView.layer.cornerRadius = 7.0f;
        _serialNumView.layer.borderWidth = 1.0f;
        _serialNumView.layer.borderColor = RGB(231, 231, 231).CGColor;
    }
    return _serialNumView;
}
//序列号文本框
-(UITextField *)serialNum_tf
{
    if (!_serialNum_tf) {
        _serialNum_tf = [[UITextField alloc]init];
        _serialNum_tf.font =FONT(17);
        _serialNum_tf.placeholder = NSLocalizedString(@"请输入设备的15位序列号", nil);
        _serialNum_tf.keyboardType = UIKeyboardTypeNumberPad;
        _serialNum_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        _serialNum_tf.delegate = self;
    }
    return _serialNum_tf;
}




@end
