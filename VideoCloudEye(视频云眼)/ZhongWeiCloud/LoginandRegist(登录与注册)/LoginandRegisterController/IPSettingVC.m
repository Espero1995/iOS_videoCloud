//
//  IPSettingVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/4/28.
//  Copyright © 2019 苏旋律. All rights reserved.
//
//图片尺寸
#define LOGOWIDTH    iPhoneWidth / 4
#define LeftSpacing  0.075 * iPhoneWidth
#define TopSpacing   iPhoneWidth / 5.5
#define TopSpacingX  iPhoneWidth / 4.5
//文本尺寸
#define ACCOUNTWIDTH 0.85 * iPhoneWidth
#import "IPSettingVC.h"
//下拉菜单栏
#import "YCXMenu.h"
#import "YCXMenuItem.h"

@interface IPSettingVC ()
{
    NSString *httpStr;
}
@property (nonatomic, strong) UIButton *backBtn;//返回按钮
@property (nonatomic, strong) UILabel *ipTipLb;//IP配置提示语
@property (nonatomic, strong) UIButton *httpSelectBtn;//http/https选择按钮
@property (nonatomic, strong) UIView *ipView;//IP配置View
@property (nonatomic, strong) UITextField *ip_tf;//IP文本框
@property (nonatomic, strong) UIButton *submitBtn;//完成按钮
@property (nonatomic, strong) NSArray *menuArray;//http/https组成的数组
@end

@implementation IPSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //IP本地存储
    NSUserDefaults *ipDefault = [NSUserDefaults standardUserDefaults];
    self.ip_tf.text = [ipDefault objectForKey:CURRENT_IP_KEY];

    if (self.ip_tf.text.length != 0) {
        self.submitBtn.backgroundColor = MAIN_COLOR;
        self.submitBtn.userInteractionEnabled = YES;
    } else {
        self.submitBtn.backgroundColor = RGB(220, 223, 230);
        self.submitBtn.userInteractionEnabled = NO;
    }

    [self setUpUI];
}

//==========================init==========================
#pragma mark ----- 初始化布局
- (void)setUpUI
{
    //返回按钮
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        if (iPhone_X_) {
            make.top.equalTo(self.view.mas_top).offset(50);
        } else {
            make.top.equalTo(self.view.mas_top).offset(30);
        }
    }];
    //ip提示语
    [self.view addSubview:self.ipTipLb];
    [self.ipTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        if (iPhone_X_) {
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacingX);
        } else {
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacing);
        }
        make.right.equalTo(self.view.mas_right).offset(-20);

        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"云平台配置", nil)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:28]  range:NSMakeRange(0, str.length)];
        CGSize maxSize = CGSizeMake(iPhoneWidth - 40, MAXFLOAT);
        CGSize attrStrSize = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.ipTipLb.frame = CGRectMake(20, 20, attrStrSize.width, attrStrSize.height);
        self.ipTipLb.attributedText = str;
    }];
    //ipView初始化
    [self.view addSubview:self.ipView];
    [self.ipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ipTipLb.mas_bottom).offset(TopSpacing);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];

    //http/https选择按钮
    [self.ipView addSubview:self.httpSelectBtn];
    [self.httpSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.ipView.mas_centerY);
        make.left.equalTo(self.ipView.mas_left).offset(0);
        make.width.mas_equalTo(@60);
    }];

    //箭头
    UIImageView *downArrow = [[UIImageView alloc]init];
    downArrow.image = [UIImage imageNamed:@"downArrow"];
    [self.httpSelectBtn addSubview:downArrow];
    [downArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.httpSelectBtn.mas_centerY).offset(2);
        make.right.equalTo(self.httpSelectBtn.mas_right).offset(0);
    }];

    //http/https选择按钮底部的line
    UILabel *numLineLb = [[UILabel alloc]init];
    numLineLb.backgroundColor = RGB(220, 220, 220);
    [self.ipView addSubview:numLineLb];
    [numLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.ipView.mas_bottom);
        make.left.equalTo(self.httpSelectBtn.mas_left).offset(0);
        make.right.equalTo(self.httpSelectBtn.mas_right).offset(0);
        make.height.mas_equalTo(@1);
    }];

    //ipView底部的line
    UIView *lineP = [[UIView alloc]init];
    lineP.backgroundColor = RGB(220, 220, 220);
    [self.ipView addSubview:lineP];
    [lineP mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(numLineLb.mas_right).offset(10);
        make.right.equalTo(self.ipView.mas_right).offset(0);
        make.bottom.equalTo(self.ipView.mas_bottom);
        make.height.mas_equalTo(@1);
    }];

    //ip文本
    [self.ipView addSubview:self.ip_tf];
    [self.ip_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.ipView.mas_centerY);
        make.left.equalTo(lineP.mas_left).offset(0);
        make.right.equalTo(self.ipView.mas_right).offset(0);
    }];

    //完成按钮
    [self.view addSubview:self.submitBtn];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.ipView.mas_bottom).offset(TopSpacing);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
}

//==========================method==========================
#pragma mark - 返回方法
- (void)returnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 完成按钮
- (void)submitClick
{
    [self.ip_tf resignFirstResponder];
    
    if (![NSString isValidateDomain:self.ip_tf.text]) {
        [XHToast showCenterWithText:NSLocalizedString(@"请输入合法的域名", nil)];
        return ;
    }
    

    NSUserDefaults *ipDefault = [NSUserDefaults standardUserDefaults];
    [ipDefault setObject:self.ip_tf.text forKey:CURRENT_IP_KEY];
    NSUserDefaults *ipType = [NSUserDefaults standardUserDefaults];
    [ipType setObject:httpStr forKey:HTTP_TYPE];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults *treeNodeDefault = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *channelModeDefault = [NSUserDefaults standardUserDefaults];//通道模式
    [[HDNetworking sharedHDNetworking]GET:@"common/groupTreeMode" parameters:postDic success:^(id _Nonnull responseObject) {
        NSLog(@"成功啦：%@", responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            if ([responseObject[@"body"] isEqual:@"channel"]) {
                //有树节点且为通道模式
                [treeNodeDefault setObject:[NSNumber numberWithBool:YES] forKey:IS_TREE_NODE];//树节点
                [channelModeDefault setObject:[NSNumber numberWithBool:YES] forKey:IS_CHANNEL_MODE];//通道
            } else {
                //有树节点
                [treeNodeDefault setObject:[NSNumber numberWithBool:YES] forKey:IS_TREE_NODE];
                [channelModeDefault setObject:[NSNumber numberWithBool:NO] forKey:IS_CHANNEL_MODE];//非通道
            }
        } else {
            //无树节点
            [treeNodeDefault setObject:[NSNumber numberWithBool:NO] forKey:IS_TREE_NODE];
            [channelModeDefault setObject:[NSNumber numberWithBool:NO] forKey:IS_CHANNEL_MODE];//非通道
        }
    } failure:^(NSError *_Nonnull error) {
        //无树节点
        [treeNodeDefault setObject:[NSNumber numberWithBool:NO] forKey:IS_TREE_NODE];
        [channelModeDefault setObject:[NSNumber numberWithBool:NO] forKey:IS_CHANNEL_MODE];//非通道
    }];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - http/https选择
- (void)httpSelectClick
{
    [self.ip_tf resignFirstResponder];
    //set title
    if (self.menuArray.count != 0) {
        if ([YCXMenu isShow]) {
            [YCXMenu dismissMenu];
        } else {
            [self showMenu];
        }
    } else {
        self.menuArray = @[[YCXMenuItem menuItem:@"http" image:nil tag:100 userInfo:nil], [YCXMenuItem menuItem:@"https" image:nil tag:101 userInfo:nil]];
        [self showMenu];
    }
}

- (void)showMenu
{
    [YCXMenu showMenuInView:self.view fromRect:CGRectMake(CGRectGetMaxX(self.httpSelectBtn.frame) - 30, CGRectGetMaxY(self.ipView.frame), 50, 0) menuItems:self.menuArray selected:^(NSInteger index, YCXMenuItem *item) {
        switch (index) {
            case 0: {
                [self.httpSelectBtn setTitle:@"http" forState:UIControlStateNormal];
                httpStr = @"http";
            }
            break;
            case 1: {
                [self.httpSelectBtn setTitle:@"https" forState:UIControlStateNormal];
                httpStr = @"https";
            }
            break;
            default:
                break;
        }
    }];
}

//==========================delegate==========================
- (void)textValueChanged {
    if (self.ip_tf.text.length != 0) {
        self.submitBtn.backgroundColor = MAIN_COLOR;
        self.submitBtn.userInteractionEnabled = YES;
    } else {
        self.submitBtn.backgroundColor = RGB(220, 223, 230);
        self.submitBtn.userInteractionEnabled = NO;
    }
}

//==========================lazy loading==========================
#pragma mark -----懒加载
//返回按钮
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.titleLabel.font = FONT(18);
        [_backBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
        [_backBtn setTitleColor:RGB(50, 50, 50) forState:UIControlStateNormal];
        [_backBtn setTitle:NSLocalizedString(@"返回", nil) forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

//IP配置提示语
- (UILabel *)ipTipLb
{
    if (!_ipTipLb) {
        _ipTipLb = [[UILabel alloc]init];
        _ipTipLb.font = FONTB(28);
        _ipTipLb.textAlignment = NSTextAlignmentLeft;
        _ipTipLb.numberOfLines = 0;//表示label可以多行显示
        _ipTipLb.lineBreakMode = NSLineBreakByWordWrapping;//换行模式，与上面的计算保持一致。
    }
    return _ipTipLb;
}

//http/https选择按钮
- (UIButton *)httpSelectBtn;
{
    if (!_httpSelectBtn) {
        _httpSelectBtn = [[UIButton alloc]init];

        //IP本地存储
        NSUserDefaults *ipTypeDefault = [NSUserDefaults standardUserDefaults];
        NSString *ipTypeStr = [ipTypeDefault objectForKey:HTTP_TYPE];
        if (ipTypeStr.length != 0) {
            if ([ipTypeStr isEqualToString:@"https"]) {
                [_httpSelectBtn setTitle:@"https" forState:UIControlStateNormal];
                httpStr = @"https";
            } else {
                [_httpSelectBtn setTitle:@"http" forState:UIControlStateNormal];
                httpStr = @"http";
            }
        } else {
            [_httpSelectBtn setTitle:@"http" forState:UIControlStateNormal];
            httpStr = @"http";
        }

        _httpSelectBtn.titleLabel.font = FONT(18);
        [_httpSelectBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_httpSelectBtn addTarget:self action:@selector(httpSelectClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _httpSelectBtn;
}
//IP配置View
- (UIView *)ipView {
    if (!_ipView) {
        _ipView = [[UIView alloc]init];
        _ipView.backgroundColor = [UIColor clearColor];
    }
    return _ipView;
}

//IP文本框
- (UITextField *)ip_tf {
    if (!_ip_tf) {
        _ip_tf = [[UITextField alloc]init];
        _ip_tf.font = FONT(17);
        _ip_tf.textColor = MAIN_COLOR;
        _ip_tf.placeholder = NSLocalizedString(@"请输入IP地址", nil);
        _ip_tf.keyboardType = UIKeyboardTypeURL;
        _ip_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_ip_tf addTarget:self action:@selector(textValueChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _ip_tf;
}

//完成按钮
- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        _submitBtn.userInteractionEnabled = NO;
        _submitBtn.layer.cornerRadius = 22.5f;
        [_submitBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
        _submitBtn.backgroundColor = RGB(220, 223, 230);
        _submitBtn.layer.cornerRadius = 20.0f;
        _submitBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        _submitBtn.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        _submitBtn.layer.shadowRadius = 3.0;
        _submitBtn.layer.shadowOpacity = 0.3;
        [_submitBtn addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

//下拉菜单数组
- (NSArray *)menuArray
{
    if (!_menuArray) {
        _menuArray = [NSArray array];
    }
    return _menuArray;
}

@end
