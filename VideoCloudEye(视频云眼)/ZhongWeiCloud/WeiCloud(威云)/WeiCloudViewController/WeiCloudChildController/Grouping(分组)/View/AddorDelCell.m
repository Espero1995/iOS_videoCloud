//
//  AddorDelCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "AddorDelCell.h"
#import "AddorDelCollectionCell.h"
#define AddorDel_Cell @"AddorDel_Cell"
@interface AddorDelCell ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation AddorDelCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.collectionView];
        self.collectionView.frame = CGRectMake(0, 0, iPhoneWidth, self.contentView.frame.size.height);
    }
    return self;
}


//=========================delegate=========================
#pragma mark ------collectionView代理方法
//有多少个章节（Section），如果省略，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// 每个章节中有多少个单元格（Cell）
//注意：这里返回的是每个章节的单元格数量，当有多个章节时，需要判断 section 参数，返回对应的数量。
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.isMyDevGroup) {
        return self.devModelArr.count;//【我的设备组是没有添加和删除功能的】
    }else{
        return self.devModelArr.count+2;//【添加和删除设备】
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    AddorDelCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AddorDel_Cell forIndexPath:indexPath];
    if (row == self.devModelArr.count) {
        cell.devNameLb.text = NSLocalizedString(@"添加设备", nil);
        [cell.addorDeleteBtn setBackgroundImage:[UIImage imageNamed:@"groupAdd"] forState:UIControlStateNormal];
    }else if (row == self.devModelArr.count+1){
        cell.devNameLb.text = NSLocalizedString(@"删除设备", nil);
        [cell.addorDeleteBtn setBackgroundImage:[UIImage imageNamed:@"groupDown"] forState:UIControlStateNormal];
    }else{
        cell.devNameLb.text = ((dev_list *)self.devModelArr[row]).name;
        [cell.addorDeleteBtn setBackgroundImage:[UIImage imageNamed:@"img1"] forState:UIControlStateNormal];
    }
    
    [self updateCollectionViewHeight:self.collectionView.collectionViewLayout.collectionViewContentSize.height];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row == self.devModelArr.count) {//添加设备
        if (self.delegate && [self.delegate respondsToSelector:@selector(addDevClick)]) {
            [self.delegate addDevClick];
        }
    }
    if (row == self.devModelArr.count+1) {//移除设备
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteDevClick)]) {
            [self.delegate deleteDevClick];
        }
    }
}

- (void)updateCollectionViewHeight:(CGFloat)height {
    self.collectionView.frame = CGRectMake(0, 0, self.collectionView.frame.size.width, height);
}


#pragma mark ====== init ======
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        CGFloat width = (iPhoneWidth - 30)/3.f;
        layout.itemSize = CGSizeMake(width, width*13/23+20);
        layout.sectionInset = UIEdgeInsetsMake(10, 5, 5, 5);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[AddorDelCollectionCell class] forCellWithReuseIdentifier:AddorDel_Cell];
        _collectionView.backgroundColor = BG_COLOR;
    }
    return _collectionView;
}


- (void)setDevModelArr:(NSArray *)devModelArr {
    _devModelArr = devModelArr;
    [self.collectionView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
