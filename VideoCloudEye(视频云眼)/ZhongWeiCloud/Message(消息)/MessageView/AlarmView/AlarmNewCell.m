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

/*容器*/
@property (nonatomic,strong) UIView * mainbodyView;
/*图片*/
@property (nonatomic,strong) UIImageView * pictureImage;
/*几号+星期*/
@property (nonatomic,strong) UILabel * weekLabel;
/*时间*/
@property (nonatomic,strong) UILabel * timeLabel;
/*选择按钮*/
@property (nonatomic,strong) UIButton * chooseBtn;
/*红点*/
@property (nonatomic,strong) UIImageView * attentionView;
/*类型*/
@property (nonatomic,strong) UILabel * typeLabel;
/*来源*/
@property (nonatomic,strong) UILabel * messageLabel;

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
    self.contentView.backgroundColor = RGB(245, 245, 245);
    //正文内容视图
    _mainbodyView = [UIView new];
    _mainbodyView.layer.masksToBounds = YES;
    _mainbodyView.layer.cornerRadius = 8;
    _mainbodyView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_mainbodyView];
    [_mainbodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(16.f);
        make.top.bottom.inset(8.f);
    }];
    
    //选择按钮
    _chooseBtn = [[UIButton alloc]initWithFrame:CGRectMake(9, (90-18)/2, 18, 18)];
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"select_n"] forState:UIControlStateNormal];
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"select_h"] forState:UIControlStateSelected];
//    _chooseBtn.enabled = NO;
    _chooseBtn.hidden = YES;
    [_chooseBtn addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_chooseBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.offset(16.f);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    
    //监控图片
    _pictureImage = [[UIImageView alloc] init];
    _pictureImage.userInteractionEnabled = YES;
    _pictureImage.layer.masksToBounds = YES;
    _pictureImage.layer.cornerRadius = 3.f;
    [self.mainbodyView addSubview:_pictureImage];
    _pictureImage.image = [UIImage imageNamed:@"alerm"];
    
    [self.pictureImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainbodyView);
        make.right.equalTo(self.mainbodyView).offset(-16);
        make.size.mas_equalTo(CGSizeMake(28, 24));
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoDetail:)];
    //将手势添加到每个imageview上
    [_pictureImage addGestureRecognizer:tap];
    
    //时间
    _timeLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:13]];
    _timeLabel.textColor = [UIColor lightGrayColor];
    [self.mainbodyView addSubview:_timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pictureImage.mas_left).offset(-20);
        make.centerY.equalTo(self.mainbodyView.mas_centerY);
    }];

    //警报信息类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont boldSystemFontOfSize:16]];
    _typeLabel.textColor = [UIColor blackColor];
    [self.self.mainbodyView addSubview:_typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainbodyView).offset(16);
        make.top.equalTo(self.mainbodyView).offset(16);
        make.right.lessThanOrEqualTo(self.pictureImage.mas_left).offset(-70);
    }];
    
    //警报来源
    _messageLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:13]];
    _messageLabel.textColor = [UIColor lightGrayColor];
    [self.mainbodyView addSubview:_messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeLabel);
        make.bottom.equalTo(self.mainbodyView.mas_bottom).offset(-12);
        make.right.lessThanOrEqualTo(self.pictureImage.mas_left).offset(-70);
    }];
    
    //红点
    _attentionView = [[UIImageView alloc] init];
    _attentionView.image = [UIImage imageNamed:@"redyuan"];
    _attentionView.hidden = YES;
    [self.mainbodyView addSubview:_attentionView];
    [self.attentionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pictureImage.mas_right).offset(3);
        make.bottom.equalTo(self.pictureImage.mas_top).offset(4);
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
}


- (void)setAlermModel:(PushMsgModel *)alermModel {
    _alermModel = alermModel;
    
    NSString *timeStr= [NSString stringWithFormat:@"%d",alermModel.alarmTime];
    NSTimeInterval time=[timeStr doubleValue];//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter * timeDate = [[NSDateFormatter alloc]init];
    NSDateFormatter * timeWeek = [[NSDateFormatter alloc]init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
    [timeDate setDateFormat:[NSString stringWithFormat:@"MM%@dd",NSLocalizedString(@"月", nil)]];
    [timeWeek setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTimeStr = [dateFormatter stringFromDate: detaildate];
    //设置了时间
    self.timeLabel.text = currentTimeStr;
    
    self.attentionView.hidden = alermModel.markread;
    
    self.typeLabel.text = [NSString stringWithFormat:@"%@%@",alermModel.deviceName,NSLocalizedString(@"警报", nil)];
    
    NSString *message = @"";
    switch (alermModel.alarmType) {
        case AlarmType_artificialVideo:
            message = NSLocalizedString(@"触发移动侦测报警", nil);
            break;
        case AlarmType_motion:
            message = NSLocalizedString(@"运动目标检测报警", nil);
            break;
        case AlarmType_remnant:
            message = NSLocalizedString(@"遗留物检测报警", nil);
            break;
        case AlarmType_objectRemoved:
            message = NSLocalizedString(@"物体移除检测报警", nil);
            break;
        case AlarmType_tripwire:
            message = NSLocalizedString(@"绊线检测报警", nil);
            break;
        case AlarmType_intrusion:
            message = NSLocalizedString(@"入侵检测报警", nil);
            break;
        case AlarmType_retrograde:
            message = NSLocalizedString(@"逆行检测报警", nil);
            break;
        case AlarmType_hover:
            message = NSLocalizedString(@"徘徊检测报警", nil);
            break;
        case AlarmType_traffic:
            message = NSLocalizedString(@"流量统计报警", nil);
            break;
        case AlarmType_density:
            message = NSLocalizedString(@"密度检测报警", nil);
            break;
        case AlarmType_abnormalVideo:
            message = NSLocalizedString(@"视频异常检测报警", nil);
            break;
        case AlarmType_fastMoving:
            message = NSLocalizedString(@"快速移动报警", nil);
            break;
        case AlarmType_FIRE_EXIT:
            message = NSLocalizedString(@"消防通道占用检测报警", nil);
            break;
        case AlarmType_SMOKE_AND_FIRE:
            message = NSLocalizedString(@"烟火检测报警", nil);
            break;
        case AlarmType_TRAFFIC_LANE_PARK:
            message = NSLocalizedString(@"异常停车检测报警", nil);
            break;
        case AlarmType_abnormalTemperature:
            message = NSLocalizedString(@"体温异常报警", nil);
            break;
        default:
            break;
    }
    self.messageLabel.text = message;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.chooseBtn.hidden = !self.isEdit;
    if (self.isEdit == YES) {
        [self.mainbodyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.chooseBtn.mas_right).offset(16.f);
            make.right.equalTo(self.contentView).inset(16.f);
            make.top.bottom.inset(8.f);
        }];
    }else{
        [self.mainbodyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView).inset(16.f);
            make.top.bottom.inset(8.f);
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
    if (self.delegete && [self.delegete respondsToSelector:@selector(Alarmcell_tPictureImageClick:atIndexPath:)]) {
        [self.delegete Alarmcell_tPictureImageClick:self atIndexPath:self.indexPath];
    }
}

- (void)configRedPointHidden:(BOOL)hidden {
    self.attentionView.hidden = hidden;
}

- (void)configChooseBtnHidden:(BOOL)hidden {
    self.chooseBtn.hidden = hidden;
}

- (void)configChooseBtnSeleted:(BOOL)selected {
    self.chooseBtn.selected = selected;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
