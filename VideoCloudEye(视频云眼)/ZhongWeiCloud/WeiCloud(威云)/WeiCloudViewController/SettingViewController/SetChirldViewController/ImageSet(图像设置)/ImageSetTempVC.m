//
//  ImageSetTempVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/2.
//  Copyright © 2018年 张策. All rights reserved.
//
#import "CircleSuccessLoading.h"
#import "CircleLoading.h"
#define pi 3.14159265359
#define DEGREES_TO_RADIANS(degress) ((pi * degress)/180)
#import "ImageSetTempVC.h"
//带按钮的cell
#import "SettingCellTwo_t.h"
//带箭头的有副标题的cell
#import "SettingCellOne_t.h"

//#import "DropDownView.h"
//#import "LewPopupViewController.h"
/*自定义滑动块*/
#import "CustomSlider.h"
@interface ImageSetTempVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
//    DropDownViewDelegate
>
{
    /*保存按钮*/
    UIButton * _saveBtn;
    /*镜像设置的参数*/
    NSString *mirrorParam;
    /*旋转设置类型*/
    NSString *rotateParam;
    /*是否打开开关*/
    BOOL isWdrEnable;
    /*宽动态设置*/
    NSNumber *wdrParam;
    /*根据设备类型显示section的个数*/
    NSInteger sectionCount;
}
/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
/*自定义滑块*/
@property (nonatomic,strong) CustomSlider *slider;
@end

@implementation ImageSetTempVC
//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"图像设置", nil);
    self.view.backgroundColor = BG_COLOR;
    [self setBarButtonItem];
    [self cteateNavBtn];
    mirrorParam = self.mirror;
    rotateParam = self.rotate;
    isWdrEnable = self.isWdr;
    wdrParam = self.wdr;
    NSLog(@"设备类型:%@",self.listModel.type);
    
    
    //暂时不需要宽动态，故设置sectionCount为1
    sectionCount = 1;
    /*
    if ([self.listModel.type isEqualToString:@"C11"]) {
        sectionCount = 1;
    }else{
        sectionCount = 3;
    }
    */
    
    [self.view addSubview:self.tv_list];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//=========================init=========================
#pragma mark - 设置导航栏按钮和响应事件
- (void)setBarButtonItem{
    _saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_saveBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(saveImageSet) forControlEvents:UIControlEventTouchUpInside];
    _saveBtn.highlighted = YES;
    _saveBtn.userInteractionEnabled = YES;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_saveBtn];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -10;
    self.navigationItem.rightBarButtonItems = @[rightItem,rightSpace];
}

//=========================method=========================
//保存图像设置
- (void)saveImageSet{
    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在保存图片设置", nil)];
    //图片设置
    [self postImageSetData];
}

//判断是否开启宽动态
-(void)changeValue:(UISwitch *)switchBtn{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        isWdrEnable = YES;
        _slider.userInteractionEnabled = YES;
        [self.tv_list reloadData];
    }else{
        switchBtn.on = NO;
        isWdrEnable = NO;
        _slider.userInteractionEnabled = NO;
        [self.tv_list reloadData];
    }
}

-(void)changeMirrorValue:(UISwitch *)switchBtn{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        mirrorParam = @"3";
        self.mirror = @"3";
    }else{
        switchBtn.on = NO;
        mirrorParam = @"0";
        self.mirror = @"0";
    }

}

//上传图像设置信息
-(void)postImageSetData{
    /*
     *  description : POST  v1/device/setpictureconfig(设置视频图像参数)
     *  param : access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & mirror=<镜像设置> & rotate= <旋转设置> & wdrEnable=<是否开启宽动态> & wdr=<结束时间>
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"user_id"];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [dic setObject:userID forKey:@"user_id"];
 
    if (mirrorParam) {
        [dic setObject:mirrorParam forKey:@"mirror"];
    }
    if (rotateParam) {
        [dic setObject:rotateParam forKey:@"rotate"];
    }
    
    if (isWdrEnable == YES) {
        [dic setObject:@"1" forKey:@"wdrEnable"];
    }else{
        [dic setObject:@"0" forKey:@"wdrEnable"];
    }
    
    if (wdrParam) {
        [dic setObject:wdrParam forKey:@"wdr"];
    }
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/setpictureconfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            [CircleLoading hideCircleInView:self.view];
            [CircleSuccessLoading showSucInView:self.view andTip:NSLocalizedString(@"图像设置成功", nil)];
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [CircleLoading hideCircleInView:self.view];
            [XHToast showCenterWithText:NSLocalizedString(@"图像设置失败,请稍候再试", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [CircleLoading hideCircleInView:self.view];
        [XHToast showCenterWithText:NSLocalizedString(@"图像设置失败,请检查您的网络", nil)];
    }];
}

//=========================delegate=========================

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return 30;
    }
    return 15;
}
//section顶部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    if (section == 2) {
        UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, iPhoneWidth, 30)];
        tipLb.text = NSLocalizedString(@"宽动态", nil);
        [tipLb setFont:FONT(13)];
        [tipLb setTextColor:[UIColor lightGrayColor]];
        [headView addSubview:tipLb];
    }
   
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return 20;
    }
    return 0.001;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    footView.backgroundColor = [UIColor clearColor];
    if (section == 2 && isWdrEnable == NO) {
            UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, iPhoneWidth, 20)];
            tipLb.text = NSLocalizedString(@"提示: 请先开启宽动态按钮", nil);
            [tipLb setFont:FONT(11)];
            [tipLb setTextColor:[UIColor lightGrayColor]];
            [footView addSubview:tipLb];
    }
    return footView;
}


//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        return 64;
    }
    return 44;
}
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionCount;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        static NSString *mirrorCellStr = @"mirrorCell";
        SettingCellTwo_t *cell = [tableView dequeueReusableCellWithIdentifier:mirrorCellStr];
        if(!cell){
            cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mirrorCellStr];
        }
        cell.typeLabel.text = NSLocalizedString(@"中心翻转", nil);
        
        NSString *mirrorStr = [NSString stringWithFormat:@"%@",self.mirror];
        if ([mirrorStr isEqualToString:@"3"]) {
            cell.switchBtn.on = YES;
        }else{
            cell.switchBtn.on = NO;
        }

        [cell.switchBtn addTarget:self action:@selector(changeMirrorValue:) forControlEvents:UIControlEventValueChanged];
        return cell;
      
    }else if (section == 1){

        static NSString *wdrEnableCellStr = @"wdrEnableCell";
        SettingCellTwo_t * cell = [tableView dequeueReusableCellWithIdentifier:wdrEnableCellStr];
        if(!cell){
            cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wdrEnableCellStr];
        }
        if (isWdrEnable == YES) {
            cell.switchBtn.on = YES;
        }else{
            cell.switchBtn.on = NO;
        }
        
        [cell.switchBtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
        cell.typeLabel.text = NSLocalizedString(@"是否开启宽动态", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        UITableViewCell *cell=[[UITableViewCell alloc]init];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        //创建cell视图
        [self createCellUI:cell];
        return cell;
    }
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 创建Cell的UI
- (void)createCellUI:(UITableViewCell *)cell{
     CGFloat num = [wdrParam floatValue];
    if (num != 0) {
        num = num - 1;
    }
   
    _slider=[[CustomSlider alloc] initWithFrame:CGRectMake(15, 10, iPhoneWidth-30, 44) titles:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"] firstAndLastTitles:@[@"1",@"10"] defaultIndex:num sliderImage:[UIImage imageNamed:@"slider"]];
    [cell.contentView addSubview:_slider];
    _slider.block=^(int index){
//        NSLog(@"当前index==%d",index);
        wdrParam = [NSNumber numberWithInt:index+1];//index表示第几个(实际情况需+1)
        
    };
    if (isWdrEnable == YES) {
        _slider.userInteractionEnabled = YES;
    }else{
        _slider.userInteractionEnabled = NO;
    }
    
}

//=========================lazy loading=========================
#pragma mark ----- 懒加载部分
-(UITableView *)tv_list{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64) style:UITableViewStyleGrouped];
        //设置代理
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.scrollEnabled = NO;
        _tv_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tv_list;
}
@end
