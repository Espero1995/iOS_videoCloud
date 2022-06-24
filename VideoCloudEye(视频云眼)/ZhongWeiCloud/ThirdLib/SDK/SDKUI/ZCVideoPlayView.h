//
//  ZCVideoPlayView.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/11/11.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ZCVideoPlayView : UIView
@property (nonatomic , assign) BOOL isFullYUVRange;
@property (nonatomic,assign)CGFloat videoScale;

//初始化
- (void)setupGL;
//传入buffer
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer playViewSize:(CGSize)size;
//清空背景颜色
- (void)cleanBackColor;
@end
