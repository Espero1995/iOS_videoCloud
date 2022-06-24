//
//  FolderTreeCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/15.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "FolderTreeCell.h"

@interface FolderTreeCell()
//文件图标
@property (nonatomic, strong) UIImageView *folderIcon;
//push按钮图标
@property (nonatomic, strong) UIImageView *pushIcon;
@end

@implementation FolderTreeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - UI
- (void)createUI
{
    [self.contentView addSubview:self.folderIcon];
    [self.folderIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.nodeNameLb];
    [self.nodeNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(50);
//        make.right.equalTo(self.contentView.mas_right).offset(-20);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.channelLb];
    [self.channelLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nodeNameLb.mas_right).offset(0);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
//    [self.contentView addSubview:self.pushIcon];
//    [self.pushIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.contentView.mas_right).offset(-15);
//        make.centerY.equalTo(self.contentView.mas_centerY);
//    }];
}


#pragma mark - getters && setters
//文件图标
- (UIImageView *)folderIcon
{
    if (!_folderIcon) {
        _folderIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"folder_node"]];
    }
    return _folderIcon;
}

//push按钮图标
- (UIImageView *)pushIcon
{
    if (!_pushIcon) {
        _pushIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"more"]];
    }
    return _pushIcon;
}

- (UILabel *)nodeNameLb
{
    if (!_nodeNameLb) {
        _nodeNameLb = [[UILabel alloc]init];
    }
    return _nodeNameLb;
}

- (UILabel *)channelLb
{
    if (!_channelLb) {
        _channelLb = [[UILabel alloc]init];
        [_channelLb setFont:[UIFont systemFontOfSize:17]];
    }
    return _channelLb;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
