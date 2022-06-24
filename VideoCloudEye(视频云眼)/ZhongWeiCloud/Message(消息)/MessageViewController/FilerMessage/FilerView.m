//
//  FilerView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "FilerView.h"
#import "FilerDeviceCell.h"//设备cell
#import "FilerDateCell.h"//日期cell
@interface FilerView()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic,strong) UITableView* tv_list;//表视图
@property (nonatomic,strong) UIView* headView;//头部视图
@property (nonatomic,strong) UILabel* titleLb;//标题
@property (nonatomic,strong) UIView* line;//线条
@property (nonatomic,strong) UIButton* closeFilerBtn;//关闭按钮
@property (nonatomic,strong) UIView* bottomView;//底部视图
@property (nonatomic,strong) UIButton* resetBtn;//重置按钮
@property (nonatomic,strong) UIButton* submitBtn;//确定按钮
@property (nonatomic,strong) NSMutableArray* deviceNameArr;
@property (nonatomic,strong) NSArray *dateArr;

@property(nonatomic,strong)NSIndexPath *lastPath;//***主要是用来接收用户上一次所选的cell的indexpath
@end

@implementation FilerView
- (instancetype)initWithDateArr : (NSArray *)dateArr
                          frame : (CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = BG_COLOR;
        if (iPhone_X_) {
            self.tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 88, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight-100) style:UITableViewStyleGrouped];
        }else{
            self.tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight-60) style:UITableViewStyleGrouped];
        }
        
        self.tv_list.delegate = self;
        self.tv_list.dataSource = self;
        self.tv_list.backgroundColor = BG_COLOR;
        [self addSubview:self.tv_list];
        
        //头部视图
        [self addSubview:self.headView];
        [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_top).offset(0);
            if (iPhone_X_) {
                make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 88));
            }else{
                make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 64));
            }
        }];
        [self.headView addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.headView);
            make.bottom.equalTo(self.headView.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 0.5));
        }];
        [self.headView addSubview:self.titleLb];
        [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.headView);
            if (iPhone_X_) {
                make.centerY.equalTo(self.headView.mas_centerY).offset(20);
            }else{
                make.centerY.equalTo(self.headView.mas_centerY).offset(7);
            }
        }];
        //关闭按钮
        [self.headView addSubview:self.closeFilerBtn];
        [self.closeFilerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLb.mas_centerY);
            make.right.equalTo(self.headView.mas_right).offset(-20);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        //底部视图
        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(0);
            if (iPhone_X_) {
                make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 100));
            }else{
                make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 60));
            }
            
        }];
        //重置按钮
        [self.bottomView addSubview:self.resetBtn];
        [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomView.mas_centerY);
            make.left.mas_equalTo(0.1*0.5*iPhoneWidth);
            make.size.mas_equalTo(CGSizeMake(0.8*0.5*iPhoneWidth, 45));
        }];
        //确定按钮
        [self.bottomView addSubview:self.submitBtn];
        [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomView.mas_centerY);
            make.left.equalTo(self.resetBtn.mas_right).offset(0.2*0.5*iPhoneWidth);
            make.size.mas_equalTo(CGSizeMake(0.8*0.5*iPhoneWidth, 45));
        }];
        
        self.dateArr = dateArr;
    }
    return self;
}

//==========================method==========================
#pragma mark - 关闭筛选消息视图
- (void)closeFilerClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeFilerView)]) {
        [self.delegate closeFilerView];
    }
}
#pragma mark - 重置按钮的点击事件
- (void)resetClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(resetAllinfoClick)]) {
        [self.delegate resetAllinfoClick];
    }
}
#pragma mark - 提交按钮的点击事件
- (void)submitClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(submitFlierClick)]) {
        [self.delegate submitFlierClick];
    }
}
//获取设备名数组
- (void)getDeviceNameArr:(NSMutableArray *)arr
{
    if (arr.count == 0) {
//        _lastPath = nil;//TODO??????
    }
    self.deviceNameArr = arr;
    [self.tv_list reloadData];
}
//获取设备名数组并重置日期
- (void)resetDateandGetDeviceNameArr:(NSMutableArray *)arr
{
    if (arr.count == 0) {
       _lastPath = nil;
    }
    self.deviceNameArr = arr;
    [self.tv_list reloadData];
}

//==========================delegate==========================
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return 7;
    }
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        static NSString* filerDeviceCell_Identifier = @"filerDeviceCell_Identifier";
        FilerDeviceCell* filerDeviceCell = [tableView dequeueReusableCellWithIdentifier:filerDeviceCell_Identifier];
        if(!filerDeviceCell){
            filerDeviceCell = [[FilerDeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:filerDeviceCell_Identifier];
        }
        if (self.deviceNameArr.count == 0) {
            filerDeviceCell.textLabel.text = NSLocalizedString(@"全部设备", nil);
            filerDeviceCell.textLabel.textColor = [UIColor blackColor];
        }else{
            filerDeviceCell.textLabel.text = [self.deviceNameArr componentsJoinedByString:@"、"];
            filerDeviceCell.textLabel.textColor = [UIColor redColor];
        }
        
       return filerDeviceCell;
    }else{
        static NSString* filerDateCell_Identifier = @"filerDateCell_Identifier";
        FilerDateCell* filerDateCell = [tableView dequeueReusableCellWithIdentifier:filerDateCell_Identifier];
        if(!filerDateCell){
            filerDateCell = [[FilerDateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:filerDateCell_Identifier];
        }
        filerDateCell.dateLb.text = self.dateArr[row];
        filerDateCell.dateLb.textColor = RGB(60, 60, 60);
        
        /////
        NSInteger oldRow = [_lastPath row];
        if (row == oldRow && _lastPath!=nil) {
            filerDateCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            filerDateCell.accessoryType = UITableViewCellAccessoryNone;
        }
        /////
        return filerDateCell;
    }
    
}
//cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *newIndexPath;
    if (indexPath.section == 1) {
        NSInteger newRow = [indexPath row];
        NSInteger oldRow = (self .lastPath !=nil)?[self .lastPath row]:-1;
        if (newRow != oldRow) {
            FilerDateCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            FilerDateCell *oldCell = [tableView cellForRowAtIndexPath:_lastPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.lastPath = indexPath;
            newIndexPath = indexPath;
        }else{
            FilerDateCell *oldCell = [tableView cellForRowAtIndexPath:_lastPath];
            _lastPath = nil;
            newIndexPath = [NSIndexPath indexPathForRow:-1 inSection:1];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate) {
        [self.delegate SelectSectionofRowAtIndex:newIndexPath];
    }
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}
//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    if (section == 0) {
        UILabel* deviceTipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, iPhoneWidth, 35)];
        deviceTipLb.text = NSLocalizedString(@"设备选择", nil);
        deviceTipLb.textColor = RGB(95, 95, 95);
        deviceTipLb.font = FONT(16);
        [headView addSubview:deviceTipLb];
    }else{
        UILabel* dateTipLb = [[UILabel alloc]init];
        [headView addSubview:dateTipLb];
        [dateTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(headView.mas_centerY);
            make.left.equalTo(headView.mas_left).offset(15);
        }];
        dateTipLb.text = NSLocalizedString(@"时间选择", nil);
        dateTipLb.textColor = RGB(95, 95, 95);
        dateTipLb.font = FONT(16);
        
        UILabel* detailTipLb = [[UILabel alloc]init];
        [headView addSubview:detailTipLb];
        [detailTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(dateTipLb.mas_right).offset(5);
            make.centerY.equalTo(dateTipLb.mas_centerY);
        }];
        detailTipLb.text = NSLocalizedString(@"支持查询最近7天消息", nil);
        detailTipLb.textColor = RGB(95, 95, 95);
        detailTipLb.font = FONT(12);
        
    }
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

#pragma mark -getter&setter
//头部视图
- (UIView *)headView
{
    if (!_headView) {
        _headView = [[UIView alloc]init];
        _headView.backgroundColor = [UIColor whiteColor];
    }
    return _headView;
}
//线条
- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = RGB(200, 200, 200);
    }
    return _line;
}
//标题
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.text = NSLocalizedString(@"消息", nil);
        _titleLb.font = FONT(18);
    }
    return _titleLb;
}

- (UIButton *)closeFilerBtn
{
    if (!_closeFilerBtn) {
        _closeFilerBtn = [[UIButton alloc]init];
        [_closeFilerBtn setBackgroundImage:[UIImage imageNamed:@"closeFiler"] forState:UIControlStateNormal];
        [_closeFilerBtn addTarget:self action:@selector(closeFilerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeFilerBtn;
}

//底部视图
- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = RGB(230, 230, 230);
    }
    return _bottomView;
}
//重置按钮
- (UIButton *)resetBtn
{
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc]init];
        [_resetBtn setTitle:NSLocalizedString(@"重置", nil) forState:UIControlStateNormal];
        _resetBtn.backgroundColor = [UIColor whiteColor];
        [_resetBtn setTitleColor:RGB(0, 0, 0) forState:UIControlStateNormal];
        _resetBtn.layer.cornerRadius = 22.5;
        [_resetBtn.layer setBorderColor:RGB(200, 200, 200).CGColor];
        [_resetBtn.layer setBorderWidth:1.0];
        [_resetBtn addTarget:self action:@selector(resetClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}
//确定按钮
- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        [_submitBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
        _submitBtn.backgroundColor = MAIN_COLOR;
        _submitBtn.layer.cornerRadius = 22.5;
        [_submitBtn addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}
//设备名数组
-(NSMutableArray *)deviceNameArr
{
    if (!_deviceNameArr) {
        _deviceNameArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _deviceNameArr;
}
//星期数组
-(NSArray *)dateArr{
    if (!_dateArr) {
        _dateArr = [NSArray array];
    }
    return _dateArr;
}
@end
