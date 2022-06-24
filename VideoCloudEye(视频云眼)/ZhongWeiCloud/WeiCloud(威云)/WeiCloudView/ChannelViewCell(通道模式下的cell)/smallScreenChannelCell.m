//
//  smallScreenChannelCell.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "smallScreenChannelCell.h"
#import "ChannelCodeListModel.h"
@interface smallScreenChannelCell ()

@property (weak, nonatomic) IBOutlet UILabel *lab_unLine;
@property (nonatomic,strong) UIImage * cutIma;

@end

@implementation smallScreenChannelCell

- (void)setChannelModel:(ChannelCodeListModel *)channelModel
{
    _channelModel = channelModel;
    _cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:channelModel.deviceId];
    if (_cutIma) {
        self.ima_photo.image = _cutIma;
    }else{
        self.ima_photo.image = [UIImage imageNamed:@"img2"];
    }
    
    //判断设备状态
    if (channelModel.chanStatus == 0) {
        self.ima_photo.alpha = 0.8;
        self.bankView.alpha = 0.7;
        self.lab_unLine.alpha = 1;
    }else{
        self.ima_photo.alpha = 1;
        self.bankView.alpha = 0;
        self.lab_unLine.alpha = 0;
    }
    self.lab_name.text = channelModel.chanName;
    self.lab_name.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.lab_name.textColor = RGB(80, 80, 80);
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 5.f;
    self.bgView.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.bgView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.bgView.layer.shadowRadius = 5.f;
    self.bgView.layer.shadowOpacity = 0.3;
}


//sd卡
- (IBAction)sdVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(smallChannelCellSDVideoClick:)]) {
        [self.cellDelegate smallChannelCellSDVideoClick:self];
    }
}
//云端录像
- (IBAction)cloudVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(smallChannelCellCloudVideoClick:)]) {
        [self.cellDelegate smallChannelCellCloudVideoClick:self];
    }
}

- (IBAction)alarmVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(smallChannelCellAlarmVideoClick:)]) {
        [self.cellDelegate smallChannelCellAlarmVideoClick:self];
    }
}

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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
