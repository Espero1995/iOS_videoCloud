//
//  definePageWidthRoundSc.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/9/3.
//  Copyright © 2018年 张策. All rights reserved.
//
#define KMargin_sc 80
#define groupBtnEdge (iPhoneWidth - 2 * KMargin_sc - 3 * groupBtnWidth)/4
#define groupBetweenEdge  2*groupBtnEdge + 10
#define groupBtnWidth  (iPhone_5_Series?53:60)
#define groupBtnHeight (iPhone_5_Series?53:60)
#import "definePageWidthRoundSc.h"

@implementation definePageWidthRoundSc

-(instancetype)initWithFrame:(CGRect)frame
                GroupNameArr:(NSMutableArray *)groupNameArr
                  GroupIDArr:(NSMutableArray *)groupIDArr
            GroupBtnLabelArr:(NSMutableArray *)groupBtnLabelArr
                 GroupBtnArr:(NSMutableArray *)groupBtnArr
{
    self=[super initWithFrame:frame];
    if (self) {
        if (groupNameArr) {
            self.groupNameArr = groupNameArr;
            self.groupIDArr = groupIDArr;
            self.groupBtnLabelArr = groupBtnLabelArr;
            self.groupBtnArr = groupBtnArr;
        }else
        {
            NSString * GroupNameAndIDArr_KeyStr = [unitl getKeyWithSuffix:[unitl get_User_id] Key:GroupNameAndIDArr_key];
            NSMutableArray * groupNameAndIDArr = [NSMutableArray arrayWithCapacity:0];
            groupNameAndIDArr = [unitl getDataWithKey:GroupNameAndIDArr_KeyStr];
            if (groupNameAndIDArr) {
                for (int i = 0; i<groupNameAndIDArr.count; i++) {
                    [self.groupNameArr addObject:groupNameAndIDArr[i][@"groupName"]];
                    [self.groupIDArr  addObject:groupNameAndIDArr[i][@"groupID"]];
                }
            }
        }
        self.navCurrentHeight = frame.size.height;

      //  self.backgroundColor = [UIColor yellowColor];
        //添加ScrollView
        [self addScrollView];
        //添加分组btn
        [self addGroupBtn];
    }
    return self;
}

- (void)setScContentSize:(CGSize)scContentSize
{
    self.sc.contentSize = scContentSize;
}
- (void)setScContentOffset:(CGPoint)scContentOffset
{
    self.sc.contentOffset = scContentOffset;
}
#pragma mark---添加ScrollView
-(void)addScrollView
{
    [self addSubview:self.sc];
}
#pragma mark---添加分组btn
-(void)addGroupBtn
{
    for (UIView * subView in [self.sc subviews]) {
        [subView removeFromSuperview];
    }
    [self.groupBtnArr removeAllObjects];
    [self.groupBtnLabelArr removeAllObjects];
    
    //获取所有组别
    NSArray *allGroup = [[unitl getAllGroupCameraModel] copy];
    
    for (int i = 0; i < self.groupNameArr.count; i++) {
        UIButton * groupBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        [groupBtn setFrame:CGRectMake(groupBtnEdge + i * (groupBtnWidth + groupBtnEdge) , (self.navCurrentHeight - 4/3 *groupBtnHeight)/2 , groupBtnWidth, groupBtnHeight)];
        groupBtn.tag = groupBtnTag + i;
        deviceGroup *tempGroupModel = allGroup[i];
        
        //其他组的状态
        if ([tempGroupModel.enableSensibility intValue] == 1) {
            [groupBtn setImage:[UIImage imageNamed:@"unselected_protected"] forState:UIControlStateNormal];
        }else{
            [groupBtn setImage:[UIImage imageNamed:@"unselected_Unprotected"] forState:UIControlStateNormal];
        }
        
        [groupBtn addTarget:self action:@selector(groupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.sc addSubview:groupBtn];
        [self.groupBtnArr addObject:groupBtn];
        
        UILabel * groupBtnLabel = [[UILabel alloc]init];
        [self.sc addSubview:groupBtnLabel];
        [groupBtnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(groupBtn.mas_centerX);
            make.top.mas_equalTo(groupBtn.mas_bottom).offset(5);
            make.width.mas_equalTo(groupBtnWidth);
        }];
        groupBtnLabel.textAlignment = NSTextAlignmentCenter;
        groupBtnLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        groupBtnLabel.adjustsFontForContentSizeCategory = YES;
        groupBtnLabel.tag = groupBtnLabelTag + i;
        groupBtnLabel.text = [NSString stringWithFormat:@"%@",self.groupNameArr[i]];
        [groupBtnLabel setFont:[UIFont boldSystemFontOfSize:FitWidth(14)]];
        [groupBtnLabel setTextColor:COLOR_TEXT];
        [self.groupBtnLabelArr addObject:groupBtnLabel];
    }
    
    
    NSInteger currentIndex = [unitl getCurrentDisplayGroupIndex];
    if (currentIndex == 0) {
        if (self.groupBtnArr.count > 0 && self.groupBtnLabelArr.count > 0) {
            deviceGroup *tempGroupModel = allGroup[0];
            //其他组的状态
            if ([tempGroupModel.enableSensibility intValue] == 1) {
                [self.groupBtnArr[0] setImage:[UIImage imageNamed:@"selected_Protected"] forState:UIControlStateNormal];
            }else{
                [self.groupBtnArr[0] setImage:[UIImage imageNamed:@"selected_Unprotected"] forState:UIControlStateNormal];
            }
//            [self.groupBtnArr[0] setImage:[UIImage imageNamed:@"selected_Unprotected"] forState:UIControlStateNormal];
            [self.groupBtnLabelArr[0] setTextColor:MAIN_COLOR];
        }
    }else
    {
        if (self.groupBtnArr.count > 0 && self.groupBtnLabelArr.count > 0) {
            
            if (currentIndex >= allGroup.count || currentIndex >= self.groupBtnArr.count ) {
                currentIndex = 0;
                [unitl saveCurrentDisplayGroupIndex:currentIndex];
            }
            deviceGroup *tempGroupModel = allGroup[currentIndex];
            //其他组的状态
            if ([tempGroupModel.enableSensibility intValue] == 1) {
                [self.groupBtnArr[currentIndex] setImage:[UIImage imageNamed:@"selected_Protected"] forState:UIControlStateNormal];
            }else{
                [self.groupBtnArr[currentIndex] setImage:[UIImage imageNamed:@"selected_Unprotected"] forState:UIControlStateNormal];
            }
            
//            [self.groupBtnArr[currentIndex] setImage:[UIImage imageNamed:@"selected_Unprotected"] forState:UIControlStateNormal];
            [self.groupBtnLabelArr[currentIndex] setTextColor:MAIN_COLOR];
        }
    }
    if (self.groupBtnArr.count < 3) {
        [UIView animateWithDuration:0.2 animations:^{
            [self setScContentOffset:CGPointMake(-(groupBtnEdge + groupBtnWidth) ,0)];
        }];
    }
}

- (void)changeBtnAndTitleFrameAnimationIsUp:(BOOL)isUp
{
    if (isUp) {
        for (int i = 0; i < self.groupBtnArr.count; i++) {
            UIButton * btn = self.groupBtnArr[i];
            [btn setFrame:CGRectMake(groupBtnEdge + i * (groupBtnWidth + groupBtnEdge) +  groupBtnWidth/2 , (self.navCurrentHeight - 4/3 *groupBtnHeight)/2 , 0, 0)];
            UILabel * label = self.groupBtnLabelArr[i];
            [label setFrame:CGRectMake(groupBtnEdge + i * (groupBtnWidth + groupBtnEdge) + groupBtnWidth/2 , (self.navCurrentHeight - 4/3 *groupBtnHeight)/2 , groupBtnWidth, groupBtnHeight)];
        }
    }else
    {
        for (int i = 0; i <self.groupBtnArr.count; i++) {
            UIButton * btn = self.groupBtnArr[i];
            [btn setFrame:CGRectMake(groupBtnEdge + i * (groupBtnWidth + groupBtnEdge)+ 1/2 * groupBtnWidth , (self.navCurrentHeight - 4/3 *groupBtnHeight)/2 , groupBtnWidth, groupBtnHeight)];
            UILabel * label = self.groupBtnLabelArr[i];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(btn.mas_centerX);
                make.top.mas_equalTo(btn.mas_bottom).offset(5);
                make.width.mas_equalTo(groupBtnWidth);
            }];
        }
    }
}


//组别创建成功之后，更新组别btn
- (void)CreateGroupSuccess
{
    [self.groupNameArr removeAllObjects];
    [self.groupIDArr removeAllObjects];
    NSMutableArray * groupNameAndIDArr = [NSMutableArray arrayWithCapacity:0];
    groupNameAndIDArr = [unitl getGroupNameAndIDArr];
    if (groupNameAndIDArr) {
        for (int i = 0; i<groupNameAndIDArr.count; i++) {
            [self.groupNameArr addObject:groupNameAndIDArr[i][@"groupName"]];
            [self.groupIDArr  addObject:groupNameAndIDArr[i][@"groupID"]];
        }
        [self setScContentSize:CGSizeMake(self.groupNameArr.count * groupBtnWidth + (self.groupNameArr.count + 1)*groupBtnEdge, self.navCurrentHeight)];
    }
    [self addGroupBtn];
    NSString * nav_Status = [unitl getDataWithKey:NAV_Status];
    if ([nav_Status isEqualToString:@"NAV_Status_UP"]) {
        [self changeBtnAndTitleFrameAnimationIsUp:YES];
    }else
    {
        [self changeBtnAndTitleFrameAnimationIsUp:NO];
    }
}

//分组btn的点击方法
- (void)groupBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupBtnClick:)]) {
        [self.delegate groupBtnClick:btn];
    }
}

#pragma mark---修改hitTest方法
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isEqual:self]){
        for (UIView *subview in _sc.subviews){
            CGPoint offset = CGPointMake(point.x - _sc.frame.origin.x + _sc.contentOffset.x - subview.frame.origin.x, point.y - _sc.frame.origin.y + _sc.contentOffset.y - subview.frame.origin.y);
            
            if ((view = [subview hitTest:offset withEvent:event])){
                return view;
            }
        }
        return _sc;
    }
    return view;
}


#pragma mark - getter && setter

- (UIScrollView *)sc
{
    if (!_sc) {
        _sc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth - 2*KMargin_sc, self.navCurrentHeight)];
        _sc.contentSize = CGSizeMake(self.groupNameArr.count * groupBtnWidth + (self.groupNameArr.count + 1)*groupBtnEdge, self.navCurrentHeight);
        _sc.showsHorizontalScrollIndicator = NO;
        //_sc.pagingEnabled=YES;
        //_sc.clipsToBounds=NO;
        _sc.bounces=NO;
        //_sc.backgroundColor = [UIColor redColor];
    }
    return _sc;
}

- (NSMutableArray *)groupNameArr
{
    if (!_groupNameArr) {
        _groupNameArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupNameArr;
}

- (NSMutableArray *)groupIDArr
{
    if (!_groupIDArr) {
        _groupIDArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupIDArr;
}

- (NSMutableArray *)groupBtnArr
{
    if (!_groupBtnArr) {
        _groupBtnArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupBtnArr;
}

- (NSMutableArray *)groupBtnLabelArr
{
    if (!_groupBtnLabelArr) {
        _groupBtnLabelArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupBtnLabelArr;
}

@end
