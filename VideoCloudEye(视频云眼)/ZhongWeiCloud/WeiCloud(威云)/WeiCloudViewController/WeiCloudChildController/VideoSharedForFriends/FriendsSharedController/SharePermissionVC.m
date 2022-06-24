//
//  SharePermissionVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#define FeatureOpen @1//1表示开启
#define FeatureClose @0//2表示未开启
#define FeaturenotSupport @2//0表示不支持

#define Talk NSLocalizedString(@"视频对讲", nil)
#define PlayBack NSLocalizedString(@"录像回放", nil)
#define CloudDeck NSLocalizedString(@"云台控制", nil)
#define Alarm NSLocalizedString(@"报警推送", nil)

#import "SharePermissionVC.h"
#import "ZCTabBarController.h"
#import "FriendsSharedVC.h"
#import "SharePermissionCell.h"
//#import "CmsFeatureModel.h"//CMS能力集
#import "FeatureModel.h"//设备能力集
@interface SharePermissionVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    NSNumber *isTalk;//是否支持对讲
    NSNumber *isPlayback;//是否支持回放
    NSNumber *isCloudDeck;//是否支持云台
    NSNumber *isAlarm;//是否支持报警推送
}
/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
/*完成按钮*/
@property (nonatomic,strong) UIButton *completeBtn;
/*最终显示出来的能力集*/
@property (nonatomic,strong) NSMutableArray *showResultArr;
/*cms能力集Model*/
@property (nonatomic,strong) Feature_cms *cmsModel;
/*分享设备能力集model*/
@property (nonatomic,strong) shareFeature *shareModel;
/*设备能力集*/
@property (nonatomic,strong) FeatureModel *featureModel;
@end

@implementation SharePermissionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"分享权限", nil);
    [self setNavBtnItem];
    self.view.backgroundColor = BG_COLOR;
    [self.view addSubview:self.tv_list];
    self.featureModel = [[FeatureModel alloc]init];
    
    [self setDeviceFeature:self.dev_mList];
    
    if (self.modifyPermissionDic) {
        
        if (self.featureModel.isTalk == 1) {//判断设备是否支持对讲
            if ([[self.modifyPermissionDic objectForKey:@"talk"] intValue] == 1) {
                isTalk = FeatureOpen;
            }else{
                isTalk = FeatureClose;
            }
        }else{
            isTalk = FeaturenotSupport;
        }
        
        //录像回放
        if ([[self.modifyPermissionDic objectForKey:@"hp"] intValue] == 1) {
            isPlayback = FeatureOpen;
        }else{
            isPlayback = FeatureClose;
        }
        
        if (self.featureModel.isCloudDeck == 1) {//判断设备是否支持云台
            if ([[self.modifyPermissionDic objectForKey:@"ptz"] intValue] == 1) {
                isCloudDeck = FeatureOpen;
            }else{
                isCloudDeck = FeatureClose;
            }
        }else{
            isCloudDeck = FeaturenotSupport;
        }
        
        //告警消息
        if ([[self.modifyPermissionDic objectForKey:@"alarm"] intValue] == 1) {
            isAlarm = FeatureOpen;
        }else{
            isAlarm = FeatureClose;
        }
        
    }else{
        //给其初始化（其他）能力集
        if (self.dev_mList.ext_info.shareFeature) {
            [self initSharedFeature];//赋值
        }else{
            isTalk = FeaturenotSupport;
            isPlayback = FeaturenotSupport;
            isCloudDeck = FeaturenotSupport;
            isAlarm = FeaturenotSupport;
        }
    }
    

    //将重新组成一个数组来进行显示
    if (![isPlayback isEqual: FeaturenotSupport]) {
        [self.showResultArr addObject:PlayBack];
    }
    if (![isAlarm isEqual: FeaturenotSupport]) {
        [self.showResultArr addObject:Alarm];
    }
    if (![isTalk isEqual: FeaturenotSupport]){
        [self.showResultArr addObject:Talk];
    }
    if (![isCloudDeck isEqual: FeaturenotSupport]) {
        [self.showResultArr addObject:CloudDeck];
    }
    
    [self.view addSubview:self.tv_list];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//=========================method======================
#pragma mark - 返回方法
- (void)returnVC
{
    //如果不支持，则设置成能力集关闭 PS：FeatureClose
    if ([isPlayback isEqual:FeaturenotSupport]) {
        isPlayback = FeatureClose;
    }
    if ([isAlarm isEqual:FeaturenotSupport]) {
        isAlarm = FeatureClose;
    }
    if ([isTalk isEqual:FeaturenotSupport]) {
        isTalk = FeatureClose;
    }
    if ([isCloudDeck isEqual:FeaturenotSupport]) {
        isCloudDeck = FeatureClose;
    }
    
    int tempTalk = [isTalk intValue];
    int tempHp = [isPlayback intValue];
    int tempPtz = [isCloudDeck intValue];
    int tempAlarm = [isAlarm intValue];
    
//    NSLog(@"isTalk:%d  isPlayback:%d  isCloudDeck:%d",self.shareModel.talk,self.shareModel.hp,self.shareModel.ptz);
//    NSLog(@"modelisTalk:%d  modelisPlayBack:%d  modelisCloudDeck:%d",tempTalk,tempHp,tempPtz);
    
    if (self.modifyPermissionDic) {
        //对讲
        if ( ([[self.modifyPermissionDic objectForKey:@"talk"] intValue] == tempTalk) && ([[self.modifyPermissionDic objectForKey:@"hp"] intValue] == tempHp) && ([[self.modifyPermissionDic objectForKey:@"ptz"] intValue] == tempPtz) && ([[self.modifyPermissionDic objectForKey:@"alarm"] intValue] == tempAlarm) ) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self createAlertView];
        }
        
    }else{
        //如果与进入时值相同，则直接退出
        if (([self.shareModel.talk intValue] == tempTalk) && ([self.shareModel.hp intValue] == tempHp) && ([self.shareModel.alarm intValue] == tempAlarm) && ([self.shareModel.ptz intValue] == tempPtz)) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self createAlertView];
        }
    }
}

#pragma mark - 警告框
- (void)createAlertView
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"你确定要放弃修改吗？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
#pragma mark - 点击完成按钮
- (void)completeClick
{
    //如果不支持，一定要记得传0给后台
    if ([isTalk isEqual:FeaturenotSupport]) {
        isTalk = FeatureClose;
    }
    if ([isPlayback isEqual:FeaturenotSupport]) {
        isPlayback = FeatureClose;
    }
    if ([isAlarm isEqual:FeaturenotSupport]) {
        isAlarm = FeatureClose;
    }
    if ([isCloudDeck isEqual:FeaturenotSupport]) {
        isCloudDeck = FeatureClose;
    }

    NSLog(@"isTalk:%@  isPlayback:%@  isCloudDeck:%@",isTalk,isPlayback,isCloudDeck);
    [Toast showLoading:self.view Tips:NSLocalizedString(@"正在设置分享权限，请稍候...", nil)];
    /*
     * description : POST v1/device/setSharedDev(分享权限)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & rtv=<实时视频>& talk=<对讲>& volice=<声音>& hp=<历史回放>& ptz=<云台>
     */
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:@1 forKey:@"rtv"];//实时视频
    [postDic setObject:@1 forKey:@"volice"];//声音
    [postDic setObject:isPlayback forKey:@"hp"];//历史回放
    [postDic setObject:isAlarm forKey:@"alarm"];//报警推送
    [postDic setObject:isTalk forKey:@"talk"];//对讲
    [postDic setObject:isCloudDeck forKey:@"ptz"];//云台
    [postDic setObject:self.dev_mList.ID forKey:@"dev_id"];//设备id
    
    
    if (self.modifyPermissionDic) {
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"startTime"] forKey:@"startTime"];
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"endTime"] forKey:@"endTime"];
        [postDic setObject:[self.modifyPermissionDic objectForKey:@"timeLimit"] forKey:@"timeLimit"];
        
    }else{
        //对时段与时限进行处理
        if (self.shareModel.startTime) {
            [postDic setObject:self.shareModel.startTime forKey:@"startTime"];
        }else{
            [postDic setObject:@"00:00" forKey:@"startTime"];
        }
        if (self.shareModel.endTime) {
            [postDic setObject:self.shareModel.endTime forKey:@"endTime"];
        }else{
            [postDic setObject:@"23:59" forKey:@"endTime"];
        }
        if ([self.shareModel.timeLimit intValue] == 0) {
            //时限
            [postDic setObject:@"-1" forKey:@"timeLimit"];
        }else{
            NSNumber *timeLimitNum = [NSNumber numberWithInteger:[self.shareModel.timeLimit integerValue]];
            //时限
            [postDic setObject:timeLimitNum forKey:@"timeLimit"];
        }
    }
    
    
    NSLog(@"权限设置后的postDic:%@",postDic);
    
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/setSharedDev" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"成功了%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            
            //修改本地的model
            NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
            tempAllGroupArr = [unitl getAllGroupCameraModel];
            NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
            devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
            
            for (int i = 0; i < devListArr.count; i++) {
                if ([((dev_list *)devListArr[i]).ID isEqualToString:self.dev_mList.ID]) {
                    dev_list * appointDevModel = devListArr[i];
                    appointDevModel.ext_info.shareFeature.hp = postDic[@"hp"];
                    appointDevModel.ext_info.shareFeature.alarm = postDic[@"alarm"];
                    appointDevModel.ext_info.shareFeature.ptz = postDic[@"ptz"];
                    appointDevModel.ext_info.shareFeature.talk = postDic[@"talk"];
                }
            }
            [unitl saveAllGroupCameraModel:tempAllGroupArr];
            
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"设置成功", nil)];
                
                NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
                [tempArr addObject:NSLocalizedString(@"预览", nil)];
                [tempArr addObject:NSLocalizedString(@"声音", nil)];
                if ([isPlayback isEqual: FeatureOpen]) {
                    [tempArr addObject:NSLocalizedString(@"回放", nil)];
                }
                if ([isAlarm isEqual: FeatureOpen]) {
                    [tempArr addObject:NSLocalizedString(@"告警", nil)];
                }
                if ([isTalk isEqual: FeatureOpen]) {
                    [tempArr addObject:NSLocalizedString(@"对讲", nil)];
                }
                if ([isCloudDeck isEqual: FeatureOpen]) {
                    [tempArr addObject:NSLocalizedString(@"云台", nil)];
                }
                
                
                FriendsSharedVC* sharedVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
                sharedVC.modifyPermissionArr = tempArr;
                sharedVC.modifyPermissionDic = postDic;
                [self.navigationController popToViewController:sharedVC animated:YES];
                
//                [self.navigationController popViewControllerAnimated:YES];
                     
            });
            
        }else{
            [Toast dissmiss];
            [XHToast showCenterWithText:NSLocalizedString(@"设置失败，请稍候再试", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        [XHToast showCenterWithText:NSLocalizedString(@"设置失败，请检查您的网络", nil)];
        NSLog(@"失败了");
    }];
    
    
    
    
}


#pragma mark - 初始化共享权限值
- (void)initSharedFeature
{
    self.shareModel = self.dev_mList.ext_info.shareFeature;
    self.cmsModel = self.dev_mList.ext_info.feature_cms;
//    [self setDeviceFeature:self.dev_mList];
    //云台
    if (self.featureModel.isCloudDeck == 1) {//支持云台
        if ([self.shareModel.ptz isEqualToString:@"1"]) {//开启
            isCloudDeck = FeatureOpen;
        }else{//关闭
            isCloudDeck = FeatureClose;
        }
    }else{//不支持
        isCloudDeck = FeaturenotSupport;
    }
    
    //对讲
    if (self.featureModel.isTalk == 1) {//支持对讲
        if ([self.shareModel.talk isEqualToString:@"1"]) {//开启对讲
            isTalk = FeatureOpen;
        }else{//关闭
            isTalk = FeatureClose;
        }
    }else{//不支持对讲
        isTalk = FeaturenotSupport;
    }
    
    //历史回放（均支持）
    if ([self.shareModel.hp isEqualToString:@"1"]) {//开启
        isPlayback = FeatureOpen;
    }else{//关闭
        isPlayback = FeatureClose;
    }
    
    //报警推送（均支持）
    if ([self.shareModel.alarm isEqualToString:@"1"]) {//开启
        isAlarm = FeatureOpen;
    }else{
        isAlarm = FeatureClose;
    }
}


//=========================delegate=========================
#pragma mark - tableview的代理方法
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else{
        return self.showResultArr.count;
    }
}
//cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray *defaultFuncArr = @[NSLocalizedString(@"实时预览", nil),NSLocalizedString(@"声音", nil)];
    static NSString* SharePermissionCell_Identifier = @"SharePermissionCell_Identifier";
    SharePermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:SharePermissionCell_Identifier];
    if(!cell){
        cell = [[SharePermissionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SharePermissionCell_Identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (section == 0) {
        cell.titleLb.text = defaultFuncArr[row];
    }else{
        cell.titleLb.text = self.showResultArr[row];
    }
    
    if (section == 0) {
        [cell.chooseBtn setBackgroundImage:[UIImage imageNamed:@"defaultChoose"] forState:UIControlStateNormal];
    }else{
        
        if ([self.showResultArr[row] isEqualToString:PlayBack] && [isPlayback isEqual:FeatureOpen]){
            cell.chooseBtn.selected = YES;
        }else if ([self.showResultArr[row] isEqualToString:Alarm] && [isAlarm isEqual:FeatureOpen]){
            cell.chooseBtn.selected = YES;
        }else if ([self.showResultArr[row] isEqualToString:Talk] && [isTalk isEqual:FeatureOpen]){
            cell.chooseBtn.selected = YES;
        }else if ([self.showResultArr[row] isEqualToString:CloudDeck] && [isCloudDeck isEqual:FeatureOpen]){
            cell.chooseBtn.selected = YES;
        }else{
            cell.chooseBtn.selected = NO;
        }
        
        [cell.chooseBtn setBackgroundImage:[UIImage imageNamed:@"chooseGou"] forState:UIControlStateSelected];
    }
    
    return cell;
    
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1) {
        SharePermissionCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.chooseBtn.selected == NO) {
            cell.chooseBtn.selected = YES;
            
            if ([self.showResultArr[row] isEqualToString:PlayBack]) {
                isPlayback = FeatureOpen;
            }
            if ([self.showResultArr[row] isEqualToString:Alarm]) {
                isAlarm = FeatureOpen;
            }
            if ([self.showResultArr[row] isEqualToString:Talk]) {
                isTalk = FeatureOpen;
            }
            if ([self.showResultArr[row] isEqualToString:CloudDeck]) {
                isCloudDeck = FeatureOpen;
            }
            
        }else{
            cell.chooseBtn.selected = NO;
            
            if ([self.showResultArr[row] isEqualToString:PlayBack]) {
                isPlayback = FeatureClose;
            }
            if ([self.showResultArr[row] isEqualToString:Alarm]) {
                isAlarm = FeatureClose;
            }
            if ([self.showResultArr[row] isEqualToString:Talk]) {
                isTalk = FeatureClose;
            }
            if ([self.showResultArr[row] isEqualToString:CloudDeck]) {
                isCloudDeck = FeatureClose;
            }
        }
    
        
    }
    
}

 //head高度
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
 {
     return 0.001;
 }
 
 //head的内容
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
     UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
     headView.backgroundColor = [UIColor clearColor];
     return headView;
 }
 
 //section底部间距
 - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
 {
     return 0.001;
 }
 //section底部视图
 - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
 {
     UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
     view.backgroundColor = [UIColor clearColor];
     return view;
 }
 


#pragma mark - getter&&setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, iPhoneWidth, iPhoneHeight-64) style:UITableViewStyleGrouped];
        _tv_list.backgroundColor = BG_COLOR;
        //设置代理
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tv_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tv_list;
}

-  (NSMutableArray *)showResultArr
{
    if (!_showResultArr) {
        _showResultArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _showResultArr;
}


#pragma mark ----- 设置能力集合
///设置能力集合
- (void)setDeviceFeature:(dev_list*)listModel{
    //1.判断Feature这个key到底在不在
    if (!listModel.ext_info.Feature) {
        NSLog(@"不存在Feature");
        self.featureModel.isWiFi = 0;
        self.featureModel.isTalk = 0;
        self.featureModel.isCloudDeck = 0;
        self.featureModel.isCloudStorage = 0;
        self.featureModel.isP2P = 0;
    }else{
        NSString *featureStr = listModel.ext_info.Feature;
        NSLog(@"featureStr:%@",featureStr);
        self.featureModel.isWiFi = [[featureStr substringWithRange:NSMakeRange(0,1)] intValue];
        self.featureModel.isTalk = [[featureStr substringWithRange:NSMakeRange(2,1)] intValue];
        self.featureModel.isCloudDeck = [[featureStr substringWithRange:NSMakeRange(4,1)] intValue];
        self.featureModel.isCloudStorage = [[featureStr substringWithRange:NSMakeRange(6,1)] intValue];
        self.featureModel.isP2P = [[featureStr substringWithRange:NSMakeRange(8,1)] intValue];
    }
}

@end
