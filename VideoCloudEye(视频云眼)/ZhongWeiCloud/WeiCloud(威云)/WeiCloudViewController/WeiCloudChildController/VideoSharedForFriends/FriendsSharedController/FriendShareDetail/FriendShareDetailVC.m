//
//  FriendShareDetailVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "FriendShareDetailVC.h"
//========Model========
//========View========
#import "SettingCellOne_t.h"
#import "SettingCellThree_t.h"
//========VC========
/*具体用户的权限*/
#import "SharePermissionDetailVC.h"
/*具体用户的时段限制*/
#import "SharetimeLimitDetailVC.h"
/*具体用户的分享时段*/
#import "SharePeriodDetailVC.h"
@interface FriendShareDetailVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;

@end

@implementation FriendShareDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    self.navigationItem.title = NSLocalizedString(@"分享权限设置", nil);
    [self cteateNavBtn];
    [self.view addSubview:self.tv_list];
    [self getPersonalSharePermissions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tv_list reloadData];
}

- (void)getPersonalSharePermissions
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"加载中，请稍候...", nil)];
    /*
     * description : GET v1/device/ getPersonalShare(查询该用户的权限)
     *  param：access_token=<令牌> & user_id =<用户ID>& to_userId=<用户ID> & dev_id=<设备ID>
     */
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.sharedPersonID forKey:@"to_userId"];
    [postDic setObject:self.dev_mList.ID forKey:@"dev_id"];
    
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/getPersonalShare" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                NSLog(@"responseObject:%@",responseObject);
            
                self.shareModel = [shareFeature mj_objectWithKeyValues:responseObject[@"body"][@"shareFeature"]];
                [self.tv_list reloadData];
            });
        }else{
            [Toast dissmiss];
            [XHToast showCenterWithText:NSLocalizedString(@"权限获取失败，请稍候再试", nil)];
        }

    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        [XHToast showCenterWithText:NSLocalizedString(@"当前网络不可用，请检查您的网络", nil)];
    }];
}
#pragma mark - 取消分享警告框
- (void)cancelShareAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"取消分享设备", nil) message:NSLocalizedString(@"确定取消分享设备给该用户?", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self cancelShare];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 取消分享
- (void)cancelShare
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"取消分享，请稍候...", nil)];
    NSMutableDictionary * guardDic = [NSMutableDictionary dictionary];
    [guardDic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [guardDic setObject:self.sharedPersonID forKey:@"shared_user"];
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/share/delete" parameters:guardDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"取消分享成功:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                //发送刷新设备列表的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"friendShareCancel" object:nil userInfo:nil];
                [self.navigationController popViewControllerAnimated:YES];
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

//=========================delegate=========================
#pragma mark - tableview的代理方法
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else{
        return 1;
    }
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 40;
    }else{
        return 20;
    }
}
//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    if (section == 0) {
        headView.frame = CGRectMake(0, 0, iPhoneWidth, 40);
        UILabel *tiplb = [FactoryUI createLabelWithFrame:CGRectMake(10, 15, 200, 20) text:NSLocalizedString(@"分享配置", nil) font:FONT(16)];
        tiplb.textColor = RGB(50, 50, 50);
        [headView addSubview:tiplb];
    }else{
        headView.frame = CGRectMake(0, 0, iPhoneWidth, 20);
    }
    return headView;
}
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.0001)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        static NSString* permissionConfigCell_Identifier = @"permissionConfigCell_Identifier";
        SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:permissionConfigCell_Identifier];
        if(!cell){
            cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:permissionConfigCell_Identifier];
        }
        if (row == 0) {
            cell.typeLabel.text = NSLocalizedString(@"分享权限", nil);
            
            if (self.shareModel) {//这个是请求的分享model，若有则显示；否则是由于网络问题造成的空，界面则不显示
                NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
                [tempArr addObject:NSLocalizedString(@"预览", nil)];
                [tempArr addObject:NSLocalizedString(@"声音", nil)];
                if ([self.shareModel.hp intValue] == 1) {
                    [tempArr addObject:NSLocalizedString(@"回放", nil)];
                }
                if ([self.shareModel.alarm intValue] == 1) {
                    [tempArr addObject:NSLocalizedString(@"告警", nil)];
                }
                if ([self.shareModel.talk intValue] == 1) {
                    [tempArr addObject:NSLocalizedString(@"对讲", nil)];
                }
                if ([self.shareModel.ptz intValue] == 1) {
                    [tempArr addObject:NSLocalizedString(@"云台", nil)];
                }
                cell.titleLabel.text = [tempArr componentsJoinedByString:@"、"];
            }
            
        }else if (row == 1){
            cell.typeLabel.text = NSLocalizedString(@"分享时段", nil);
            
            if (self.shareModel) {//这个是请求的分享model，若有则显示；否则是由于网络问题造成的空，界面则不显示
                //开始时间
                NSString *startTime;
                if (self.shareModel.startTime) {
                    startTime = self.shareModel.startTime;
                }else{
                    startTime = @"00:00";
                }
                //结束时间
                NSString *endTime;
                if (self.shareModel.endTime) {
                    endTime = self.shareModel.endTime;
                }else{
                    endTime = @"23:59";
                }
                
                cell.titleLabel.text = [NSString stringWithFormat:@"%@~%@",startTime,endTime];
            }
            
        }else{
            cell.typeLabel.text = NSLocalizedString(@"分享时限", nil);
            if (self.shareModel) {//这个是请求的分享model，若有则显示；否则是由于网络问题造成的空，界面则不显示
                if ([self.shareModel.timeLimit intValue] == 0 || [self.shareModel.timeLimit intValue] == -1) {
                    cell.titleLabel.text = NSLocalizedString(@"永久", nil);
                }else{
                    cell.titleLabel.text = [NSString stringWithFormat:@"%d%@",[self.shareModel.timeLimit intValue],NSLocalizedString(@"天", nil)];
                }
            }
        }
        return cell;
    }else{
        static NSString *DeleteCell_Identifier = @"DeleteCell_Identifier";
        SettingCellThree_t* cell = [tableView dequeueReusableCellWithIdentifier:DeleteCell_Identifier];
        if(!cell){
            cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DeleteCell_Identifier];
        }
        cell.deleteLabel.text = NSLocalizedString(@"取消分享", nil);
        [cell.deleteLabel setTextColor:[UIColor redColor]];
        return cell;
    }
    
    
}
#pragma mark - 点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            if (self.shareModel) {
                SharePermissionDetailVC *spVC = [[SharePermissionDetailVC alloc]init];
                spVC.dev_mList = self.dev_mList;
                spVC.shareModel = self.shareModel;
                spVC.sharedPersonID = self.sharedPersonID;
                [self.navigationController pushViewController:spVC animated:YES];
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"当前网络不可用，无法进行设置", nil)];
            }
        }else if (row == 1){
            if (self.shareModel) {
                SharePeriodDetailVC *spVC = [[SharePeriodDetailVC alloc]init];
                spVC.dev_mList = self.dev_mList;
                spVC.shareModel = self.shareModel;
                spVC.startTime = self.shareModel.startTime;
                spVC.endTime = self.shareModel.endTime;
                spVC.sharedPersonID = self.sharedPersonID;
                [self.navigationController pushViewController:spVC animated:YES];
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"当前网络不可用，无法进行设置", nil)];
            }
        }else{
            if (self.shareModel) {
                SharetimeLimitDetailVC *slVC = [[SharetimeLimitDetailVC alloc]init];
                slVC.dev_mList = self.dev_mList;
                slVC.shareModel = self.shareModel;
                slVC.sharedPersonID = self.sharedPersonID;
                [self.navigationController pushViewController:slVC animated:YES];
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"当前网络不可用，无法进行设置", nil)];
            }
        }
    }else{
        [self cancelShareAlert];
    }
    
}

#pragma mark - getter && setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) style:UITableViewStyleGrouped];
        _tv_list.backgroundColor = BG_COLOR;
        //设置代理
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _tv_list;
}


@end
