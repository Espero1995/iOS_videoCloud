//
//  gruopInfoModel.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/31.
//  Copyright © 2018年 苏旋律. All rights reserved.
//

#import "gruopInfoModel.h"

@implementation gruopInfoModel

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ret forKey:@"ret_group"];
    [aCoder encodeObject:self.info forKey:@"info_group"];
    [aCoder encodeObject:self.body forKey:@"body_group"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.ret =[aDecoder decodeObjectForKey:@"ret_group"];
        self.info =[aDecoder decodeObjectForKey:@"info_group"];
        self.body =[aDecoder decodeObjectForKey:@"body_group"];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end

@implementation gruopListModel

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.deviceGroup forKey:@"deviceGroup_group"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.deviceGroup =[aDecoder decodeObjectForKey:@"deviceGroup_group"];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end

@implementation deviceGroupModel

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.devcieIds forKey:@"devcieIds_group"];
    [aCoder encodeObject:self.ownerId forKey:@"ownerId_group"];
    [aCoder encodeObject:self.channels forKey:@"channels_group"];
    [aCoder encodeObject:self.groupName forKey:@"groupName_group"];
    [aCoder encodeObject:self.silentMode forKey:@"silentMode_group"];
    [aCoder encodeObject:self.createDate forKey:@"createDate_group"];
    [aCoder encodeObject:self.groupId forKey:@"groupId_group"];
    [aCoder encodeObject:self.enableSensibility forKey:@"enableSensibility_group"];
    [aCoder encodeBool:self.top forKey:@"top_group"];
    [aCoder encodeObject:self.deviceList forKey:@"deviceList_group"];

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.devcieIds =[aDecoder decodeObjectForKey:@"devcieIds_group"];
        self.ownerId =[aDecoder decodeObjectForKey:@"ownerId_group"];
        self.channels =[aDecoder decodeObjectForKey:@"channels_group"];
        self.groupName =[aDecoder decodeObjectForKey:@"groupName_group"];
        self.silentMode =[aDecoder decodeObjectForKey:@"silentMode_group"];
        self.createDate =[aDecoder decodeObjectForKey:@"createDate_group"];
        self.groupId =[aDecoder decodeObjectForKey:@"groupId_group"];
        self.enableSensibility =[aDecoder decodeObjectForKey:@"enableSensibility_group"];
        self.top =[aDecoder decodeBoolForKey:@"top_group"];
        self.deviceList =[aDecoder decodeObjectForKey:@"deviceList_group"];

    }
    return self;
}


@end

@implementation deviceListModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"ID": @"id"};
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.grantPlanId forKey:@"grantPlanId_group"];
    [aCoder encodeBool:self.is_public forKey:@"is_public_group"];
    [aCoder encodeObject:self.status forKey:@"status_group"];
    [aCoder encodeObject:self.owner_id forKey:@"owner_id_group"];
    [aCoder encodeObject:self.chan_size forKey:@"chan_size_group"];
    [aCoder encodeObject:self.dev_p_code forKey:@"dev_p_code_group"];
    [aCoder encodeObject:self.enableSD forKey:@"enableSD_group"];
    [aCoder encodeObject:self.enableOperator forKey:@"enableOperator_group"];
    [aCoder encodeBool:self.enable_sec forKey:@"enable_sec_group"];
    [aCoder encodeObject:self.enableInfrared forKey:@"enableInfrared_group"];
    [aCoder encodeObject:self.name forKey:@"name_group"];
    [aCoder encodeObject:self.version forKey:@"version_group"];
    [aCoder encodeObject:self.type forKey:@"type_group"];
    [aCoder encodeObject:self.ID forKey:@"ID_group"];
    [aCoder encodeObject:self.firstOnlineDate forKey:@"firstOnlineDate_group"];
    [aCoder encodeObject:self.owner_name forKey:@"owner_name_group"];
    [aCoder encodeObject:self.chans forKey:@"chans_group"];
    [aCoder encodeObject:self.silentMode forKey:@"silentMode_group"];
    [aCoder encodeObject:self.autoUpgrade forKey:@"autoUpgrade_group"];
    [aCoder encodeObject:self.sharePolice forKey:@"sharePolice_group"];
    [aCoder encodeObject:self.enableCloud forKey:@"enableCloud_group"];
    [aCoder encodeObject:self.vsample forKey:@"vsample_group"];
    [aCoder encodeObject:self.device_class forKey:@"device_class_group"];
    [aCoder encodeObject:self.groupId forKey:@"groupId_group"];
    [aCoder encodeObject:self.chan_alias forKey:@"chan_alias_group"];
    [aCoder encodeObject:self.importDate forKey:@"importDate_group"];
    [aCoder encodeObject:self.enableSensibility forKey:@"enableSensibility_group"];
    [aCoder encodeObject:self.grantInfo forKey:@"grantInfo_group"];
    [aCoder encodeObject:self.ext_info forKey:@"ext_info_group"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.grantPlanId =[aDecoder decodeObjectForKey:@"grantPlanId_group"];
        self.is_public =[aDecoder decodeBoolForKey:@"is_public_group"];
        self.status =[aDecoder decodeObjectForKey:@"status_group"];
        self.owner_id =[aDecoder decodeObjectForKey:@"owner_id_group"];
        self.chan_size =[aDecoder decodeObjectForKey:@"chan_size_group"];
        self.dev_p_code =[aDecoder decodeObjectForKey:@"dev_p_code_group"];
        self.enableSD =[aDecoder decodeObjectForKey:@"enableSD_group"];
        self.enableOperator =[aDecoder decodeObjectForKey:@"enableOperator_group"];
        self.enable_sec =[aDecoder decodeBoolForKey:@"enable_sec_group"];
        self.enableInfrared =[aDecoder decodeObjectForKey:@"enableInfrared_group"];
        self.name =[aDecoder decodeObjectForKey:@"name_group"];
        self.version =[aDecoder decodeObjectForKey:@"version_group"];
        self.type =[aDecoder decodeObjectForKey:@"type_group"];
        self.ID =[aDecoder decodeObjectForKey:@"ID_group"];
        self.firstOnlineDate =[aDecoder decodeObjectForKey:@"firstOnlineDate_group"];
        self.owner_name =[aDecoder decodeObjectForKey:@"owner_name_group"];
        self.chans =[aDecoder decodeObjectForKey:@"chans_group"];
        self.silentMode =[aDecoder decodeObjectForKey:@"silentMode_group"];
        self.autoUpgrade =[aDecoder decodeObjectForKey:@"autoUpgrade_group"];
        self.sharePolice =[aDecoder decodeObjectForKey:@"sharePolice_group"];
        self.enableCloud =[aDecoder decodeObjectForKey:@"enableCloud_group"];
        self.vsample =[aDecoder decodeObjectForKey:@"vsample_group"];
        self.device_class =[aDecoder decodeObjectForKey:@"device_class_group"];
        self.groupId =[aDecoder decodeObjectForKey:@"groupId_group"];
        self.chan_alias =[aDecoder decodeObjectForKey:@"chan_alias_group"];
        self.importDate =[aDecoder decodeObjectForKey:@"importDate_group"];
        self.enableSensibility =[aDecoder decodeObjectForKey:@"enableSensibility_group"];
        self.grantInfo =[aDecoder decodeObjectForKey:@"grantInfo_group"];
        self.ext_info =[aDecoder decodeObjectForKey:@"ext_info_group"];
 
    }
    return self;
}



@end

@implementation ext_infoModel
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Feature forKey:@"Feature_group"];
    [aCoder encodeObject:self.shareFeature forKey:@"shareFeature_group"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.Feature =[aDecoder decodeObjectForKey:@"Feature_group"];
        self.shareFeature =[aDecoder decodeObjectForKey:@"shareFeature_group"];
    }
    return self;
}



@end

@implementation shareFeatureModel
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.hp forKey:@"hp_group"];
    [aCoder encodeObject:self.rtv forKey:@"rtv_group"];
    [aCoder encodeObject:self.timeLimit forKey:@"timeLimit_group"];
    [aCoder encodeObject:self.endTime forKey:@"endTime_group"];
    [aCoder encodeObject:self.ptz forKey:@"ptz_group"];
    [aCoder encodeObject:self.volice forKey:@"volice_group"];
    [aCoder encodeObject:self.alarm forKey:@"alarm_group"];
    [aCoder encodeObject:self.startTime forKey:@"startTime_group"];
    [aCoder encodeObject:self.talk forKey:@"talk_group"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.hp =[aDecoder decodeObjectForKey:@"hp_group"];
        self.rtv =[aDecoder decodeObjectForKey:@"rtv_group"];
        self.timeLimit =[aDecoder decodeObjectForKey:@"timeLimit_group"];
        self.endTime =[aDecoder decodeObjectForKey:@"endTime_group"];
        self.ptz =[aDecoder decodeObjectForKey:@"ptz_group"];
        self.volice =[aDecoder decodeObjectForKey:@"volice_group"];
        self.alarm =[aDecoder decodeObjectForKey:@"alarm_group"];
        self.startTime =[aDecoder decodeObjectForKey:@"startTime_group"];
        self.talk =[aDecoder decodeObjectForKey:@"talk_group"];
    }
    return self;
}



@end
