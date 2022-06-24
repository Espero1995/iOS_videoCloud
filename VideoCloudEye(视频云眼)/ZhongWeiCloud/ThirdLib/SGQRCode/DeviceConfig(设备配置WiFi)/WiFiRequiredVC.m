//
//  WiFiRequiredVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "WiFiRequiredVC.h"
@interface WiFiRequiredVC ()

@end

@implementation WiFiRequiredVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setUI
- (void)setUpUI
{
    self.navigationItem.title = NSLocalizedString(@"Wi-Fi连接", nil);
    [self cteateNavBtn];
}

-(void)returnVC
{
    [self.navigationController popViewControllerFromBottom];
}

@end
