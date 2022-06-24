//
//  AboutUsRelatedView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/21.
//  Copyright © 2018 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AboutUsRelatedViewDelegate <NSObject>
- (void)agreementBtnAction;
- (void)websiteBtnAction;
- (void)WeChatBtnAction;
- (void)telBtnAction;
@end

@interface AboutUsRelatedView : UIView
@property (nonatomic,weak)id<AboutUsRelatedViewDelegate>delegate;
+(instancetype)viewFromXib;
@end
