//
//  GroupNamedVC.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupNamedVC.h"

@interface GroupNamedVC ()
<
UITextFieldDelegate
>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;

@end

@implementation GroupNamedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDefaultParameters];
}

- (void)setDefaultParameters
{
    self.view.backgroundColor = BG_COLOR;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backClick)];
    self.navigationItem.title = NSLocalizedString(@"分组名称", nil);
    self.nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTF.delegate = self;
    self.finishBtn.enabled = NO;
}


#pragma mark =========  action  =========
//返回
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)finishBtnClick:(id)sender {
    [self.nameTF resignFirstResponder];
    if ([self isInputRuleAndBlank:self.nameTF.text]) {
        //注意：此处还需要判断组名有没有重复
        [Toast showLoading:self.view Tips:NSLocalizedString(@"正在创建分组，请稍候...", nil)];
        [self createGroupRequest];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"组名只支持字母、数字和中文", nil)];
    }
}

- (void)createGroupRequest
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSString * tempGroupNameStr = [NSString stringWithFormat:@"%@",self.nameTF.text];
    NSMutableArray *  tempDeciceIdsArr = self.deviceIdsArr;
    //NSMutableArray * tempChansArr = self.chansArr;
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * tempChansDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [tempDic setObject:tempGroupNameStr forKey:@"groupName"];
    [tempDic setObject:tempDeciceIdsArr forKey:@"devcieIds"];
    [tempDic setObject:tempChansDic forKey:@"channels"];//这里的channels需要传dic
    [tempDic setObject:@"" forKey:@"createDate"];
    [tempDic setObject:@"" forKey:@"enableSensibility"];
    [tempDic setObject:@"" forKey:@"groupId"];
    [tempDic setObject:[unitl get_User_id] forKey:@"ownerId"];
    [tempDic setObject:@"" forKey:@"silentMode"];
    [tempDic setObject:@"NO" forKey:@"top"];
    
    NSString * jsonStr = [unitl dictionaryToJSONString:tempDic];
    [dic setObject:jsonStr forKey:@"jsonStr"];

    [[HDNetworking sharedHDNetworking]POST:@"v1/devicegroup/create" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"创建分组:%@",responseObject);
        if (ret == 0) {
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"创建成功", nil)];
                [self UpDateGroupInfo];
                [[NSNotificationCenter defaultCenter]postNotificationName:GroupCreateOrDeleteSuccess_updateUI object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];//需要刷新设备列表
            });
            
        }else
        {
            [Toast dissmiss];
            switch (ret) {
                case -1:
                {
                    [XHToast showCenterWithText:NSLocalizedString(@"创建组别失败", nil)];
                }
                    break;
                case 1603:
                {
                    [XHToast showCenterWithText:NSLocalizedString(@"创建组别已达上限", nil)];
                }
                    break;
                case 1601:
                {
                    [XHToast showCenterWithText:NSLocalizedString(@"该分组名称已被占用", nil)];
                }
                    break;
                    
                default:
                    break;
            }
        }
//        WeiCloudListModel *listModel = [WeiCloudListModel mj_objectWithKeyValues:responseObject[@"body"]];
//        NSInteger groupCount = listModel.deviceGroup.count;
    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        [XHToast showCenterWithText:NSLocalizedString(@"创建失败，请检查您的网络", nil)];
        NSLog(@"查询失败 网络正在开小差...");
    }];
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
//        NSLog(@"111查询分组信息:%@",responseObject);
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
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"查询分组 网络正在开小差...");
    }];
}

#pragma mark ======= textField的代理 =======
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    if (textField.text.length <= 10  && textField.text.length >= 1) {
        self.finishBtn.backgroundColor = [UIColor orangeColor];
        self.finishBtn.enabled = YES;
    }else{
        self.finishBtn.backgroundColor = RGB(180, 180, 180);
        self.finishBtn.enabled = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.nameTF) {
        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        else if (self.nameTF.text.length >= 10) {
            self.nameTF.text = [textField.text substringToIndex:10];
            return NO;
        }
    }
    return YES;
}

//只支持字母数字和中文
- (BOOL)isInputRuleAndBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark ----- getter && setter
- (NSMutableArray *)deviceIdsArr
{
    if (!_deviceIdsArr) {
        _deviceIdsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _deviceIdsArr;
}

- (NSMutableArray *)chansArr
{
    if (!_chansArr) {
        _chansArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _chansArr;
}


@end
