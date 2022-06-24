//
//  AdjustSensitivityController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/21.
//  Copyright © 2017年 张策. All rights reserved.
//
#define pi 3.14159265359
#define DEGREES_TO_RADIANS(degress) ((pi * degress)/180)
#import "AdjustSensitivityController.h"
#import "SetTimeModel.h"
#import "CircleLoading.h"
#import "CircleSuccessLoading.h"
@interface AdjustSensitivityController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    //开始时间
    NSString * _beginTime;
    //结束时间
    NSString * _stopTime;
    //重复周期
    NSMutableString * _weekString;
    NSMutableArray * _dataArr;
}
@property(nonatomic,strong) UITableView *tableView;
//header上灵敏度提示文本
@property(nonatomic,strong) UILabel *tipLabel;
//等待框
@property (nonatomic,strong) UIView * backView;
//等待框里的提示语
@property (nonatomic,strong) UILabel * label;
//绘画圆弧的图
@property (nonatomic,strong) CAShapeLayer *shapeLayer;

@end

@implementation AdjustSensitivityController
//======================system========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"移动侦测灵敏度", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self cteateNavBtn];
    [self createData];
    [self createTableView];
}
//当pop出去时使用
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //调用自己的block 给它传入一个实参【灵敏度值】
    NSString *tempStr = self.tipLabel.text;
    //去掉除了数字以外的字符
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z\u4e00-\u9fa5]+" options:0 error:NULL];
  NSString *result = [regular stringByReplacingMatchesInString:tempStr options:0 range:NSMakeRange(0, [tempStr length]) withTemplate:@""];
    //去掉冒号
    self.block([result substringFromIndex:1]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//======================init========================
#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{
    
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor= BG_COLOR;
    self.tableView.scrollEnabled=NO;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    [self.view addSubview:self.tableView];
}

#pragma mark ------生成数据源
//数据源
- (void)createData{
    _dataArr = [[NSMutableArray alloc]init];
    _weekString = [[NSMutableString alloc]init];
    _beginTime = [[NSString alloc]init];
    _stopTime = [[NSString alloc]init];
    //获取数据
//    [self getData];
}
#pragma mark ------ 查询布防
//查询布放
- (void)getData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/getguardplan" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"查询布放：11%@",responseObject);
            [_dataArr removeAllObjects];
            SetTimeModel * model = [SetTimeModel mj_objectWithKeyValues:responseObject[@"body"]];
            _dataArr = [NSMutableArray arrayWithArray:model.guardConfigList];
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:model.guardConfigList[0]];
            _beginTime = [dic valueForKey:@"start_time"];
            _stopTime = [dic valueForKey:@"stop_time"];
            _weekString = [dic valueForKey:@"period"];
            int temp = [dic[@"enable"] intValue];
            if (temp == 1) {
                _subing = YES;
            }else if (temp == 0){
                _subing=NO;
            }
            
        }else{
            //灵敏度设置为60【默认】
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求错误！");
    }];
}


//======================delegate========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc]init];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    //创建cell视图
    [self createCellUI:cell];
    return cell;
}

#pragma mark ----- 设置区头区尾
//区头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

//区头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
        UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 35)];
        _tipLabel= [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 0, 0) text:nil font:[UIFont systemFontOfSize:14]];
        _tipLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"当前灵敏度", nil),_adjustDegree];
        _tipLabel.textColor = [UIColor colorWithHexString:@"b2b2b2"];
        _tipLabel.numberOfLines = 1;
        [backView addSubview:_tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView.mas_left).offset(20);
            make.top.equalTo(backView.mas_top).offset(15);
            make.size.mas_equalTo(CGSizeMake(255, 14));
        }];
        return backView;
        
}
//======================method========================
#pragma mark ------设置布防
- (void)setGuardPlan:(NSString *)str{
     NSLog(@"灵敏度：%@，开始时间：%@，结束时间：%@，周期：%@",str,self.startTime,self.endTime,self.periodStr);
    
    NSMutableDictionary* guardDic = [NSMutableDictionary dictionary];
    [guardDic setObject:self.listModel.ID forKey:@"dev_id"];
    [guardDic setObject:@"1"forKey:@"alarmType"];
    [guardDic setObject:@"1" forKey:@"enable"];
    [guardDic setObject:self.startTime forKey:@"start_time"];
    [guardDic setObject:self.endTime forKey:@"stop_time"];
    [guardDic setObject:self.periodStr forKey:@"period"];
//    [guardDic setObject:_beginTime forKey:@"start_time"];
//    [guardDic setObject:_stopTime forKey:@"stop_time"];
//    [guardDic setObject:_weekString forKey:@"period"];
    
    
    //    NSLog(@"灵敏度：%@",str);
    NSNumber *degree = @([str integerValue]);
    [guardDic setObject:degree forKey:@"sensibility"];
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/setguardplan" parameters:guardDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"result:%@",responseObject);
        //上传数据之后并将页面样式改变顺便去除加载视图
//        self.tipLabel.text=[NSString stringWithFormat:@"当前灵敏度:%@",str];
//        [self.backView removeFromSuperview];
        
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [CircleSuccessLoading showSucInView:self.view andTip:NSLocalizedString(@"灵敏度设置成功", nil)];
            self.tipLabel.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"当前灵敏度", nil),str];
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"灵敏度设置失败，请稍候再试", nil)];
        }
        [CircleLoading hideCircleInView:self.view];
    } failure:^(NSError * _Nonnull error) {
        [self createNetWrong];
        [CircleLoading hideCircleInView:self.view];
    }];
    
}


#pragma mark - 创建Cell的UI
- (void)createCellUI:(UITableViewCell *)cell{
    //初始化Slider
    CGFloat left = 20;
    CGFloat width = iPhoneWidth - left*2;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(left, 100/2+10, width, 20)];

    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;
    
//    //当前值
//    if ([_adjustDegree isEqualToString:@""]) {
//        _adjustDegree = @"60";
//        slider.value=[_adjustDegree floatValue]/100.0;
//    }else{
//        slider.value=[_adjustDegree floatValue]/100.0;
//    }
    slider.value = [_adjustDegree floatValue]/100.0;
    slider.minimumTrackTintColor=[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    slider.maximumTrackTintColor=[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    [cell.contentView addSubview:slider];
    
    slider.continuous = YES;//注意设置为NO能保证是在Changed之后放开赋值
    [slider addTarget:self action:@selector(stopChange:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法UIControlEventTouchUpInside/UIControlEventValueChanged
    
    //三个低中高提示label
    UILabel *lowLb = [[UILabel alloc]initWithFrame:CGRectMake(left, 25, 50, 20)];
    lowLb.text = NSLocalizedString(@"低", nil);
    [cell.contentView addSubview:lowLb];
    UILabel *midLb = [[UILabel alloc]initWithFrame:CGRectMake((iPhoneWidth-100)/2, 25, 100, 20)];
    midLb.text  = NSLocalizedString(@"中", nil);
    midLb.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:midLb];
    UILabel *highLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(slider.frame)-20, 25, 50, 20)];
    highLb.text = NSLocalizedString(@"高", nil);
    [cell.contentView addSubview:highLb];
    
    //两端的端点
    UILabel *leftSideLb = [[UILabel alloc]initWithFrame:CGRectMake(left, 60+20/2-10/2, 2, 10)];
    leftSideLb.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    [cell.contentView addSubview:leftSideLb];
    UILabel *rightSideLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(slider.frame)-2, 60+20/2-10/2, 2, 10)];
    rightSideLb.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    [cell.contentView addSubview:rightSideLb];
    self.tipLabel.text = [NSString stringWithFormat:@"%@:%ld",NSLocalizedString(@"当前灵敏度", nil),(long)round(slider.value)*100];

}

// slider变动时改变label值
- (void)sliderValueChanged:(id)sender {

    UISlider *slider = (UISlider *)sender;
    CGFloat pro = slider.value;
//    NSString *sensitivityStr=[NSString stringWithFormat:@"当前灵敏度:%ld",(long)round(pro*100)];
     NSString *sensitivityStr=[NSString stringWithFormat:@"%ld",(long)round(pro*100)];
     NSLog(@"sensitivityStr:%@",sensitivityStr);
    self.tipLabel.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"当前灵敏度", nil),sensitivityStr];
}

- (void)stopChange:(id)sender
{
    NSLog(@"STOP");
    UISlider *slider = (UISlider *)sender;
    CGFloat pro = slider.value;
    NSString *sensitivityStr=[NSString stringWithFormat:@"%ld",(long)round(pro*100)];
    NSLog(@"sensitivityStr:%@",sensitivityStr);
    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在设置灵敏度", nil)];
    [self setGuardPlan:sensitivityStr];
}


//等待框
- (void)createWaitBox:(NSString *)str{
    
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
//    _backView.backgroundColor = [UIColor clearColor];
    //背景设置黑色+透明度
    self.backView.backgroundColor = [UIColor blackColor];
    self.backView.alpha=0.65f;
    [self.view addSubview:_backView];
    [self.view bringSubviewToFront:_backView];
    
//    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(50, iPhoneHeight/2-50, iPhoneWidth-100, 100)];
     UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0.15*iPhoneWidth, iPhoneHeight/2-80, iPhoneWidth*0.7, 100)];
    view.layer.cornerRadius = 3.0f;
    view.backgroundColor = [UIColor whiteColor];
    [_backView addSubview:view];
    
    //画圆
    CALayer *circleLayer = [CALayer layer];
    circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    circleLayer.frame = CGRectMake(10,38,24,24);
//    [view.layer addSublayer:circleLayer];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.strokeColor = MAIN_COLOR.CGColor;//[UIColor colorWithRed:0/255.0 green:170/255.0 blue:255/255.0 alpha:1]
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.lineWidth = 5;
    
    UIBezierPath *thePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(12, 12) radius:24-3.5 startAngle:0 endAngle:DEGREES_TO_RADIANS(225) clockwise:YES];
    _shapeLayer.path = thePath.CGPath;
    [circleLayer addSublayer:_shapeLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation.z";
    animation.duration = 1.f;
    animation.fromValue = @(0);
    animation.toValue = @(2*M_PI);
    animation.repeatCount = INFINITY;
    
    [circleLayer addAnimation:animation forKey:nil];
    //带参数
//    [self performSelector:@selector(delayDo:) withObject:str afterDelay:2.0f];
    //
    [self setGuardPlan:str];
    
    NSString *tempStr = NSLocalizedString(@"正在设置灵敏度", nil);
    
    CGSize size = [tempStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(60, 0, size.width + 25, 100);
    _label.text = tempStr;
    //    _label.textColor = [UIColor whiteColor];
    float contentWidth = size.width + 50 +25;
    
    //来刚好容纳菊花旋转+字
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake((0.7*iPhoneWidth - contentWidth)/2, 0, contentWidth, 100)];
    //        contentView.backgroundColor = [UIColor blueColor];
    
    [contentView.layer addSublayer:circleLayer];
    [contentView addSubview:_label];
    
    [view addSubview:contentView];
}


//- (void)delayDo:(id)sender{
//    NSString *str;
//    if ( [sender isKindOfClass:[NSString class]] ) {
//        str = sender;
//    }
//    self.tipLabel.text=str;
//    [self.backView removeFromSuperview];
//
//}


- (void)createNetWrong{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"正在设置灵敏度", nil) message:NSLocalizedString(@"网络不畅哦，是否退出？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
