//
//  WeiCloudCell_t.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "WeiCloudCell_t.h"
#import "WeiCloudListModel.h"
#import "NSString+Md5String.h"
@interface WeiCloudCell_t ()

@property (weak, nonatomic) IBOutlet UILabel *lab_fromName;
@property (weak, nonatomic) IBOutlet UILabel *lab_unLine;
@property (nonatomic,strong) UIImage * cutIma;

@end

@implementation WeiCloudCell_t

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
        self.lab_unLine.alpha = 1;
    }else{
        self.ima_photo.alpha = 1;
        self.bankView.alpha = 0;
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
                    if ([shareFeature.hp intValue]== 1) {
                        self.sdBtn.hidden = NO;
                        self.cloudBtn.hidden = NO;
                        self.alarmBtn.hidden = NO;
                    }else{
                        self.sdBtn.hidden = YES;
                        self.cloudBtn.hidden = YES;
                        self.alarmBtn.hidden = YES;
                    }
                }else{
                    self.sdBtn.hidden = YES;
                    self.cloudBtn.hidden = YES;
                    self.alarmBtn.hidden = YES;
                }
            }
            
            
        }
    }
   
    if ([unitl isNull:model.name]) {
        self.lab_name.text = model.type;
    }else{
        self.lab_name.text = model.name;
    }
    self.lab_name.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.lab_name.textColor = RGB(80, 80, 80);
    _nameStr = [NSMutableString stringWithFormat:@"%@",model.name];
    
    UserModel * userModel = [[GetAccountInfo shareInstane] getAccountModel];
    self.lab_fromName.textColor = MAIN_COLOR;
    if ([userModel.user_name isEqualToString:model.owner_name]) {
        self.lab_fromName.text = @"";
    }else{
        self.lab_fromName.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"来自", nil),model.owner_name];
        self.lab_fromName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 5.f;
    self.bgView.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.bgView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.bgView.layer.shadowRadius = 5.f;
    self.bgView.layer.shadowOpacity = 0.3;
}


- (IBAction)btnSettingClick:(id)sender forEvent:(UIEvent *)event {
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(WeiCloudCellBtnSettingClick:andEvent:)]) {
        [self.cellDelegate WeiCloudCellBtnSettingClick:self andEvent:event];
    }
}

//sd卡
- (IBAction)sdVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(WeiCloudCellSDVideoClick:)]) {
        [self.cellDelegate WeiCloudCellSDVideoClick:self];
    }
}
//云端录像
- (IBAction)cloudVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(WeiCloudCellCloudVideoClick:)]) {
        [self.cellDelegate WeiCloudCellCloudVideoClick:self];
    }
}

- (IBAction)alarmVideoClick:(id)sender
{
    if (self.cellDelegate &&[self.cellDelegate respondsToSelector:@selector(WeiCloudCellAlarmVideoClick:)]) {
        [self.cellDelegate WeiCloudCellAlarmVideoClick:self];
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
