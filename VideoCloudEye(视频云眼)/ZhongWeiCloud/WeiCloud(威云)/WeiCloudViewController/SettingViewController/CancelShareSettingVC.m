//
//  CancelShareSettingVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "CancelShareSettingVC.h"
#import "OtherShareCell_t.h"
#import "ZCTabBarController.h"
@interface CancelShareSettingVC ()
//图片
@property (nonatomic,strong) UIImageView *headImage;
//名称
@property (nonatomic,strong) UILabel *nameLb;
//消息
@property (nonatomic,strong) UILabel *messageLb;
//取消分享按钮
@property (nonatomic, strong) UIButton *cancelShareBtn;

@property (nonatomic,strong) UIView *deviceShareView;
@end

@implementation CancelShareSettingVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    [self cteateNavBtn];
    self.title = NSLocalizedString(@"设置", nil);
    self.view.backgroundColor = BG_COLOR;
    [self setUpUI];
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

//==========================init==========================
- (void)setUpUI
{
    [self.view addSubview:self.deviceShareView];
    [self.deviceShareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(15);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 90));
    }];
    
    //图片
    [self.deviceShareView addSubview:self.headImage];
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.deviceShareView.mas_left).offset(15);
        make.centerY.equalTo(self.deviceShareView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(110, 75));
    }];
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.cornerRadius = 5.f;
    
    //名称
    [self.deviceShareView addSubview:self.nameLb];
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(15);
        make.top.equalTo(self.headImage.mas_top).offset(5);
        make.right.equalTo(self.deviceShareView.mas_right).offset(-20);
    }];
    
    //消息
    [self.deviceShareView addSubview:self.messageLb];
    [self.messageLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(15);
        make.right.equalTo(self.deviceShareView.mas_right).offset(-20);
        make.bottom.equalTo(self.headImage.mas_bottom).offset(-5);
    }];
    //取消分享按钮
    [self.deviceShareView addSubview:self.cancelShareBtn];
    [self.cancelShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.deviceShareView.mas_centerY);
        make.right.mas_equalTo(self.deviceShareView.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    //赋值
    self.nameLb.text = self.dev_mList.name;
    self.messageLb.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"来自", nil),self.dev_mList.owner_name];
    self.headImage.image = self.currentVideo_CutImage;
}

//==========================method==========================
- (void)cancelShareBtnClick
{
    NSArray *arr=[[NSArray alloc]initWithObjects:NSLocalizedString(@"取消分享", nil), nil];
    [ChooseDialog createWithSystemStyle:self.navigationController Title:nil Message:nil Array:arr CallBack:^(NSInteger index) {
        if (index==0) {
            [self deleteOtherSharedDev:self.dev_mList];
        }
        
    }];
}
#pragma mark - 删除分享设备
- (void)deleteOtherSharedDev:(dev_list *)model
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"取消分享，请稍候...", nil)];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:[unitl get_User_id] forKey:@"user_id"];
    [dic setObject:model.ID forKey:@"dev_id"];
    
    [[HDNetworking sharedHDNetworking] POST:@"v1/device/share/cancelFromOthers" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"respinseObject:%@",responseObject);
        
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                //发送刷新设备列表的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }else{
            [Toast dissmiss];
            [XHToast showCenterWithText:NSLocalizedString(@"取消分享失败，请稍候再试", nil)];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        [XHToast showCenterWithText:NSLocalizedString(@"取消分享失败，请检查您的网络", nil)];
    }];

}


#pragma mark - getter && setter
- (UIView *)deviceShareView
{
    if (!_deviceShareView) {
        _deviceShareView = [[UIView alloc]initWithFrame:CGRectZero];
        _deviceShareView.backgroundColor = RGB(255, 255, 255);
    }
    return _deviceShareView;
}
//图片
- (UIImageView *)headImage
{
    if (!_headImage) {
        _headImage = [[UIImageView alloc]init];
    }
    return _headImage;
}
//名称
- (UILabel *)nameLb
{
    if (!_nameLb) {
        _nameLb = [[UILabel alloc]init];
        _nameLb.font = FONT(16);
        _nameLb.textColor = RGB(0, 0, 0);
    }
    return _nameLb;
}
//介绍
- (UILabel *)messageLb
{
    if (!_messageLb) {
        _messageLb = [[UILabel alloc]init];
        _messageLb.font = FONT(13);
        _messageLb.textColor = RGB(150, 150, 150);
    }
    return _messageLb;
}
//按钮
- (UIButton *)cancelShareBtn
{
    if (!_cancelShareBtn) {
        _cancelShareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelShareBtn setImage:[UIImage imageNamed:@"cancelLink"] forState:UIControlStateNormal];
        [_cancelShareBtn addTarget:self action:@selector(cancelShareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelShareBtn;
}


@end
