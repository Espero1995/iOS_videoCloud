//
//  AlarmCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/16.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "AlarmCell_t.h"
#import "FactoryUI.h"
@implementation AlarmCell_t

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    
    self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    //顶部视图
    _topView = [FactoryUI createViewWithFrame:CGRectMake(0, 0, iPhoneWidth, 20)];
    _topView.backgroundColor = [UIColor colorWithHexString:@"#f4f3f3"];
    [self.contentView addSubview:_topView];
    //线
    
    _lineView1 = [FactoryUI createViewWithFrame:CGRectMake(0,0, self.bounds.size.width+100, 0.5)];
    _lineView1.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
    [self.contentView addSubview:_lineView1];
    
    _lineView2 = [FactoryUI createViewWithFrame:CGRectMake(0,20, self.bounds.size.width+100, 0.5)];
    _lineView2.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
    [self.topView addSubview:_lineView2];
    
    
    //时间
    _timeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, iPhoneWidth, 9) text:nil font:[UIFont systemFontOfSize:9]];
    _timeLabel.textColor = [UIColor colorWithHexString:@"a5a5a5"];
    _timeLabel.numberOfLines = 0;
    _timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.topView addSubview:_timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView.mas_left).offset(15);
        make.top.equalTo(self.topView.mas_top).offset(5.5);
    }];
    
    //选择按钮
    _chooseBtn = [FactoryUI createButtonWithFrame:CGRectMake(13, 53, 18, 18) title:nil titleColor:nil imageName:nil backgroundImageName:@"unselect" target:self selector:nil];
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    _chooseBtn.enabled = NO;
    _chooseBtn.alpha = 0;
    [_chooseBtn addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_chooseBtn];
    
    
    //警报信息类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 300, 15) text:nil font:[UIFont systemFontOfSize:14]];
    _typeLabel.textColor = [UIColor colorWithHexString:@"000000"];
    _typeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _typeLabel.numberOfLines = 0;
    [self.contentView addSubview:_typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(35);
        make.top.equalTo (self.contentView.mas_top).offset(45);
    }];
    
    //红点
    _attentionView = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:nil];
    _attentionView.image = [UIImage imageNamed:@"sign"];
    _attentionView.alpha = 0;
    [self.contentView addSubview:_attentionView];
    
    [self.attentionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeLabel.mas_right).offset(5);
        make.top.equalTo(self.typeLabel.mas_top).offset(9);
    }];
    

    
    //警报来源
    _messageLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 200, 9) text:nil font:[UIFont systemFontOfSize:9]];
    _messageLabel.textColor = [UIColor colorWithHexString:@"959595"];
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.numberOfLines = 0;
    [self.contentView addSubview:_messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(35);
        make.top.equalTo(self.typeLabel.mas_bottom).offset(12);
    }];
    
    //监控图片
    _pictureImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 105, 78) imageName:nil];
    _pictureImage.userInteractionEnabled = YES;
    [self.contentView addSubview:_pictureImage];
    [self.pictureImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-13);
        make.top.equalTo(self.contentView.mas_top).offset(32);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-12);
//        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_right).offset(-118);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoDetail:)];
    //将手势添加到每个imageview上
    [_pictureImage addGestureRecognizer:tap];
    
}
- (void)setModel:(PushMsgModel *)model{


}
//选择删除按钮点击事件
- (void)deleteCell:(AlarmCell_t *)cell
{
    if (self.delegete && [self.delegete respondsToSelector:@selector(AlarmCell_tChooseBtnClick:)]) {
        [self.delegete AlarmCell_tChooseBtnClick:self];
    }
}
- (void)photoDetail:(AlarmCell_t *)cell{

    if (self.detaSore && [self.detaSore respondsToSelector:@selector(Alarmcell_tPictureImageClick:)]) {
        [self.detaSore Alarmcell_tPictureImageClick:self];
    }
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
