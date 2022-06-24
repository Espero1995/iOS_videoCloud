//
//  DeviceSortCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "DeviceSearchCell.h"

@interface DeviceSearchCell ()
@property (nonatomic,strong) UIImage * cutIma;
@end

@implementation DeviceSearchCell


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
        self.bankView.alpha = 0.7;
    }else{
        self.ima_photo.alpha = 1;
        self.bankView.alpha = 0;
    }

    if ([unitl isNull:model.name]) {
        self.lab_name.text = model.type;
    }else{
        self.lab_name.text = model.name;
    }
    self.lab_name.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.lab_name.textColor = RGB(80, 80, 80);
    self.lab_fromName.textColor = MAIN_COLOR;
    self.lab_fromName.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"来自", nil),model.owner_name];
    self.lab_fromName.lineBreakMode = NSLineBreakByTruncatingMiddle;
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


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
