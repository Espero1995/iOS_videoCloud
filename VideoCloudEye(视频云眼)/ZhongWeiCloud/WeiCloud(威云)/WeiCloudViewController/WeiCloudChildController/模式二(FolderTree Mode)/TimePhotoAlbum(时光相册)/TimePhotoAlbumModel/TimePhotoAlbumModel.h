//
//  TimePhotoAlbumModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/23.
//  Copyright © 2018 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimePhotoAlbumModel : NSObject
@property (nonatomic,copy)NSString *url;
@property (nonatomic,copy)NSString *createDate;
@property (nonatomic,strong)UIImage *image;
@property (nonatomic,assign)BOOL isUsed;//判断是否使用了
@end

