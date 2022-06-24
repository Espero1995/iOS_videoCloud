//
//  electronicControlView.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2019/3/12.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum electronicControlBtnType {
    electronicControlBtnType_subtract  = 10,
    electronicControlBtnType_plus,
} electronicControlBtnType;

@protocol electronicControlViewDelegate <NSObject>

- (void)electronicControlVCAction:(UIButton*)btn;

- (void)electronicControlVCStopAction:(UIButton*)btn;

@end

@interface electronicControlView : UIView
@property (nonatomic, assign) id<electronicControlViewDelegate> delegate;/**< 代理指针 */

@end


