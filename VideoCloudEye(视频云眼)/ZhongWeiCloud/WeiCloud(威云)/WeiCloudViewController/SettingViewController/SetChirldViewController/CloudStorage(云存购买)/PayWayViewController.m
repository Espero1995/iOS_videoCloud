//
//  PayWayViewController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/23.
//  Copyright © 2017年 张策. All rights reserved.
//
#import "PayWayViewController.h"
#import "myPayCell.h"
//支付宝支付
# import <AlipaySDK/AlipaySDK.h>
#import "MyCloudStorageVC.h"
#import "CloudStorageNewVC.h"
#import "WXApi.h"
@interface PayWayViewController ()<
UITableViewDelegate,
UITableViewDataSource,
WXApiDelegate
>
{
    NSString *info;
}
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIButton *payBtn;
@property (nonatomic,assign) NSInteger row;//为了标记前一个点击的cell
@end

@implementation PayWayViewController
//======================system========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"支付方式", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    [self createTableView];
    [self createPayBtn];
    self.row = 0;///使得它的位置先定位到行数+1个位置【确保选中最后一个row能被勾选中】
    
    NSLog(@"传过来的参数1：%@;传过来的参数2：%@；传过来的参数3：%@",_payMealModel.plan_info,_payMealModel.Pid,_payMealModel.discount_fee);
    NSLog(@"传过来的id：%@",self.deviceID);
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jumpToSuccessVC) name:PAYSUCCESSJUMPTOVC object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//======================init========================
#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, iPhoneHeight) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor = BG_COLOR;
    self.tableView.scrollEnabled=NO;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:self.tableView];
}

#pragma mark ------创建支付提交按钮
//创建支付提交按钮
- (void)createPayBtn{
    self.payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.payBtn.frame = CGRectMake(0.1*iPhoneWidth, 150, 0.8*iPhoneWidth, 40);
    [self.payBtn setTitle:NSLocalizedString(@"确认支付", nil) forState:UIControlStateNormal];
    [self.payBtn setTintColor:[UIColor whiteColor]];
    self.payBtn.backgroundColor = MAIN_COLOR;
    self.payBtn.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.payBtn];
    [self.payBtn addTarget:self action:@selector(payClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)payClick{
    NSLog(@"我选择了:【%@】作为支付方式",info);
    if ([info isEqualToString:NSLocalizedString(@"微信支付", nil)]) {
       // NSLog(@"我选择了:%@作为支付方式11111",info);
        if ([WXApi isWXAppInstalled]) {
            [self submitOrderWithPaymentType:[NSNumber numberWithInt:2]];
        }else{
           [XHToast showCenterWithText:NSLocalizedString(@"您尚未安装微信客户端，可选择其它方式支付", nil)];
        }
    }else{
        [self submitOrderWithPaymentType:[NSNumber numberWithInt:1]];
    }
}

//======================delegate========================
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString *str = @"MyPayCell";
    myPayCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[myPayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
//    cell.selectionStyle = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (row == 0) {
        cell.headImg.image = [UIImage imageNamed:@"Alipay"];
        cell.payName.text = NSLocalizedString(@"支付宝", nil);
        cell.selectImg.image = [UIImage imageNamed:@"Selecte"];
        
    }else if(row == 1){
        cell.headImg.image = [UIImage imageNamed:@"WeChat"];
        cell.payName.text = NSLocalizedString(@"微信支付", nil);
        cell.selectImg.image = [UIImage imageNamed:@"Unchecked"];
    }
    
    return cell;
}

#pragma mark ------cell的点击事件
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //勾选
    if(indexPath.row == _row){
        return;
    }
    myPayCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.selectStyle == 0) {
        newCell.selectStyle = 1;
        newCell.selectImg.image = [UIImage imageNamed:@"Selecte"];
    }
    NSIndexPath *oldIndexPath =[NSIndexPath indexPathForRow:_row inSection:0];
    myPayCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.selectStyle == 1 || oldCell.selectStyle == 0) {
        oldCell.selectStyle = 0;
        oldCell.selectImg.image = [UIImage imageNamed:@"Unchecked"];
    }
    _row=indexPath.row;
    info = newCell.payName.text;
}

#pragma mark ----- 设置区头区尾
//区头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

//区头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 40)];
    UILabel *tipLabel= [[UILabel alloc]init];
    tipLabel.text = NSLocalizedString(@"选择支付方式", nil);
    tipLabel.textColor = [UIColor colorWithHexString:@"b2b2b2"];
    tipLabel.font = [UIFont systemFontOfSize:14.0f];
    tipLabel.numberOfLines = 1;
    [backView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView.mas_left).offset(15);
        make.top.equalTo(backView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(255, 20));
    }];
    return backView;
}


//======================method========================

- (void)submitOrderWithPaymentType:(NSNumber *)payment
{
    /*
     POST  v1/cloudplans/buy
     Content-Type: application/x-www-form-urlencoded
     请求参数
     access_token=<令牌> & user_id=<用户ID> & plan_id=<套餐ID> & device_id=<设备ID> &  payment =<支付方式>  payment  : 1 支付宝 2微信
     */
    if ([payment intValue] == 1) {
        NSMutableDictionary * putData = [[NSMutableDictionary alloc]initWithCapacity:0];
        [putData setObject:_payMealModel.Pid forKey:@"plan_id"];
        [putData setObject:self.deviceID forKey:@"device_id"];
        [putData setObject:payment forKey:@"payment"];
        
        [[HDNetworking sharedHDNetworking]GET:@"v1/cloudplans/buy" parameters:putData Iszfb:YES IsToken:YES success:^(id  _Nonnull responseObject) {
            if ([responseObject[@"ret"] intValue] == 0) {
                NSLog(@"【支付宝支付】向服务器发送购买云存请求成功。responseObject：%@",responseObject);
                NSString * payOrder = responseObject[@"body"][@"order_info"];
                
                if (payOrder) {
                    // NSLog(@"payOrder:%@",payOrder);
                    //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
                    NSString *appScheme = @"zfb201712044879";
                    
                    [[AlipaySDK defaultService] payOrder:payOrder fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                        NSLog(@"【支付宝】reslut = %@",resultDic);
                        NSString * memo = resultDic[@"memo"];
                        NSLog(@"【支付宝】===memo:%@", memo);
                        
                        int resultCode = [resultDic[@"resultStatus"] intValue];
                        
                        if (resultCode == 9000) {
//                            [XHToast showCenterWithText:@"支付成功"];
                            [self jumpToSuccessVC];
                        }else{
                            [XHToast showCenterWithText:NSLocalizedString(@"支付失败", nil)];
                        }
                    }];
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"支付出错，请重新尝试", nil)];
                }
                
            }
            
            NSLog(@"responseObject11:%@",responseObject);
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"【支付宝】支付失败");
            //ALI40247
        }];
    }else
    {
        NSMutableDictionary * putData = [[NSMutableDictionary alloc]initWithCapacity:0];
        [putData setObject:_payMealModel.Pid forKey:@"plan_id"];
        [putData setObject:self.deviceID forKey:@"device_id"];
        [putData setObject:payment forKey:@"payment"];
        
        [[HDNetworking sharedHDNetworking]GET:@"v1/cloudplans/buy" parameters:putData Iszfb:YES IsToken:YES success:^(id  _Nonnull responseObject) {
            if ([responseObject[@"ret"] intValue] == 0) {
                NSLog(@"【微信支付】向服务器发送购买云存请求成功。responseObject：%@",responseObject);
                NSString * payOrder = responseObject[@"body"][@"order_info"];
                
                if (payOrder) {
                    NSString * appid = responseObject[@"body"][@"order_info"][@"appid"];
                    NSString * partnerid = responseObject[@"body"][@"order_info"][@"mch_id"];
                    NSString * prepayid = responseObject[@"body"][@"order_info"][@"prepay_id"];
                    NSString * package = @"Sign=WXPay";
                    NSString * noncestr = responseObject[@"body"][@"order_info"][@"nonce_str"];
//                    NSString * timestamp = [unitl getNowTimeTimestamp];
                    NSString * timestamp = responseObject[@"body"][@"order_info"][@"timestamp"];
//                    NSLog(@"生成的时间戳：%@",timestamp);
                    NSString * sign = responseObject[@"body"][@"order_info"][@"sign"];
                    // NSLog(@"payOrder:%@",payOrder);
                    //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
                    //需要创建这个支付对象
                    PayReq *req = [[PayReq alloc] init];
                    
                    req.openID = appid; //由用户微信号和AppID组成的唯一标识，用于校验微信用户
                    
                    req.partnerId = partnerid;// 商家id，在注册的时候给的
                    
                    req.prepayId  = prepayid;// 预支付订单这个是后台跟微信服务器交互后，微信服务器传给你们服务器的，你们服务器再传给你
                    
                    req.package  = package;// 根据财付通文档填写的数据和签名
                    
                    req.nonceStr  = noncestr;// 随机编码，为了防止重复的，在后台生成
                    
                    NSString * stamp = timestamp;// 这个是时间戳，也是在后台生成的，为了验证支付的
                    req.timeStamp = stamp.intValue;
                    
                    req.sign = sign;// 这个签名也是后台做的
                    
                    //发送请求到微信，等待微信返回onResp
                    [WXApi sendReq:req];
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"支付出错，请重新尝试", nil)];
                }
//                [self jumpToSuccessVC];
            }
            
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"【微信】支付失败:%@",error);
            //ALI40247
        }];
    }
}

#pragma mark - 支付成功后跳转
- (void)jumpToSuccessVC
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"支付成功", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.isMyVCJumpTo) {//这里是my界面过来
            CloudStorageNewVC * cloudVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];;
            [self.navigationController popToViewController:cloudVC animated:NO];
        }else{
            MyCloudStorageVC* MyCloudVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
            MyCloudVC.isRefresh = YES;
            [self.navigationController popToViewController:MyCloudVC animated:NO];
        }
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

@end
