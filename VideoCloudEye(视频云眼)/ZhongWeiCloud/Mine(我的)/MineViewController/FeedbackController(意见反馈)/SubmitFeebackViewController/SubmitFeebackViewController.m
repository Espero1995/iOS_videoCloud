//
//  SubmitFeebackViewController.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/9.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SubmitFeebackViewController.h"
#import "HClTextView.h"
#import "ZCTabBarController.h"

@interface SubmitFeebackViewController ()
{
    UIApplication *app;
}
@property (weak, nonatomic) HClTextView *textView;
@property (nonatomic,copy)NSString *postTextStr;
/*客服电话提醒*/
@property (nonatomic,strong)UILabel *ServerLb;
/*客服电话*/
@property (nonatomic,strong)UIButton *ServerBtn;
@end

@implementation SubmitFeebackViewController

//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    app = [UIApplication sharedApplication];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = NSLocalizedString(@"意见反馈", nil);
    [self cteateNavBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"发送", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneFunc)];
    HClTextView *textView = [[NSBundle mainBundle] loadNibNamed:@"HClTextView" owner:self options:nil].lastObject;
    [self.view addSubview:textView];
    self.textView = textView;
    textView.delegate = self;
    textView.clearButtonType = ClearButtonAppearWhenEditing;
    [textView setPlaceholder:NSLocalizedString(@"客官！给点意见吧~", nil) contentText:nil maxTextCount:200];
    __weak typeof(self) weakSelf = self;
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
        make.height.equalTo(@(250));
        make.top.equalTo(weakSelf.view.mas_top).with.offset(0);
    }];
    
    //客服电话提醒布局
    [self.view addSubview:self.ServerLb];
    [self.ServerLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(0);
        make.centerX.equalTo(self.textView.mas_centerX).offset(-60);
    }];
    
    //客服电话布局
    [self.view addSubview:self.ServerBtn];
    [self.ServerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.ServerLb.mas_centerY);
        make.left.equalTo(self.ServerLb.mas_right).offset(5);
    }];
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

//==========================method==========================
- (void)textViewDidChange:(UITextView *)textView
{
    self.postTextStr = textView.text;
}

- (void)doneFunc
{
    if (self.postTextStr.length>200) {
        [XHToast showCenterWithText:NSLocalizedString(@"超出限制字数啦~", nil)];
        return;
    }else if (self.postTextStr.length == 0){
        [XHToast showCenterWithText:NSLocalizedString(@"您没有写上您的问题哦~\n如果有什么问题，反馈给我们吧~", nil)];
    }else{
        NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
        [postDic setObject:self.postTextStr forKey:@"feedback"];
        [[HDNetworking sharedHDNetworking]POST:@"v1/user/feedback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            [XHToast showCenterWithText:NSLocalizedString(@"反馈成功", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError * _Nonnull error) {
            [XHToast showCenterWithText:NSLocalizedString(@"反馈失败，请检查您的网络", nil)];
        }];
    }
}

- (void)callServicePhone{
     [app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",@"4008265826"]] options:@{} completionHandler:nil];
}

//==========================lazy loading==========================
#pragma mark ----- 懒加载
-(UILabel *)ServerLb{
    if (!_ServerLb) {
        _ServerLb = [[UILabel alloc]init];
        _ServerLb = [FactoryUI createLabelWithFrame:CGRectZero text:NSLocalizedString(@"客服电话:", nil) font:FONT(16)];
        _ServerLb.textColor = [UIColor lightGrayColor];
    }
    return _ServerLb;
}

-(UIButton *)ServerBtn{
    if (!_ServerBtn) {
        _ServerBtn = [[UIButton alloc]init];
        [_ServerBtn setTitle:@"400-826-5826" forState:UIControlStateNormal];
        [_ServerBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_ServerBtn addTarget:self action:@selector(callServicePhone) forControlEvents:UIControlEventTouchUpInside];

        _ServerBtn.titleLabel.font = FONT(16);
    }
    return _ServerBtn;
}

@end
