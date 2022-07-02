//
//  bigScreenChannelCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/14.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "bigScreenChannelCell.h"
#import "ChannelCodeListModel.h"
@interface bigScreenChannelCell ()
/*截图*/
@property (nonatomic,strong) UIImage * cutIma;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UILabel *lab_unLine;
@property (strong, nonatomic) IBOutlet UIImageView *devicePlayImg;
@property (strong, nonatomic) IBOutlet UIButton *sdBtn;//SD卡按钮
@property (strong, nonatomic) IBOutlet UIButton *cloudBtn;//云端按钮
@property (strong, nonatomic) IBOutlet UIButton *alarmBtn;//告警按钮

@property (nonatomic,strong) UIView *tipView;

@end
@implementation bigScreenChannelCell
//=========================init=========================
- (void)awakeFromNib {
    [super awakeFromNib];
    self.sdBtn.hidden = self.cloudBtn.hidden = YES;
    self.bgView.layer.cornerRadius = 5.f;
    self.bgView.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.bgView.layer.shadowOffset = CGSizeMake(0.f, 0.f);
    self.bgView.layer.shadowRadius = 5.f;
    self.bgView.layer.shadowOpacity = 0.5;
    self.ima_photo.layer.masksToBounds = YES;
    self.ima_photo.layer.cornerRadius = 5.0f;
    self.backView.layer.masksToBounds = YES;
    self.backView.layer.cornerRadius = 5.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


//=========================method=========================

//sd卡
- (IBAction)sdVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(bigChannelCellSDVideoClick:)]) {
        [self.cellDelegate bigChannelCellSDVideoClick:self];
    }
}
//云端录像
- (IBAction)cloudVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(bigChannelCellCloudVideoClick:)]) {
        [self.cellDelegate bigChannelCellCloudVideoClick:self];
    }
}

//告警列表
- (IBAction)alarmVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(bigChannelCellAlarmVideoClick:)]) {
        [self.cellDelegate bigChannelCellAlarmVideoClick:self];
    }
}


- (void)setChannelModel:(ChannelCodeListModel *)channelModel
{
    _channelModel = channelModel;
    //截图
    _cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:channelModel.deviceId];
    if (_cutIma) {
        self.ima_photo.image = _cutIma;
    }else{
        self.ima_photo.image = [UIImage imageNamed:@"img1"];
    }
    
    //判断设备状态
    if (channelModel.chanStatus == 0) {
        self.lab_unLine.alpha = 1;
        self.devicePlayImg.alpha = 0;
        self.backView.alpha = 0.8;
    }else{
        self.lab_unLine.alpha = 0;
        self.devicePlayImg.alpha = 1;
        self.backView.alpha = 0;
    }
    self.deviceName_Lb.text = channelModel.chanName;
    self.deviceName_Lb.textColor = RGB(80, 80, 80);
    self.deviceName_Lb.lineBreakMode = NSLineBreakByTruncatingMiddle;
}

#pragma mark -----截图方法
- (UIImage*)getSmallImageWithUrl:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)nameStr
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //1、拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",nameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    UIImage *cutIma =  [[UIImage alloc]initWithContentsOfFile:savePath];

    return cutIma;
}


@end
