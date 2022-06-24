//
//  ConfigSuccessVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/19.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "ConfigSuccessVC.h"
#import "ZCTabBarController.h"
@interface ConfigSuccessVC ()
/**
 * @brief 提交按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
/**
 * @brief 摄像头图片
 */
@property (strong, nonatomic) IBOutlet UIImageView *cameraImg;
/**
 * @brief 摄像头机型
 */
@property (strong, nonatomic) IBOutlet UILabel *cameraLb;

/**
 * @brief 顶部图片
 */
@property (strong, nonatomic) IBOutlet UIImageView *headImg;

@end

@implementation ConfigSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
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

#pragma mark - setUI
- (void)setUpUI
{
    [self createNavEmptyBtn];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.submitBtn.layer.cornerRadius = 22.5f;
    [self.cameraImg sd_setImageWithURL:[NSURL URLWithString:self.configModel.devImgURL] placeholderImage:[UIImage imageNamed:@"CloudPic"]];
    self.cameraLb.text = self.configModel.deviceType;
    self.headImg.image = [UIImage imageNamed:NSLocalizedString(@"config_success", nil)];
}

#pragma mark - 返回点击事件
- (void)returnVC
{
    //无需触发事件，此处就是为空方法
}

#pragma mark - 提交点击事件
- (IBAction)submitClick:(id)sender
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.configModel.deviceId forKey:@"dev_id"];
    if (self.configModel.checkCode) {
        [dic setObject:self.configModel.checkCode forKey:@"check_code"];
    }else{
        [dic setObject:@"" forKey:@"check_code"];
    }
    
    if (isNodeTreeMode) {
        [dic setObject:@"" forKey:@"group_id"];
    }else{
        NSString *groupID = ((deviceGroup *)[unitl getCameraGroupModelIndex:[unitl getCurrentDisplayGroupIndex]]).groupId;
        [dic setObject:groupID forKey:@"group_id"];
    }
    
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/add" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            //添加成功
            //发送删除设备的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            //添加失败
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        //添加失败
        [XHToast showCenterWithText:NSLocalizedString(@"添加失败，请检查您的网络", nil)];
    }];
}





@end
