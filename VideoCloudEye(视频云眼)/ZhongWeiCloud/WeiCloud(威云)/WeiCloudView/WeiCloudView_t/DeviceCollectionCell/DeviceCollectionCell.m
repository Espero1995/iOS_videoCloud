//
//  DeviceCollectionCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "DeviceCollectionCell.h"
@interface DeviceCollectionCell ()
@property (nonatomic,strong) UIImage * cutIma;
@end
@implementation DeviceCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 3.f;
    self.ima_photo.layer.masksToBounds = YES;
    self.ima_photo.layer.cornerRadius = 3.0f;
    self.backView.layer.masksToBounds = YES;
    self.backView.layer.cornerRadius = 3.f;
}



- (IBAction)btnSettingClick:(id)sender forEvent:(UIEvent *)event
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(DeviceCollectionSettingClick:andEvent:)]) {
                [self.delegate DeviceCollectionSettingClick:self andEvent:event];
    }
}

//SD卡
- (IBAction)sdVideoClick:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(DeviceCollectionSDVideoClick:)]) {
        [self.delegate DeviceCollectionSDVideoClick:self];
    }
}
//云端录像
- (IBAction)cloudVideoClick:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(DeviceCollectionCloudVideoClick:)]) {
        [self.delegate DeviceCollectionCloudVideoClick:self];
    }
}
//告警消息
- (IBAction)alarmVideoClick:(id)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(DeviceCollectionAlarmVideoClick:)]) {
        [self.delegate DeviceCollectionAlarmVideoClick:self];
    }
}



- (void)setModel:(dev_list *)model
{
    _model = model;
    _cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:model.ID];
    if (_cutIma) {
        self.ima_photo.image = _cutIma;
    }else{
        self.ima_photo.image = [UIImage imageNamed:@"img2"];
    }
    
    //判断设备状态
    if (model.status == 0) {
        self.ima_photo.alpha = 0.8;
        self.backView.alpha = 0.7;
        self.lab_unLine.alpha = 1;
    }else{
        self.ima_photo.alpha = 1;
        self.backView.alpha = 0;
        self.lab_unLine.alpha = 0;
        
    }
    
    if (model.device_class == 1) {//普通设备
        self.isOnline_img.hidden = NO;
        if ([model.enableSensibility intValue] == 0) {
            // NSLog(@"移动侦测：关==名称：%@",model.name);
            self.isOnline_img.image = [UIImage imageNamed:@"person_1-1"];//没有开移动侦测
        }else{
            //NSLog(@"移动侦测：开==名称：%@",model.name);
            self.isOnline_img.image = [UIImage imageNamed:@"person_2-1"];//开移动侦测
        }
    }else{//安全网关【NT4、J3】
        self.isOnline_img.hidden = YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        if ([model.owner_id isEqualToString:[unitl get_User_id]]) {
            self.btn_setting.hidden = NO;
            
            if (model.chanCount == 0 || model.chanCount == 1) {
                self.sdBtn.hidden = NO;
                self.cloudBtn.hidden = NO;
                self.alarmBtn.hidden = NO;
            }else{
                self.sdBtn.hidden = YES;
                self.cloudBtn.hidden = YES;
                self.alarmBtn.hidden = YES;
            }
            
        }else{
            self.btn_setting.hidden = YES;
            
            //如果是途虎子账号，可以直接查看录像
            if (!isNodeTreeMode) {
                shareFeature *shareFeature = model.ext_info.shareFeature;
                if (model.enableOperator == 1) {
                    if ([shareFeature.hp intValue] == 1) {
                        self.sdBtn.hidden = NO;
                        self.cloudBtn.hidden = NO;
                        self.alarmBtn.hidden = NO;
                    }else{
                        self.sdBtn.hidden = YES;
                        self.cloudBtn.hidden = YES;
                        self.alarmBtn.hidden = YES;
                    }
                } else{
                    self.sdBtn.hidden = YES;
                    self.cloudBtn.hidden = YES;
                    self.alarmBtn.hidden = YES;
                }
                
            }   
            
        }
    }
    
    if ([unitl isNull:model.name]) {
        self.deviceName_Lb.text = model.type;
    }else{
        self.deviceName_Lb.text = model.name;
    }
    self.deviceName_Lb.textColor = RGB(80, 80, 80);
    self.deviceName_Lb.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    _nameStr = [NSMutableString stringWithFormat:@"%@",model.name];
    

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


@end
