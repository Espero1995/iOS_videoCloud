//
//  SettingCellThree_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SettingCellThree_t.h"

@implementation SettingCellThree_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    
    //删除设备
    _deleteLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 70, 16) text:_deleteLabel.text font:[UIFont systemFontOfSize:17]];
    _deleteLabel.textColor = [UIColor colorWithHexString:@"000000"];
    [self.contentView addSubview:_deleteLabel];
    
    [self.deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
