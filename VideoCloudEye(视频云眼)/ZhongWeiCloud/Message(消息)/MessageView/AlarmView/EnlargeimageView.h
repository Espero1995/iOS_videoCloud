//
//  EnlargeimageView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/17.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnlargeimageView : UIView

/**
 返回这个View
 
 @param frame view的大小
 @return 返回这个View
 */
- (instancetype)initWithframe:(CGRect) frame;
@property (nonatomic, strong) UIImage *enlargeImage;
@property (nonatomic, copy) NSString *imageUrl;

- (void)enlargeImageClick;

@end
