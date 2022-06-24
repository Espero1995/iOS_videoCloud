
//  JWcameraModelManger.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "JWcameraModelManger.h"

@interface JWcameraModelManger()
@property (nonatomic, strong) NSMutableArray * coverImageArr;/**< 装封面图片数组 */

@end

@implementation JWcameraModelManger

HDSingletonM(JWcameraModelManger)

- (void)setCameraDeviceConverImageSuccess:(Success)success Failure:(Failure)failure
{
    
    NSOperationQueue * downloadConverImageQueue = [[NSOperationQueue alloc]init];
    downloadConverImageQueue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation * op1 = [NSBlockOperation blockOperationWithBlock:^{
        
          }];
        NSArray * tempCameraDeviceModel = [unitl getCameraGroupDeviceModelIndex:0];
        NSInteger tempArrCount = [tempCameraDeviceModel count];
        NSLog(@"走啦啊啊啊啊啊0000");
        for (int i = 0; i < tempArrCount; i++) {
            dev_list *listModel = (dev_list *)tempCameraDeviceModel[i];
            self.bIsEncrypt = listModel.enable_sec;
            self.key = listModel.dev_p_code;
            NSLog(@"走啦啊啊啊啊啊1111==%@",self.key);
            NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
            [changeDic setObject:listModel.ID forKey:@"dev_id"];
            [changeDic setObject:@"1" forKey:@"chan_id"];
            if (listModel.status == 1) {
                
                [[HDNetworking sharedHDNetworking]POST:@"v1/device/capture" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
                    int ret = [responseObject[@"ret"]intValue];
                    if (ret == 0) {
                        UIImage * coverImage = [[JWfileManager sharedJWfileManager]getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                        UIImageView * coverIV = [[UIImageView alloc]initWithImage:coverImage ? coverImage : DefaultDeviceCoverImage];
                        listModel.coverImageView = coverIV;
                        
                        NSDictionary * dic = responseObject[@"body"];
                        NSString * urlStr = [dic objectForKey:@"pic_url"];
                        NSURL * picUrl = [NSURL URLWithString:urlStr];
                        NSLog(@"走啦啊啊啊啊啊2222===%@===图片地址：%@",self.key,picUrl);
                        if (self.bIsEncrypt) {
                            NSURLRequest *request = [NSURLRequest requestWithURL:picUrl];
                            __block UIImage * image;
                            
                            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {//[[NSOperationQueue alloc] init]   [NSOperationQueue mainQueue]
                                //NSLog(@"收到图片的data：%@---长度：%zd",response,data.length);
                                const unsigned char *imageCharData=(const unsigned char*)[data bytes];
                                size_t len = [data length];
                                
                                unsigned char outImageCharData[len];
                                size_t outLen = len;
                                
                                NSLog(@"走啦啊啊啊啊啊ppppp 收到图片长度：%zu 是否被16整除：%@   图片下载请求是否成功：%@",len,len %16 == 0?@"是":@"不是",[((NSHTTPURLResponse *)response) statusCode] == 200?@"是":@"不是");
                                if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200) {
                                    int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
                                    if (decrptImageSucceed == 1) {
                                        NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                                        image  = [UIImage imageWithData:imageData];
                                        listModel.coverImageView.image = image;
                                        [self.coverImageArr addObject:listModel];
                                        NSLog(@"走啦啊啊啊啊啊3333");
                                    }
                                }
                            }];
                        }
                    }
                } failure:^(NSError * _Nonnull error) {
                    UIImage *cutIma = [[JWfileManager sharedJWfileManager]getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                    listModel.coverImageView.image = cutIma ? cutIma : DefaultDeviceCoverImage;
                }];
            }
        }
    NSBlockOperation * op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"走啦啊啊啊啊啊4444");
        [unitl saveCameraModel:self.coverImageArr];
        success(@"succeed");
    }];
    [op2 addDependency:op1];
    [downloadConverImageQueue addOperation:op2];
    [downloadConverImageQueue addOperation:op1];
}

- (UIImage *)getCameraDeviceConverImageIndex:(NSInteger)index2
{
    NSArray * tempArr = [unitl getCameraModel];
    UIImage * tempConverImage;
    if (tempArr.count > 0) {
         tempConverImage = ((dev_list *)tempArr[index2]).coverImageView.image;
    }
    return tempConverImage?tempConverImage:DefaultDeviceCoverImage;
}

- (void)testMethod
{
    
}

#pragma mark - getter && setter
/*解码器*/
- (JW_CIPHER_CTX)cipher
{
    if (self.key && self.bIsEncrypt) {
        size_t len = strlen([self.key cStringUsingEncoding:NSASCIIStringEncoding]);
        _cipher =  jw_cipher_create((const unsigned char*)[self.key cStringUsingEncoding:NSASCIIStringEncoding], len);
        NSLog(@"创建cipher：%p==self.key：%@====self.bIsEncrypt:%@",&_cipher,self.key,self.bIsEncrypt?@"YES":@"NO");
    }
    return _cipher;
}

- (NSMutableArray *)coverImageArr
{
    if (!_coverImageArr) {
        _coverImageArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _coverImageArr;
}

@end
