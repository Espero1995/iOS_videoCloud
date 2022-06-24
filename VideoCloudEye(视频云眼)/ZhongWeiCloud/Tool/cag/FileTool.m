//
//  FileTool.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/27.
//  Copyright © 2018 张策. All rights reserved.
//

#import "FileTool.h"

@implementation FileTool

#pragma mark - 创建自己制定路径的文件夹
+ (void)createRootFilePath:(NSString *)fileName
{
    if ([self isFileExist:fileName]) {
        NSLog(@"该文件已被创建，请使用");
    }else{
        NSLog(@"该文件并未创建，现在进行创建任务");
        //创建文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //1、拼接目录
        NSString *path = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents%@",fileName]];
        if([fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]){
            NSLog(@"创建成功!");
        }else{
            NSLog(@"创建失败");
        }
    }
}

#pragma mark - 判断文件是否已经在沙盒中已经存在
+ (BOOL)isFileExist:(NSString *)fileName
{
    NSLog(@"fileName:::%@",fileName);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
}

#pragma mark - 生成文件名
+ (NSString *)createFileName
{
    NSString *pathName = [NSString stringWithFormat:@"/Documents/%@/file/%@",[unitl get_user_mobile],[unitl getNowTimeTimestamp]];
    return pathName;
}

+ (NSString *)getFilePath:(NSString *)pathName
{
    //1、拼接目录
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:pathName];
//    NSLog(@"savePath:%@",filePath);
    return filePath;
}


@end
