//
//  FileCollectionCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/25.
//  Copyright © 2018 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
@interface FileCollectionCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) IBOutlet UIView *bottomBgView;
@property (strong, nonatomic) IBOutlet UIImageView *isVideoImg;
@property (nonatomic,strong) FileModel *model;
@property (nonatomic,strong) UIButton *chooseBtn;
@end

