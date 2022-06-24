//
//  WeiCloudListModel.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "WeiCloudListModel.h"


@implementation WeiCloudListModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"deviceGroup" : @"deviceGroup"
             };
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.deviceGroup forKey:@"deviceGroup"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.deviceGroup =[aDecoder decodeObjectForKey:@"deviceGroup"];
    }
    return self;
}


@end



@implementation deviceGroup

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"dev_list" : @"dev_list"
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"dev_list": @"deviceList"
             };
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.devcieIds forKey:@"devcieIds"];
    [aCoder encodeObject:self.ownerId forKey:@"ownerId"];
    [aCoder encodeObject:self.channels forKey:@"channels"];
    [aCoder encodeObject:self.groupName forKey:@"groupName"];
    [aCoder encodeObject:self.silentMode forKey:@"silentMode"];
    [aCoder encodeObject:self.createDate forKey:@"createDate"];
    [aCoder encodeObject:self.groupId forKey:@"groupId"];
    [aCoder encodeObject:self.enableSensibility forKey:@"enableSensibility"];
    [aCoder encodeBool:self.top forKey:@"top"];
    [aCoder encodeObject:self.dev_list forKey:@"dev_list"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.devcieIds =[aDecoder decodeObjectForKey:@"devcieIds"];
        self.ownerId =[aDecoder decodeObjectForKey:@"ownerId"];
        self.channels =[aDecoder decodeObjectForKey:@"channels"];
        self.groupName =[aDecoder decodeObjectForKey:@"groupName"];
        self.silentMode =[aDecoder decodeObjectForKey:@"silentMode"];
        self.createDate =[aDecoder decodeObjectForKey:@"createDate"];
        self.groupId =[aDecoder decodeObjectForKey:@"groupId"];
        self.enableSensibility =[aDecoder decodeObjectForKey:@"enableSensibility"];
        self.top =[aDecoder decodeBoolForKey:@"top"];
        self.dev_list =[aDecoder decodeObjectForKey:@"dev_list"];
    }
    return self;
}

@end




@implementation dev_list

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"ID": @"id"};
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeInteger:(int)self.chan_size forKey:@"chan_size"];
    [aCoder encodeObject:self.chan_alias forKey:@"chan_alias"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeObject:self.owner_id forKey:@"owner_id"];
    [aCoder encodeObject:self.owner_name forKey:@"owner_name"];
    [aCoder encodeObject:self.vsample forKey:@"vsample"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.dev_p_code forKey:@"dev_p_code"];
    [aCoder encodeBool:self.enable_sec forKey:@"enable_sec"];
    //新增
    [aCoder encodeObject:self.version forKey:@"version"];
    [aCoder encodeBool:self.is_public forKey:@"is_public"];
    [aCoder encodeObject:self.importDate forKey:@"importDate"];
    [aCoder encodeObject:self.groupId forKey:@"groupId"];
    [aCoder encodeInteger:(int)self.device_class forKey:@"device_class"];
    [aCoder encodeObject:self.chans forKey:@"chans"];
    [aCoder encodeObject:self.ext_info forKey:@"ext_info"];
    [aCoder encodeObject:self.extParams forKey:@"extParams"];
    
    [aCoder encodeObject:self.silentMode forKey:@"silentMode"];
    [aCoder encodeObject:self.enableSD forKey:@"enableSD"];
    [aCoder encodeObject:self.enableCloud forKey:@"enableCloud"];
    [aCoder encodeInteger:(int)self.enableOperator forKey:@"enableOperator"];
    [aCoder encodeObject:self.enableSensibility forKey:@"enableSensibility"];
    [aCoder encodeObject:self.enableInfrared forKey:@"enableInfrared"];
    [aCoder encodeInteger:(int)self.shraedLimit forKey:@"shraedLimit"];
    [aCoder encodeInteger:(long)self.chanCount forKey:@"chanCount"];
    [aCoder encodeObject:self.grantPlanId forKey:@"grantPlanId"];
    [aCoder encodeObject:self.firstOnlineDate forKey:@"firstOnlineDate"];
    [aCoder encodeObject:self.autoUpgrade forKey:@"autoUpgrade"];
    [aCoder encodeObject:self.sharePolice forKey:@"sharePolice"];
    [aCoder encodeObject:self.grantInfo forKey:@"grantInfo"];
    
    [aCoder encodeObject:self.coverImageView forKey:@"coverImageView"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.ID =[aDecoder decodeObjectForKey:@"ID"];
        self.chan_size =(int)[aDecoder decodeIntegerForKey:@"chan_size"];
        self.chan_alias =[aDecoder decodeObjectForKey:@"chan_alias"];
        self.name =[aDecoder decodeObjectForKey:@"name"];
        self.owner_id =[aDecoder decodeObjectForKey:@"owner_id"];
        self.owner_name =[aDecoder decodeObjectForKey:@"owner_name"];
        self.vsample =[aDecoder decodeObjectForKey:@"vsample"];
        self.type =[aDecoder decodeObjectForKey:@"type"];
        self.status =  [aDecoder decodeIntegerForKey:@"status"];
        self.dev_p_code = [aDecoder decodeObjectForKey:@"dev_p_code"];
        self.enable_sec = [aDecoder decodeBoolForKey:@"enable_sec"];
        //新增
        self.version = [aDecoder decodeObjectForKey:@"version"];
        self.is_public = [aDecoder decodeBoolForKey:@"is_public"];
        self.importDate = [aDecoder decodeObjectForKey:@"importDate"];
        self.groupId = [aDecoder decodeObjectForKey:@"groupId"];
        self.device_class = (int)[aDecoder decodeIntegerForKey:@"device_class"];
        self.chans = [aDecoder decodeObjectForKey:@"chans"];
        self.ext_info = [aDecoder decodeObjectForKey:@"ext_info"];
        self.extParams = [aDecoder decodeObjectForKey:@"extParams"];
        
        self.silentMode = [aDecoder decodeObjectForKey:@"silentMode"];
        self.enableSD = [aDecoder decodeObjectForKey:@"enableSD"];
        self.enableCloud = [aDecoder decodeObjectForKey:@"enableCloud"];
        self.enableOperator = (int)[aDecoder decodeIntegerForKey:@"enableOperator"];
        self.enableSensibility = [aDecoder decodeObjectForKey:@"enableSensibility"];
        self.enableInfrared = [aDecoder decodeObjectForKey:@"enableInfrared"];
        self.shraedLimit = (int)[aDecoder decodeObjectForKey:@"shraedLimit"];
        self.chanCount = (long)[aDecoder decodeObjectForKey:@"chanCount"];
        self.grantPlanId = [aDecoder decodeObjectForKey:@"grantPlanId"];
        self.firstOnlineDate = [aDecoder decodeObjectForKey:@"firstOnlineDate"];
        self.autoUpgrade = [aDecoder decodeObjectForKey:@"autoUpgrade"];
        self.sharePolice = [aDecoder decodeObjectForKey:@"sharePolice"];
        self.grantInfo = [aDecoder decodeObjectForKey:@"grantInfo"];
        
        self.coverImageView = [aDecoder decodeObjectForKey:@"coverImageView"];
    }
    return self;
}
@end



@implementation ext_info
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Feature forKey:@"Feature"];
    [aCoder encodeObject:self.dev_img forKey:@"dev_img"];
    [aCoder encodeObject:self.video_streams forKey:@"video_streams"];
    [aCoder encodeObject:self.feature_cms forKey:@"Feature_cms"];
    [aCoder encodeObject:self.shareFeature forKey:@"shareFeature"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.Feature =[aDecoder decodeObjectForKey:@"Feature"];
        self.dev_img =[aDecoder decodeObjectForKey:@"dev_img"];
        self.video_streams =[aDecoder decodeObjectForKey:@"video_streams"];
        self.feature_cms =[aDecoder decodeObjectForKey:@"Feature_cms"];
        self.shareFeature =[aDecoder decodeObjectForKey:@"shareFeature"];
    }
    return self;
}

@end



@implementation Feature_cms
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.apm forKey:@"apm"];
    [aCoder encodeObject:self.cloud forKey:@"cloud"];
    [aCoder encodeObject:self.imf forKey:@"imf"];
    [aCoder encodeObject:self.lm forKey:@"lm"];
    [aCoder encodeObject:self.mdt forKey:@"mdt"];
    [aCoder encodeObject:self.p2p forKey:@"p2p"];
    [aCoder encodeObject:self.ptz forKey:@"ptz"];
    [aCoder encodeObject:self.scm forKey:@"scm"];
    [aCoder encodeObject:self.sm forKey:@"sm"];
    [aCoder encodeObject:self.talk forKey:@"talk"];
    [aCoder encodeObject:self.tdccm forKey:@"tdccm"];
    [aCoder encodeObject:self.wdy forKey:@"wdy"];
    [aCoder encodeObject:self.wifi forKey:@"wifi"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.apm =[aDecoder decodeObjectForKey:@"apm"];
        self.cloud =[aDecoder decodeObjectForKey:@"dev_img"];
        self.imf =[aDecoder decodeObjectForKey:@"imf"];
        self.lm =[aDecoder decodeObjectForKey:@"lm"];
        self.mdt =[aDecoder decodeObjectForKey:@"mdt"];
        self.p2p =[aDecoder decodeObjectForKey:@"p2p"];
        self.ptz =[aDecoder decodeObjectForKey:@"ptz"];
        self.scm =[aDecoder decodeObjectForKey:@"scm"];
        self.sm =[aDecoder decodeObjectForKey:@"sm"];
        self.talk =[aDecoder decodeObjectForKey:@"talk"];
        self.tdccm =[aDecoder decodeObjectForKey:@"tdccm"];
        self.wdy =[aDecoder decodeObjectForKey:@"wdy"];
        self.wifi =[aDecoder decodeObjectForKey:@"wifi"];
    }
    return self;
}
@end



@implementation shareFeature
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.hp forKey:@"hp_shareFeature"];
    [aCoder encodeObject:self.ptz forKey:@"ptz_shareFeature"];
    [aCoder encodeObject:self.rtv forKey:@"rtv_shareFeature"];
    [aCoder encodeObject:self.talk forKey:@"talk_shareFeature"];
    [aCoder encodeObject:self.volice forKey:@"volice_shareFeature"];
    
    [aCoder encodeObject:self.timeLimit forKey:@"timeLimit_shareFeature"];
    [aCoder encodeObject:self.endTime forKey:@"endTime_shareFeature"];
    [aCoder encodeObject:self.alarm forKey:@"alarm_shareFeature"];
    [aCoder encodeObject:self.startTime forKey:@"startTime_shareFeature"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.hp =[aDecoder decodeObjectForKey:@"hp_shareFeature"];
        self.ptz =[aDecoder decodeObjectForKey:@"ptz_shareFeature"];
        self.rtv =[aDecoder decodeObjectForKey:@"rtv_shareFeature"];
        self.talk =[aDecoder decodeObjectForKey:@"talk_shareFeature"];
        self.volice =[aDecoder decodeObjectForKey:@"volice_shareFeature"];
        
        self.timeLimit =[aDecoder decodeObjectForKey:@"timeLimit_shareFeature"];
        self.endTime =[aDecoder decodeObjectForKey:@"endTime_shareFeature"];
        self.alarm =[aDecoder decodeObjectForKey:@"alarm_shareFeature"];
        self.startTime =[aDecoder decodeObjectForKey:@"startTime_shareFeature"];
    }
    return self;
}
@end
