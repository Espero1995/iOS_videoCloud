//
//  FileModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/25.
//  Copyright © 2018 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject
/**
 * 文件名：文件名称
 */
@property (nonatomic,copy) NSString *name;
/**
 * 日期：文件的生成日期
 */
@property (nonatomic,copy) NSString *date;
/**
 * 描述：文件的创建时间
 */
@property (nonatomic,copy) NSString *createTime;
/**
 * 类型：文件类型 0：视频 1：图片 2：gif
 */
@property (nonatomic,assign) int type;
/**
 * 路径：文件存储路径
 */
@property (nonatomic,copy) NSString *filePath;
/**
 * 图片：封面截图
 */
//@property (nonatomic,strong) UIImage *coverImg;
@end

