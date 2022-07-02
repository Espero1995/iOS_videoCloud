//
//  fourScreenChannelCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "fourScreenChannelCell.h"
#import "ChannelCodeListModel.h"
@interface fourScreenChannelCell ()
/*截图*/
@property (nonatomic,strong) UIImage * cutIma;
@end
@implementation fourScreenChannelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sdBtn.hidden = self.cloudBtn.hidden = YES;
    self.layer.cornerRadius = 3.f;
    self.ima_photo.layer.masksToBounds = YES;
    self.ima_photo.layer.cornerRadius = 3.0f;
    self.backView.layer.masksToBounds = YES;
    self.backView.layer.cornerRadius = 3.f;
}


//SD卡
- (IBAction)sdVideoClick:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(fourChannelCellSDVideoClick:)]) {
        [self.delegate fourChannelCellSDVideoClick:self];
    }
}
//云端录像
- (IBAction)cloudVideoClick:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(fourChannelCellCloudVideoClick:)]) {
        [self.delegate fourChannelCellCloudVideoClick:self];
    }
}
//告警消息
- (IBAction)alarmVideoClick:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(fourChannelCellAlarmVideoClick:)]) {
        [self.delegate fourChannelCellAlarmVideoClick:self];
    }
}



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
        self.backView.alpha = 0.7;
        self.lab_unLine.alpha = 1;
    }else{
        self.ima_photo.alpha = 1;
        self.backView.alpha = 0;
        self.lab_unLine.alpha = 0;
        
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
