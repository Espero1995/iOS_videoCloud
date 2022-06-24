//
//  ZCVideoTimeModel.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/22.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZCVideoTimeModel : NSObject
@property (nonatomic,assign)CGFloat benginTime;
@property (nonatomic,assign)CGFloat endTime;
@property (nonatomic,copy)NSString *palyBackUrl;
@property (nonatomic,copy)NSString *downloadUrl;
@property (nonatomic, copy) NSString* name;/**< 这段视频的文件名称 */

@end
