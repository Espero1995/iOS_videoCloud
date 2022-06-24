//
//  FileTool.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/27.
//  Copyright © 2018 张策. All rights reserved.
//
/**
 *  description:专门处理一些有关沙盒文件等方法
 */
#import <Foundation/Foundation.h>

@interface FileTool : NSObject
/**
 根据自己定义的文件路径来进行创建文件夹
 @param fileName 传进来的文件路径（创建于Documents路径下）
 其中会进行路径是否存在进行判定，如果存在将不进行创建，未存在则进行创建文件夹
 */
+ (void)createRootFilePath:(NSString *)fileName;

/**
 根据自己定义的文件路径来生成文件名
 @return 返回生成好的文件名
 */
+ (NSString *)createFileName;

/**
 根据自己定义的文件路径来进行搜索文件路径并创建完整的最终路径
 @param pathName 传进来的文件路径（创建于Documents路径下）
 @return 返回完整的沙盒文件路径
 */
+ (NSString *)getFilePath:(NSString *)pathName;

/**
 判断文件是否已经在沙盒中已经存在
 @param fileName 传进来的文件路径
 @return 是否存在
 */
+ (BOOL)isFileExist:(NSString *)fileName;

@end

