//
//  JWfileManager.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "JWfileManager.h"

@implementation JWfileManager
HDSingletonM(JWfileManager)

- (UIImage*)getSmallImageWithUrl:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)nameStr
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径,拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"%@.jpg",nameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    UIImage *cutIma =  [[UIImage alloc]initWithContentsOfFile:savePath];
    
//    NSData* imageData = [fileManager contentsAtPath:savePath];
//    if (!imageData) {
//        NSLog(@"该路径下未找到 图片");
//    }
    return cutIma;
}
@end
