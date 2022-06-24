//
//  VideoPlayView.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/2.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZCVideoPlayView.h"

@interface JWPlayView : UIView
@property (weak, nonatomic) IBOutlet ZCVideoPlayView *openView;
+(instancetype)viewFromXib;

@end
