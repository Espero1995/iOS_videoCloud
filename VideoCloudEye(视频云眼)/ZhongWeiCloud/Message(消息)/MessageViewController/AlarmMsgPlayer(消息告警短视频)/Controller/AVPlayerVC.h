//
//  AVPlayerVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2020/2/20.
//  Copyright © 2020 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVPlayerVC : BaseViewController
//title
@property (nonatomic,copy) NSString *videoTitle;
//告警url
@property (nonatomic,copy) NSString *videoUrl;
@end

NS_ASSUME_NONNULL_END
