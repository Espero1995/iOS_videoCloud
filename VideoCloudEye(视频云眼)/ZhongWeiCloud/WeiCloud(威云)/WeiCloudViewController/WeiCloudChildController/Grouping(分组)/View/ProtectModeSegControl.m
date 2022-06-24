//
//  ProtectModeSegControl.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ProtectModeSegControl.h"
#import "UIButton+HDExtension.h"
@interface ProtectModeSegControl ()
{
    NSArray *_titlesArray;//标题数组
}
@property (nonatomic, assign)NSInteger radius;//圆角半径
@end

@implementation ProtectModeSegControl

+(instancetype)creatSegmentedControlWithTitle:(NSArray *)titleArs {
    ProtectModeSegControl *segmented = [[ProtectModeSegControl alloc]init];
    segmented.radius = 4;
    [segmented initSetsWithTitleArs:titleArs];
    return segmented;
}

+(instancetype)creatSegmentedControlWithTitle:(NSArray *)titleArs withRadius:(NSInteger)radius{
    ProtectModeSegControl *segmented = [[ProtectModeSegControl alloc]init];
    segmented.radius = radius;
    [segmented initSetsWithTitleArs:titleArs];
    return segmented;
}



- (void)initSetsWithTitleArs:(NSArray *)titles{
    self.backgroundColor = MAIN_COLOR;
    self.layer.cornerRadius = self.radius;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = MAIN_COLOR.CGColor;
    self.layer.borderWidth = 1;
    _titlesArray = titles;
    [self creatBtnWithTitles:_titlesArray];
}

- (void)creatBtnWithTitles:(NSArray *)titles{
    NSInteger count = titles.count;
    for (int index = 0; index < titles.count ; index++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[index] forState:UIControlStateNormal];
        btn.titleLabel.font = FONT(16);
        //按钮字体颜色
        [btn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];//正常
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];//高亮
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];//被选中
        [btn setTitleColor:[UIColor whiteColor] forState: UIControlStateSelected | UIControlStateHighlighted];//被选中且高亮
       
        //按钮背景颜色
        [btn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];//正常
        [btn setBackgroundColor:MAIN_COLOR forState:UIControlStateHighlighted];//高亮
        [btn setBackgroundColor:MAIN_COLOR forState:UIControlStateSelected];//被选中
        [btn setBackgroundColor:RGB(180, 180, 180) forState: UIControlStateSelected | UIControlStateHighlighted];//被选中且高亮(故意置灰能显示有点中的效果)
        
        if (index == 0) {
            //按钮图片（房子）
            [btn setImage:[UIImage imageNamed:@"groupHouse_n"] forState:UIControlStateNormal];//正常
            [btn setImage:[UIImage imageNamed:@"groupHouse_h"] forState:UIControlStateHighlighted];//高亮
            [btn setImage:[UIImage imageNamed:@"groupHouse_h"] forState:UIControlStateSelected];//被选中
            [btn setImage:[UIImage imageNamed:@"groupHouse_h"] forState:UIControlStateSelected | UIControlStateHighlighted];//被选中且高亮
        }else{
            //按钮图片（人）
            [btn setImage:[UIImage imageNamed:@"groupPerson_n"] forState:UIControlStateNormal];//正常
            [btn setImage:[UIImage imageNamed:@"groupPerson_h"] forState:UIControlStateHighlighted];//高亮
            [btn setImage:[UIImage imageNamed:@"groupPerson_h"] forState:UIControlStateSelected];//被选中
            [btn setImage:[UIImage imageNamed:@"groupPerson_h"] forState:UIControlStateSelected | UIControlStateHighlighted];//被选中且高亮
        }
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.currentImage.size.width+30, 0, 0);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.tag = index + 10;
        [self addSubview:btn];
        if (index == 0) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(self);
            make.width.equalTo(self).dividedBy(count);
            [self isFirstByIndex:index]? make.leading.equalTo(self.mas_leading):make.leading.equalTo([self returnOneBtn:index].mas_trailing).offset(1);
        }];
    }
}

/**
 *  判段是否是第一个button 如果是第一个那么其左边是和 self 的左边相等的 如果不是第一个那么其左边是和上一个 button 的右边相等的(也可以有间距 根据需求)
 button的宽度是根据 self 的宽 除以数组的长度 这样就等分
 *
 *  @param index index description
 *
 *  @return return value description
 */

- (BOOL)isFirstByIndex:(NSInteger)index{
    if (index == 0) {
        return YES;
    }
    return NO;
}

/**
 *  取出前一个btn
 *
 *  @param index index description
 *
 *  @return return value description
 */
- (UIButton *)returnOneBtn:(NSInteger)index{
    NSInteger last = index + 10 - 1;
    UIButton *btn = [self viewWithTag:last];
    return btn;
}

- (NSArray *)tagsArray{
    NSMutableArray *muA = [NSMutableArray arrayWithCapacity:_titlesArray.count];
    for (NSInteger index = 0; index < _titlesArray.count; index ++) {
        NSInteger tag = index + 10;
        [muA addObject:@(tag)];
    }
    return muA.copy;
}


- (void)btnClicked:(UIButton *)btn{
    NSInteger tag = btn.tag;
    btn.selected = YES;
    for (NSNumber *nub in [self tagsArray]) {
        if (tag != nub.integerValue) {
            UIButton *btn = [self viewWithTag:nub.integerValue];
            btn.selected = NO;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectSegmentWithIndex:)]) {
        [_delegate didSelectSegmentWithIndex:tag - 10];
    }
}


- (void)updateSelectedIndexToFirst{
    UIButton *btn = [self viewWithTag:10];
    [self btnClicked:btn];
}

- (void)updateSelectedWithIndex:(NSInteger)index{
    UIButton *btn = [self viewWithTag:index + 10];
    [self btnClicked:btn];
}


@end
