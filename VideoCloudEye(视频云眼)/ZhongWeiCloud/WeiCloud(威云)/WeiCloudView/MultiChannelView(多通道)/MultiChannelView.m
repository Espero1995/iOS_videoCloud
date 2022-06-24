//
//  MultiChannelView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/11/12.
//  Copyright © 2019 苏旋律. All rights reserved.
//
#define PAGESIZE 25

#import "MultiChannelView.h"
#import "MultiChannelModel.h"
#import "PassageWay_t.h"
#import "chansModel.h"
@interface MultiChannelView ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate
>
{
    NSInteger pageNum;//拿去请求的页码好，需要通过临时页码号来传值
    NSInteger tempNum;//临时使用的页码号
    NSInteger isNextPage;//判断是跳转下一页的还是跳转上一页的,默认0 是初始状态进入；1：表明上一页；2：表明下一页
}

/**
 * @brief 根据isMultiChannel字段进行区分来获取不同的数组内容
 * @description 通道数组(isMultiChannel = YES) / 设备列表(isMultiChannel = NO)
 */
@property (nonatomic,strong) NSMutableArray *dataArr;

//顶部导航栏
@property (nonatomic,strong)UIView *navView;
//导航栏标题
@property (nonatomic,strong)UILabel *titleLabel;
//表视图
@property (nonatomic, strong) UITableView *tv_list;
//页码输入框
@property (nonatomic, strong) UITextField *page_tf;
//左按钮
@property (nonatomic, strong) UIButton *leftPageBtn;
//右按钮
@property (nonatomic, strong) UIButton *rightPageBtn;

/**
 * @brief 判断是否是多通道
 */
@property (nonatomic,assign) BOOL isMultiChannel;

/**
 * @brief 设备id
 */
@property (nonatomic,copy) NSString *devId;

/**
 * @brief 设备model
 */
@property (nonatomic,strong) dev_list *listModel;

@end

@implementation MultiChannelView

- (instancetype)initWithFrame:(CGRect)frame isMultiChannel:(BOOL)isMultiChannel devId:(NSString *)devId andDevModel:(dev_list *)model;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isMultiChannel = isMultiChannel;
        self.devId = devId;
        self.listModel = model;
        
        pageNum = 0;
        tempNum = 0;
        isNextPage = 0;
        self.backgroundColor = BG_COLOR;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5.f;
        [self addSubview:self.navView];
        //添加导航栏标题
        [self.navView addSubview:self.titleLabel];
        self.titleLabel.center = self.navView.center;
        [self addSubview:self.tv_list];
        
        if (self.isMultiChannel) {
            //判断下是接口请求方式的多通道还是设备列表获取的多通道【self.listModel.chanCount】
            
            if (self.listModel.chanCount > 1) {//接口请求
                //多通道时请求获取通道数
                MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownMethod)];
                [header beginRefreshing];
                self.tv_list.mj_header = header;
                
                [self addSubview:self.page_tf];
                self.page_tf.text = [NSString stringWithFormat:@"%ld",pageNum+1];
                [self.page_tf mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.mas_centerX);
                    make.bottom.equalTo(self.mas_bottom).offset(-10);
                    make.size.mas_equalTo(CGSizeMake(100, 30));
                }];
                [self addSubview:self.leftPageBtn];
                [self.leftPageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.page_tf.mas_centerY);
                    make.right.equalTo(self.page_tf.mas_left).offset(-5);
                    make.size.mas_equalTo(CGSizeMake(25, 25));
                }];
                
                [self addSubview:self.rightPageBtn];
                [self.rightPageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.page_tf.mas_centerY);
                    make.left.equalTo(self.page_tf.mas_right).offset(5);
                    make.size.mas_equalTo(CGSizeMake(25, 25));
                }];
            }else{
                //此处就是用设备列表下的多通道
                self.dataArr = [chansModel mj_objectArrayWithKeyValuesArray:self.listModel.chans];
                
            }
            
            
            
            
        }else{
            
            //单通道时是用来获取当前列表下的设备数目
            [self.dataArr removeAllObjects];
            NSArray *tempArr = [[unitl getAllDeviceCameraModel] copy];
            for (int i = 0; i < tempArr.count; i++) {
                dev_list *VideolistModel =  tempArr[i];
                if (VideolistModel.chan_size == 1) {
                    if (VideolistModel.status == 1) {
                        [self.dataArr addObject:VideolistModel];
                    }
                }
            }
            
            
        }
        
        
        
    }
    return self;
}

//==========================method==========================
//下拉请求
- (void)pullDownMethod
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.devId forKey:@"dev_id"];
    [postDic setObject:[NSNumber numberWithInteger:(long)tempNum*PAGESIZE] forKey:@"offset"];
    [postDic setObject:[NSNumber numberWithInteger:PAGESIZE] forKey:@"limit"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/queryChanCodes" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"通道Id:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            
            NSArray *tempArr = [MultiChannelModel mj_objectArrayWithKeyValuesArray:responseObject[@"body"][@"deviceChannelCodeList"]];
            
            if (tempArr.count == 0) {
                [XHToast showCenterWithText:NSLocalizedString(@"暂无更多通道", nil)];
                
                //此处的判断是为了防止如果下一页没有数据了，页码需要倒退回原来的页面号
                tempNum = pageNum;
                self.page_tf.text = [NSString stringWithFormat:@"%ld",pageNum+1];
                [self.tv_list.mj_header endRefreshing];
                [self.tv_list reloadData];
                
            }else{
                pageNum = tempNum;
                [self.dataArr removeAllObjects];
                self.dataArr = [MultiChannelModel mj_objectArrayWithKeyValuesArray:responseObject[@"body"][@"deviceChannelCodeList"]];
                self.page_tf.text = [NSString stringWithFormat:@"%ld",pageNum+1];
                [self.tv_list.mj_header endRefreshing];
                [self.tv_list reloadData];
            }
            
        }else{
            [self.tv_list.mj_header endRefreshing];
            [XHToast showCenterWithText:NSLocalizedString(@"查询通道失败，请稍后再试", nil)];
            //此处的判断是为了防止如果请求失败了，页码需要倒退回原来的页面号
            tempNum = pageNum;
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.tv_list.mj_header endRefreshing];
        [XHToast showCenterWithText:NSLocalizedString(@"查询通道失败，请检查您的网络", nil)];
        //此处的判断是为了防止如果请求失败了，页码需要倒退回原来的页面号
        tempNum = pageNum;
    }];
    
    
}

//上一页点击事件
- (void)previousChannelPage
{
    if (tempNum == 0) {
        [XHToast showCenterWithText:NSLocalizedString(@"当前已经是第一页", nil)];
    }else{
        tempNum --;
        isNextPage = 1;
        [self pullDownMethod];
    }
}

//下一页点击事件
- (void)nextChannelPage
{
    tempNum ++;
    isNextPage = 2;
    [self pullDownMethod];
}

- (BOOL)deptNumInputShouldNumber:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}


//==========================delegate==========================
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString * str = @"MyCell";
    PassageWay_t *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[PassageWay_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    if (self.isMultiChannel) {
        if (self.listModel.chanCount > 1) {
            MultiChannelModel *model = self.dataArr[row];
            cell.titleLbel.text = model.chanName;
        }else{
            chansModel *model = self.dataArr[row];
            cell.titleLbel.text = model.name;
        }
        
    }else{
        dev_list *devModel = self.dataArr[row];
        NSLog(@"devModel:%@",devModel.type);
        if ([unitl isNull:devModel.name]) {
            cell.titleLbel.text = [NSString stringWithFormat:@"%@", devModel.type];
        }else{
            cell.titleLbel.text = [NSString stringWithFormat:@"%@", devModel.name];
        }
    }
    
    
    return cell;
}

//cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (self.isMultiChannel) {
        if (self.listModel.chanCount > 1) {
            //多通道设备列表选择
            MultiChannelModel *model = self.dataArr[row];
            if (self.channelDelegate && [self.channelDelegate respondsToSelector:@selector(didSelectedCellIndex:withChannelModel:)]) {
                [self.channelDelegate didSelectedCellIndex:indexPath withChannelModel:model];
            }
        }else{
            chansModel *model = self.dataArr[row];
            if (self.channelDelegate && [self.channelDelegate respondsToSelector:@selector(didSelectedCellIndex:withChansModel:)]) {
                [self.channelDelegate didSelectedCellIndex:indexPath withChansModel:model];
            }
        }
        
        
    }else{
        dev_list *devModel = self.dataArr[row];
        //设备列表
        if (self.channelDelegate && [self.channelDelegate respondsToSelector:@selector(didSelectedCellIndex:WithDeviceModel:isNVR:)]) {
            [self.channelDelegate didSelectedCellIndex:indexPath WithDeviceModel:devModel isNVR:NO];
        }
        
    }
    
    
    
}

//搜索虚拟键盘响应

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"点击了搜索:%@",textField.text);
    if ([self deptNumInputShouldNumber:textField.text]) {
        tempNum = [textField.text integerValue];
        [self.page_tf resignFirstResponder];
        [self pullDownMethod];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"请输入数字", nil)];
        return NO;
    }
    
    return YES;
}

#pragma mark - getters && setters
- (UITableView *)tv_list
{
    if (!_tv_list) {
        if (self.isMultiChannel && self.listModel.chanCount > 1) {
            _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.frame.size.width ,self.frame.size.height - 44 - 50) style:UITableViewStylePlain];
        }else{
            _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.frame.size.width ,self.frame.size.height - 44) style:UITableViewStylePlain];
        }
        
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _tv_list;
}

//导航栏标题
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = NSLocalizedString(@"通道列表", nil);
    }
    return _titleLabel;
}

//导航栏
- (UIView *)navView
{
    if (!_navView) {
        _navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        _navView.backgroundColor = MAIN_COLOR;
    }
    return _navView;
}
//页码输入框
- (UITextField *)page_tf
{
    if (!_page_tf) {
        _page_tf = [[UITextField alloc]init];
        _page_tf.borderStyle = UITextBorderStyleRoundedRect;
        _page_tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _page_tf.returnKeyType = UIReturnKeySearch; //设置按键类型
        _page_tf.placeholder = NSLocalizedString(@"页码", nil);
        _page_tf.textAlignment = NSTextAlignmentCenter;
        _page_tf.delegate = self;
    }
    return _page_tf;
}

//左按钮
- (UIButton *)leftPageBtn
{
    if (!_leftPageBtn) {
        _leftPageBtn = [[UIButton alloc]init];
        [_leftPageBtn setBackgroundImage:[UIImage imageNamed:@"channelLeft"] forState:UIControlStateNormal];
        [_leftPageBtn addTarget:self action:@selector(previousChannelPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftPageBtn;
}

//右按钮
- (UIButton *)rightPageBtn
{
    if (!_rightPageBtn) {
        _rightPageBtn = [[UIButton alloc]init];
        [_rightPageBtn setBackgroundImage:[UIImage imageNamed:@"channelRight"] forState:UIControlStateNormal];
        [_rightPageBtn addTarget:self action:@selector(nextChannelPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightPageBtn;
}


//根据isMultiChannel字段进行区分来获取不同的数组内容
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

@end
