//
//  FileCollectionCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/25.
//  Copyright © 2018 张策. All rights reserved.
//

#import "FileCollectionCell.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
@implementation FileCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //选择按钮
    _chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chooseBtn setImage:[UIImage imageNamed:@"select_n"] forState:UIControlStateNormal];
    [_chooseBtn setImage:[UIImage imageNamed:@"select_h"] forState:UIControlStateSelected];
    [self.img addSubview:_chooseBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.img.mas_left).offset(5);
        make.top.equalTo(self.img.mas_top).offset(5);
    }];
    
}

- (void)setModel:(FileModel *)model
{
    _model = model;
//    NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];//缩略图文件名
//    self.img.image = [[UIImage alloc]initWithContentsOfFile:filePath];
    
    self.img.image = [self getImage:model];
}

-(UIImage *)getImage:(FileModel *)model
{
    NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
    UIImage *thumb = [[UIImage alloc] init];
    if (model.type == 0) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        return thumb;
    }else if (model.type == 1){
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:filePath];
        return image;
    }else{
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:filePath];
        return image;
    }
    
    return thumb;
}

@end
