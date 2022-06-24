//
//  AlarmNewCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/12.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "AlarmNewCell.h"
#import "UIImage+image.h"
@interface AlarmNewCell ()

@end

@implementation AlarmNewCell
//========================init========================
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI
{
//    self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    //正文内容视图
    _mainbodyView = [FactoryUI createViewWithFrame:CGRectMake(0, 30, iPhoneWidth, 90)];
    _mainbodyView.backgroundColor = [UIColor clearColor];//RGB(255, 255, 255);
    [self.contentView addSubview:_mainbodyView];
    [_mainbodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 90));
    }];
    
    //选择按钮
    _chooseBtn = [[UIButton alloc]initWithFrame:CGRectMake(9, (90-18)/2, 18, 18)];
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"select_n"] forState:UIControlStateNormal];
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"select_h"] forState:UIControlStateSelected];
//    _chooseBtn.enabled = NO;
    _chooseBtn.alpha = 0;
    [_chooseBtn addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainbodyView addSubview:_chooseBtn];
    
    //监控图片
    _pictureImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    _pictureImage.userInteractionEnabled = YES;
    _pictureImage.layer.masksToBounds = YES;
    _pictureImage.layer.cornerRadius = 3.f;
    [self.mainbodyView addSubview:_pictureImage];
    
    
    [self.pictureImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainbodyView.mas_top).offset(10);
        make.left.equalTo(self.mainbodyView.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(110, 70));
    }];
    
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoDetail:)];
    //将手势添加到每个imageview上
    [_pictureImage addGestureRecognizer:tap];
    
    
    //时间
    _timeLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:13]];
    _timeLabel.textColor = [UIColor lightGrayColor];
//    _timeLabel.numberOfLines = 0;
//    _timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.mainbodyView addSubview:_timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mainbodyView.mas_right).offset(-10);
        make.centerY.equalTo(self.mainbodyView.mas_centerY);
    }];
    

    //警报信息类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    _typeLabel.textColor = [UIColor blackColor];
    [self.self.mainbodyView addSubview:_typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pictureImage.mas_right).offset(10);
        make.top.equalTo(self.pictureImage.mas_top).offset(7);
        make.right.equalTo(self.mainbodyView.mas_right).offset(-70);
    }];

    
    //红点
    _attentionView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _attentionView.image = [UIImage imageNamed:@"redyuan"];
    _attentionView.alpha = 0;
    [self.mainbodyView addSubview:_attentionView];
    [self.attentionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pictureImage.mas_right).offset(3);
        make.bottom.equalTo(self.pictureImage.mas_top).offset(5);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];

    
    //警报来源
    _messageLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 200, 9) text:nil font:[UIFont systemFontOfSize:13]];
    _messageLabel.textColor = [UIColor lightGrayColor];
    [self.mainbodyView addSubview:_messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pictureImage.mas_right).offset(10);
        make.bottom.equalTo(self.pictureImage.mas_bottom).offset(-7);
        make.right.equalTo(self.mainbodyView.mas_right).offset(-60);
    }];
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (self.isEdit == YES) {
        [self.pictureImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainbodyView.mas_top).offset(10);
            make.left.equalTo(self.mainbodyView.mas_left).offset(32);
            make.size.mas_equalTo(CGSizeMake(110, 70));
        }];
    }else{
        [self.pictureImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainbodyView.mas_top).offset(10);
            make.left.equalTo(self.mainbodyView.mas_left).offset(10);
            make.size.mas_equalTo(CGSizeMake(110, 70));
        }];
    }
}

//========================method========================
//选择删除按钮点击事件
- (void)deleteCell:(AlarmNewCell *)cell
{
    if (self.delegete && [self.delegete respondsToSelector:@selector(AlarmCell_tChooseBtnClick:)]) {
        [self.delegete AlarmCell_tChooseBtnClick:self];
    }
}
- (void)photoDetail:(AlarmNewCell *)cell
{
    if (self.delegete && [self.delegete respondsToSelector:@selector(Alarmcell_tPictureImageClick:)]) {
        [self.delegete Alarmcell_tPictureImageClick:self];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
