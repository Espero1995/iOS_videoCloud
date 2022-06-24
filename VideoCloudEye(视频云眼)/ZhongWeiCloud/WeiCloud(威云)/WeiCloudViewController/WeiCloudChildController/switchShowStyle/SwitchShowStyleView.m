//
//  SwitchShowStyleView.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/19.
//  Copyright © 2018年 张策. All rights reserved.
//
#define switchShowBtn_bgView_Height 50
#define cellHeight 50
#define switchShowStyleView_height (iPhone_X_?188:170)
#import "SwitchShowStyleView.h"
#import "GroupDevCell.h"
#import "groupModel.h"
@interface SwitchShowStyleView ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    GroupDevCellDelegate
>
@property (nonatomic,strong) UITableView *tv_list;//存放分组
@property (nonatomic,strong) NSMutableArray *groupArr;
@end


@implementation SwitchShowStyleView

- (instancetype)initWithFrame:(CGRect)frame GroupData:(NSMutableArray *)data
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self createUI];
        [self changeSwitchShowFrameandData:data];
        //self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}
/*
- (void)createUI
{
    //[self setFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight / 3)];
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.switchShowStyle_bgView];
    [self.switchShowStyle_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.switchShowStyle_bgView addSubview:self.switchShowBtn_bgView];
    [self.switchShowBtn_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.switchShowStyle_bgView);
        make.bottom.mas_equalTo(self.switchShowStyle_bgView.mas_bottom);
        make.height.mas_equalTo(switchShowBtn_bgView_Height);
    }];
    [self.switchShowStyle_bgView addSubview:self.addGroupBtn];
    self.addGroupBtn.backgroundColor = [UIColor yellowColor];
    [self.addGroupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.switchShowStyle_bgView);
        make.bottom.mas_equalTo(self.switchShowBtn_bgView.mas_top);
        make.height.mas_equalTo(switchShowBtn_bgView_Height);
    }];

    self.addGroupBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - self.addGroupBtn.currentImage.size.width+20, 0, 0);
    self.addGroupBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    [self.switchShowStyle_bgView addSubview:self.line1_horizontal];
    [self.line1_horizontal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.switchShowStyle_bgView);
        make.left.mas_equalTo(self.switchShowBtn_bgView.mas_left).offset(20);
        make.height.mas_equalTo(@0.5);
        make.bottom.mas_equalTo(self.addGroupBtn.mas_top).offset(-0.5);
    }];
    
    [self.switchShowBtn_bgView addSubview:self.littleMode];
    [self.littleMode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.switchShowBtn_bgView.mas_left);
        make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
        make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3)-1, switchShowBtn_bgView_Height));
    }];
   // NSLog(@"switchShowStyle_bgView：%@==switchShowBtn_bgView：%@==self:%@",_switchShowStyle_bgView,_switchShowBtn_bgView,self);
    [self.switchShowBtn_bgView addSubview:self.largeMode];
    [self.largeMode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.littleMode.mas_right);
        make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
        make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3), switchShowBtn_bgView_Height));
    }];
    
    [self.switchShowBtn_bgView addSubview:self.fourScreenMode];
    [self.fourScreenMode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.switchShowBtn_bgView.mas_right);
        make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
        make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3)-1, switchShowBtn_bgView_Height));
    }];
    
    [self.switchShowBtn_bgView addSubview:self.line1_vertical];
    [self.line1_vertical mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.littleMode.mas_right);
        make.centerY.mas_equalTo(self.switchShowBtn_bgView);
        make.height.mas_equalTo(switchShowBtn_bgView_Height /3);
        make.width.mas_equalTo(@1);
    }];
    
    [self.switchShowBtn_bgView addSubview:self.line2_vertical];
    [self.line2_vertical mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.largeMode.mas_right);
        make.centerY.mas_equalTo(self.switchShowBtn_bgView);
        make.height.mas_equalTo(switchShowBtn_bgView_Height /3);
        make.width.mas_equalTo(@1);
    }];
    
    [self.switchShowStyle_bgView addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.switchShowStyle_bgView).offset(15);
        if (iPhone_X_TO_Xs) {
            make.top.mas_equalTo(self.switchShowStyle_bgView).offset(50);
        }else{
            make.top.mas_equalTo(self.switchShowStyle_bgView).offset(30);
        }
    }];
}
*/
- (void)updateUIAfterGroupCreatedGroupData:(NSMutableArray *)data
{
    self.groupArr = [data mutableCopy];
    if (self.groupArr.count <= 5) {
        self.frame = CGRectMake(0, 0, iPhoneWidth, switchShowStyleView_height + 50 * self.groupArr.count);
    }else{
        self.frame = CGRectMake(0, 0, iPhoneWidth, switchShowStyleView_height + 50 * 5);
    }
    [self.switchShowStyle_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(self);
        make.left.right.equalTo(self);
        //make.bottom.equalTo(self.mas_bottom);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(self.frame.size.height);
    }];
  //  self.switchShowStyle_bgView.backgroundColor = [UIColor blueColor];
//    CGRect selfFrame = self.frame;
//    [self.switchShowStyle_bgView setFrame:selfFrame];
//
    [self.switchShowBtn_bgView  mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.switchShowStyle_bgView);
        make.bottom.mas_equalTo(self.switchShowStyle_bgView.mas_bottom);
        make.height.mas_equalTo(switchShowBtn_bgView_Height);
    }];
    
    [self.addGroupBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.switchShowStyle_bgView);
        make.bottom.mas_equalTo(self.switchShowBtn_bgView.mas_top);
        make.height.mas_equalTo(switchShowBtn_bgView_Height);
    }];
    
    [self.switchShowStyle_bgView addSubview:self.tv_list];
    [self.tv_list mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.switchShowStyle_bgView.mas_centerX);
        make.top.equalTo(self.closeBtn.mas_bottom).offset(7);
        if (self.groupArr.count <= 5) {
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth, self.groupArr.count*cellHeight));
        }else{
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 5*cellHeight));//超过五个就显示五个其他采用滚动展示
        }
    }];
    [self.tv_list reloadData];
    if (self.groupArr.count > 0) {
        //每次到跳到第一行
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tv_list scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}
 
- (void)changeSwitchShowFrameandData:(NSMutableArray *)dataArr
{
    self.groupArr = [dataArr mutableCopy];
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.switchShowStyle_bgView];
    [self.switchShowStyle_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    [self.switchShowStyle_bgView addSubview:self.switchShowBtn_bgView];
    [self.switchShowBtn_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.switchShowStyle_bgView);
        make.bottom.equalTo(self.switchShowStyle_bgView.mas_bottom);
        make.height.mas_equalTo(switchShowBtn_bgView_Height);
    }];
    [self.switchShowStyle_bgView addSubview:self.addGroupBtn];
    [self.addGroupBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.switchShowStyle_bgView);
        make.bottom.equalTo(self.switchShowBtn_bgView.mas_top);
        make.height.mas_equalTo(switchShowBtn_bgView_Height);
    }];
    
    self.addGroupBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - self.addGroupBtn.currentImage.size.width+20, 0, 0);
    self.addGroupBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [self.switchShowStyle_bgView addSubview:self.line1_horizontal];
    [self.line1_horizontal mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.switchShowStyle_bgView);
        make.left.mas_equalTo(self.switchShowBtn_bgView.mas_left).offset(20);
        make.height.mas_equalTo(@0.5);
        make.bottom.mas_equalTo(self.addGroupBtn.mas_top).offset(-0.5);
    }];
    
    [self.switchShowBtn_bgView addSubview:self.littleMode];
    [self.littleMode mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.switchShowBtn_bgView.mas_left);
        make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
        make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3)-1, switchShowBtn_bgView_Height));
    }];
    [self.switchShowBtn_bgView addSubview:self.largeMode];
    [self.largeMode mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.littleMode.mas_right);
        make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
        make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3), switchShowBtn_bgView_Height));
    }];
    
    [self.switchShowBtn_bgView addSubview:self.fourScreenMode];
    [self.fourScreenMode mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.switchShowBtn_bgView.mas_right);
        make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
        make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3)-1, switchShowBtn_bgView_Height));
    }];
    
    [self.switchShowBtn_bgView addSubview:self.line1_vertical];
    [self.line1_vertical mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.littleMode.mas_right);
        make.centerY.mas_equalTo(self.switchShowBtn_bgView);
        make.height.mas_equalTo(switchShowBtn_bgView_Height /3);
        make.width.mas_equalTo(@1);
    }];
    
    [self.switchShowBtn_bgView addSubview:self.line2_vertical];
    [self.line2_vertical mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.largeMode.mas_right);
        make.centerY.mas_equalTo(self.switchShowBtn_bgView);
        make.height.mas_equalTo(switchShowBtn_bgView_Height /3);
        make.width.mas_equalTo(@1);
    }];
    
    [self.switchShowStyle_bgView addSubview:self.closeBtn];
    [self.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.switchShowStyle_bgView).offset(15);
        if (iPhone_X_) {
            make.top.mas_equalTo(self.switchShowStyle_bgView).offset(50);
        }else{
            make.top.mas_equalTo(self.switchShowStyle_bgView).offset(30);
        }
    }];
    
    [self.switchShowStyle_bgView addSubview:self.tv_list];
    [self.tv_list mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.switchShowStyle_bgView.mas_centerX);
        make.top.equalTo(self.closeBtn.mas_bottom).offset(7);
        if (self.groupArr.count <= 5) {
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth, self.groupArr.count*cellHeight));
        }else{
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 5*cellHeight));//超过五个就显示五个其他采用滚动展示
        }
    }];
    [self.tv_list reloadData];
    if (self.groupArr.count > 0) {
        //每次到跳到第一行
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tv_list scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark === Action
- (void)SwitchShowStyleBtnClick:(UIButton*)btn
{
    if (self.delegate && [self respondsToSelector:@selector(SwitchShowStyleBtnClick:)]) {
        [self.delegate SwitchShowStyleBtnClick:btn];
    }
}

//==========================delegate==========================
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupArr.count;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}
//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    static NSString* GroupDevCell_Identifier = @"GroupDevCell_Identifier";
    GroupDevCell* cell = [tableView dequeueReusableCellWithIdentifier:GroupDevCell_Identifier];
    if(!cell){
        cell = [[GroupDevCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupDevCell_Identifier];
    }
    
    cell.delegate = self;
    groupModel *model = self.groupArr[row];
    
    cell.titleLb.text = model.groupName;
    
    if (row == [unitl getCurrentDisplayGroupIndex]) {
        cell.titleLb.textColor = MAIN_COLOR;
    }else{
        cell.titleLb.textColor = RGB(50, 50, 50);
    }
    return cell;
}

//点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self respondsToSelector:@selector(GroupSettingClick:)]) {
        [self.delegate SwitchGroupClick:indexPath.row];
    }
}

//设置按钮的点击事件
- (void)GroupSettingClick:(GroupDevCell *)cell
{
    NSIndexPath * indexPath = [self.tv_list indexPathForCell:cell];
    if (self.delegate && [self respondsToSelector:@selector(GroupSettingClick:)]) {
        [self.delegate GroupSettingClick:indexPath.row];
    }
}

#pragma mark === getter && setter
- (UIView *)switchShowStyle_bgView//self上面的一层背景view
{
    if (!_switchShowStyle_bgView) {
        _switchShowStyle_bgView = [[UIView alloc]initWithFrame:CGRectZero];
        //_switchShowStyle_bgView.backgroundColor = [UIColor redColor];
    }
    return _switchShowStyle_bgView;
}

- (UIView *)switchShowBtn_bgView
{
    if (!_switchShowBtn_bgView) {
        _switchShowBtn_bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _switchShowBtn_bgView.backgroundColor = [UIColor colorWithHexString:@"#EEEFF3"];
    }
    return _switchShowBtn_bgView;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.tag = TAG_CLOSEBTN;
        [_closeBtn setImage:[UIImage imageNamed:@"close_three"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)addGroupBtn
{
    if (!_addGroupBtn) {
        _addGroupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addGroupBtn.tag = TAG_ADDGROUPBTN;
        [_addGroupBtn setImage:[UIImage imageNamed:@"up_group"] forState:UIControlStateNormal];
        [_addGroupBtn setTitle:NSLocalizedString(@"添加分组", nil) forState:UIControlStateNormal];
        [_addGroupBtn setTitleColor:RGB(108, 108, 108) forState:UIControlStateNormal];
        _addGroupBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_addGroupBtn addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addGroupBtn;
}

- (UIButton *)littleMode
{
    if (!_littleMode) {
        _littleMode = [UIButton buttonWithType:UIButtonTypeCustom];
        _littleMode.tag = TAG_LITTLEMODE;
        if ([unitl CameraListDisplayMode] == CameraListDisplayMode_littleMode) {
            _littleMode.selected = YES;
        }
        [_littleMode setImage:[UIImage imageNamed:@"list_n"] forState:UIControlStateNormal];
        [_littleMode setImage:[UIImage imageNamed:@"list_h"] forState:UIControlStateSelected];
        [_littleMode addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _littleMode;
}

- (UIButton *)largeMode
{
    if (!_largeMode) {
        _largeMode = [UIButton buttonWithType:UIButtonTypeCustom];
        _largeMode.tag = TAG_LARGEMODE;
        if ([unitl CameraListDisplayMode] == CameraListDisplayMode_largeMode) {
            _largeMode.selected = YES;
        }
        [_largeMode setImage:[UIImage imageNamed:@"big_n"] forState:UIControlStateNormal];
        [_largeMode setImage:[UIImage imageNamed:@"big_h"] forState:UIControlStateSelected];
        [_largeMode addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _largeMode;
}

- (UIButton *)fourScreenMode
{
    if (!_fourScreenMode) {
        _fourScreenMode = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([unitl CameraListDisplayMode] == CameraListDisplayMode_fourScreenMode) {
            _fourScreenMode.selected = YES;
        }
        _fourScreenMode.tag = TAG_FOURSCREENMODE;
        [_fourScreenMode setImage:[UIImage imageNamed:@"gouped_n"] forState:UIControlStateNormal];
        [_fourScreenMode setImage:[UIImage imageNamed:@"gouped_h"] forState:UIControlStateSelected];
        [_fourScreenMode addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fourScreenMode;
}

- (UIView *)line1_vertical
{
    if (!_line1_vertical) {
        _line1_vertical = [[UIView alloc]initWithFrame:CGRectZero];
        _line1_vertical.backgroundColor = [UIColor lightGrayColor];
    }
    return _line1_vertical;
}

- (UIView *)line2_vertical
{
    if (!_line2_vertical) {
        _line2_vertical = [[UIView alloc]initWithFrame:CGRectZero];
        _line2_vertical.backgroundColor = [UIColor lightGrayColor];
    }
    return _line2_vertical;
}

- (UIView *)line1_horizontal
{
    if (!_line1_horizontal) {
        _line1_horizontal = [[UIView alloc]initWithFrame:CGRectZero];
        _line1_horizontal.backgroundColor = RGB(220, 220, 220);
        _line1_horizontal.hidden = YES;
    }
    return _line1_horizontal;
}
//表视图
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tv_list.showsVerticalScrollIndicator = NO;
    }
    return _tv_list;
}
- (NSMutableArray *)groupArr
{
    if (!_groupArr) {
        _groupArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupArr;
}

@end
