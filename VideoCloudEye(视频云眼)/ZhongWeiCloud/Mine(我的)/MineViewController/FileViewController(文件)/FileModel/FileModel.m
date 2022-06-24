//
//  FileModel.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/25.
//  Copyright © 2018 张策. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.createTime forKey:@"createTime"];
    [aCoder encodeInteger:(int)self.type forKey:@"type"];
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
//    [aCoder encodeObject:self.coverImg forKey:@"coverImg"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.createTime = [aDecoder decodeObjectForKey:@"createTime"];
        self.type = (int)[aDecoder decodeIntegerForKey:@"type"];
        self.filePath = [aDecoder decodeObjectForKey:@"filePath"];
//        self.coverImg = [aDecoder decodeObjectForKey:@"coverImg"];
    }
    return self;
}
@end
