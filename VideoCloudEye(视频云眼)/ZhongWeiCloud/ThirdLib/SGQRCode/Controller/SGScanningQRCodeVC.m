//
//  SGScanningQRCodeVC.m
//  SGQRCodeExample
//
//  Created by Sorgle on 16/8/25.
//  Copyright © 2016年 Sorgle. All rights reserved.
//
//  - - - - - - - - - - - - - - 交流QQ：1357127436 - - - - - - - - - - - - - - - //
//
//  - - 如在使用中, 遇到什么问题或者有更好建议者, 请于 kingsic@126.com 邮箱联系 - - - - //
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  - - GitHub下载地址 https://github.com/kingsic/SGQRCode.git - - - - - - - - - //
//
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //

#import "SGScanningQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "SGScanningQRCodeView.h"
#import "ScanSuccessJumpVC.h"
#import "SGQRCodeTool.h"
#import <Photos/Photos.h>
#import "SGAlertView.h"

#import "RcodeShowController.h"
#import "InputSerialNumVC.h"//手动输入序列号界面
#import "ConfigTypeVC.h"//设备配置类型选择VC
#import "DeviceConfigModel.h"//设备配置的model
#import "ConfigSuccessVC.h"//配置成功界面
#import "ConfigOccupiedVC.h"//设备被他人已占用界面
#import "ZCTabBarController.h"

@interface SGScanningQRCodeVC () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,SGAlertViewDelegate>
/** 会话对象 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 图层类 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) SGScanningQRCodeView *scanningView;

@property (nonatomic, assign) BOOL first_push;
//闪光灯
@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic,assign)BOOL isOpen;
@end

@implementation SGScanningQRCodeVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

   
    // 创建扫描边框
//    self.scanningView = [[SGScanningQRCodeView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height) outsideViewLayer:self.view.layer];
    [self.view addSubview:self.scanningView];
    // 二维码扫描
    [self setupScanningQRCode];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (isMainAccount) {
        self.navigationItem.title = NSLocalizedString(@"添加设备", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"配置设备", nil);
    }
    
    self.isOpen = NO;
//    // 二维码扫描
//    [self setupScanningQRCode];
    self.first_push = YES;
    [self cteateNavBtn];
    // rightBarButtonItem
    [self setupRightBarButtonItem];
    
}

// rightBarButtonItem
- (void)setupRightBarButtonItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"inputSerialNum"] style:UIBarButtonItemStyleDone target:self action:@selector(inpueSerialNumClick)];
    [self.navigationItem.rightBarButtonItem setImage:[[UIImage imageNamed:@"inputSerialNum"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}
#pragma mark - 手动输入序列号界面
- (void)inpueSerialNumClick
{
    InputSerialNumVC *inputVC = [[InputSerialNumVC alloc]init];
    [self.navigationController pushViewController:inputVC animated:YES];
}


/*
#pragma mark ------打开闪光灯
#pragma mark - - - 照明灯的点击事件
- (void)light_buttonAction{
    self.isOpen = !self.isOpen;
    if (self.isOpen) {
         [self turnOnLight:self.isOpen];
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"QRCodeLight"] style:UIBarButtonItemStyleDone target:self action:@selector(light_buttonAction)];
    }else{
         [self turnOnLight:self.isOpen];
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"QRCodeLightClose"] style:UIBarButtonItemStyleDone target:self action:@selector(light_buttonAction)];
        [self.navigationItem.rightBarButtonItem setImage:[[UIImage imageNamed:@"QRCodeLightClose"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
}

- (void)turnOnLight:(BOOL)on {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (on) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode: AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}
*/
#pragma mark - - - rightBarButtonItenAction 的点击事件
- (void)rightBarButtonItenAction {
    [self readImageFromAlbum];
}
#pragma mark - - - 从相册中读取照片
- (void)readImageFromAlbum {
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        // 判断授权状态
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
            // 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { // 用户点击了好
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init]; // 创建对象
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
                        imagePicker.delegate = self; // 指定代理，因此我们要实现UIImagePickerControllerDelegate,  UINavigationControllerDelegate协议
                        [self presentViewController:imagePicker animated:YES completion:nil]; // 显示相册
                        NSLog(@"主线程 - - %@", [NSThread currentThread]);
                    });
                    NSLog(@"当前线程 - - %@", [NSThread currentThread]);
                    
                    // 用户第一次同意了访问相册权限
                    NSLog(@"用户第一次同意了访问相册权限");
                } else {
                    // 用户第一次拒绝了访问相机权限
                    NSLog(@"用户第一次拒绝了访问相册");
                }
            }];
       
        } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前应用访问相册
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init]; // 创建对象
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
            imagePicker.delegate = self; // 指定代理，因此我们要实现UIImagePickerControllerDelegate,  UINavigationControllerDelegate协议
            [self presentViewController:imagePicker animated:YES completion:nil]; // 显示相册

        } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册
            [unitl createAlertActionWithTitle:NSLocalizedString(@"已为“视频云眼”关闭相机", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开相机", nil) andController:self];
        } else if (status == PHAuthorizationStatusRestricted) {
            NSLog(@"因为系统原因, 无法访问相册");
        }
        
    } else {
        SGAlertView *alertView = [SGAlertView alertViewWithTitle:NSLocalizedString(@"温馨提示", nil) delegate:nil contentTitle:NSLocalizedString(@"未检测到您的摄像头", nil) alertViewBottomViewType:(SGAlertViewBottomViewTypeOne)];
        [alertView show];
    }
}
#pragma mark - - - UIImagePickerControllerDelegate
/*
// 此方法，已过期
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {

    [self dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:image];
    }];
}
*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info - - - %@", info);
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    }];
}
#pragma mark - - - 从相册中识别二维码, 并进行界面跳转
- (void)scanQRCodeFromPhotosInTheAlbum:(UIImage *)image {
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    NSLog(@"扫描结果 － － %@", features);
    
    for (int index = 0; index < [features count]; index ++) {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *scannedResult = feature.messageString;
        NSLog(@"result:%@",scannedResult);
        
        if (self.first_push) {
            ScanSuccessJumpVC *jumpVC = [[ScanSuccessJumpVC alloc] init];
            jumpVC.jump_URL = scannedResult;
            [self.navigationController pushViewController:jumpVC animated:YES];
            
            self.first_push = NO;
        }
    }
}

#pragma mark - - - 二维码扫描
- (void)setupScanningQRCode {
    // 初始化链接对象（会话对象）
    self.session = [[AVCaptureSession alloc] init];
    // 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    [SGQRCodeTool SG_scanningQRCodeOutsideVC:self session:_session previewLayer:_previewLayer];
    
}

#pragma mark - - - 二维码扫描代理方法
// 调用代理方法，会频繁的扫描
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    // 0、扫描成功之后的提示音
    [self playSoundEffect:@"sound.caf"];

    // 1、如果扫描完成，停止会话
//    [self.session stopRunning];
    
    // 2、删除预览图层
//    [self.previewLayer removeFromSuperlayer];
    
    // 3、设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        NSLog(@"二维码显示扫描结果 = %@", metadataObjects);
        
       // 扫描结果为条形码
            NSString *rcodeStr = obj.stringValue;
//            000123456789；123456；OB-CN7016-H10/DIWS
            NSRange range = [rcodeStr rangeOfString:@";"];
            if (range.location!=NSNotFound) {
                NSArray *rcodeArr = [rcodeStr componentsSeparatedByString:@";"];
                NSLog(@"数组显示结果：%@",rcodeArr);
                if (rcodeArr.count == 3) {
                    
                    /* TODO
                    NSString *deveid = rcodeArr[2];
                    NSString *erialNumber = rcodeArr[0];
                    NSString *check_code = rcodeArr[1];
                    RcodeShowController *showVc = [[RcodeShowController alloc]init];
                    showVc.deveId = deveid;
                    showVc.erialNumber = erialNumber;
                    showVc.check_code = check_code;
                    [self.navigationController pushViewController:showVc animated:YES];
                    */
                    [self.session stopRunning];
                    
                    if (isMainAccount) {
                        //获取设备归属
                        [self getDevMsg:rcodeArr];
                    }else{
                        [self filterNotOwnerDevice:rcodeArr];
                    }
                    
                    
                    
                }
                else{
//                    SGAlertView *alertView = [SGAlertView alertViewWithTitle:NSLocalizedString(@"温馨提示", nil) delegate:nil contentTitle:NSLocalizedString(@"无法识别二维码，您可通过屏幕右上角按钮手动输入", nil) alertViewBottomViewType:(SGAlertViewBottomViewTypeOne)];
//                    alertView.delegate_SG = self;
//                    [alertView show];
                    [self.session stopRunning];
                    [XHToast showCenterWithText:NSLocalizedString(@"无法识别二维码，您可通过屏幕右上角按钮手动输入", nil)];
                    
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                    dispatch_after(time, dispatch_get_main_queue(), ^(void){
                        [self.session startRunning];
                    });
                    
                }
            }else {
//                SGAlertView *alertView = [SGAlertView alertViewWithTitle:NSLocalizedString(@"温馨提示", nil) delegate:nil contentTitle:NSLocalizedString(@"无法识别二维码，您可通过屏幕右上角按钮手动输入", nil) alertViewBottomViewType:(SGAlertViewBottomViewTypeOne)];
//                alertView.delegate_SG = self;
//                [alertView show];
                [self.session stopRunning];
                [XHToast showCenterWithText:NSLocalizedString(@"无法识别二维码，您可通过屏幕右上角按钮手动输入", nil)];
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^(void){
                    [self.session startRunning];
                });
            }
        }
    
}
- (void)didSelectedRightButtonClick
{
//    [self setupScanningQRCode];
}

#pragma mark - - - 扫描提示声
/** 播放音效文件 */
- (void)playSoundEffect:(NSString *)name{
    // 获取音效
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;

    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    // 如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */
void soundCompleteCallback(SystemSoundID soundID, void *clientData){
    NSLog(@"播放完成...");
}

#pragma mark - - - 移除定时器
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 1、停止会话
    [self.session stopRunning];
    // 2、删除预览图层
    [self.previewLayer removeFromSuperlayer];
}

-(void)dealloc
{
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
}

-(SGScanningQRCodeView *)scanningView{
    if (!_scanningView) {
        //iOS 系统版本11前后导航栏有所区别
        float scanningY;
        
        scanningY = 0.0f;
        _scanningView = [[SGScanningQRCodeView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-scanningY, self.view.frame.size.width, self.view.frame.size.height) outsideViewLayer:self.view.layer];
        /*
        if (@available(iOS 11.0, *)) {
            scanningY = 64.0f;
        }else{
            scanningY = 0.0f;
        }
        if (iPhone_X_TO_Xs) {
            _scanningView = [[SGScanningQRCodeView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-scanningY-24, self.view.frame.size.width, self.view.frame.size.height) outsideViewLayer:self.view.layer];
        }else{
            _scanningView = [[SGScanningQRCodeView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-scanningY, self.view.frame.size.width, self.view.frame.size.height) outsideViewLayer:self.view.layer];
        }
         */
    }
    return _scanningView;
}


#pragma mark - 过滤并不是属于自己的设备
- (void)filterNotOwnerDevice:(NSArray *)rcodeArr
{
    NSString *deviceID = rcodeArr[0];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:deviceID forKey:@"deviceId"];
    [[HDNetworking sharedHDNetworking]GET:@"open/deviceTree/canOperate" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"过滤是不是属于自己的设备:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            BOOL isDirectory = [responseObject[@"body"] boolValue];
            if (isDirectory) {
                //跳转到设备配网页面
                [self getDevMsg:rcodeArr];
            }else{
                [XHToast showCenterWithText:@"该设备不在您当前文件夹下，无法进行配置"];
            }
        }else{
            [XHToast showCenterWithText:@"设备配置失败，请稍候再试"];
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [self.session startRunning];
            });
            
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:@"设备配置失败，请检查您的网络"];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void){
            [self.session startRunning];
        });
    }];
}


#pragma mark - 获取设备归属
- (void)getDevMsg:(NSArray *)rcodeArr
{
    NSString *deviceID = rcodeArr[0];
    NSString *checkCode = rcodeArr[1];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:deviceID forKey:@"dev_id"];
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/getowner" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"后台返回，获取设备归属信息:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        
        DeviceConfigModel *model = [[DeviceConfigModel alloc]init];
        model.deviceId = deviceID;
        model.checkCode = checkCode;
        
        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            NSString * ower_id = bodyDic[@"owner_id"];
            NSString * vender = bodyDic[@"vender"];
            NSString *enableWifi = bodyDic[@"wifi_enable"];//是否是通过wifi来配置的
            
            NSLog(@"ower_id:%@===%ld",ower_id,[ower_id length]);
            model.enableWifi = [enableWifi intValue];
            model.deviceType = bodyDic[@"dev_type"];
            
            //图片
            NSString *tempImgUrl = [NSString stringWithFormat:@"%@1.png",[bodyDic objectForKey:@"dev_img"]];
            model.devImgURL = tempImgUrl;

            [[NSUserDefaults standardUserDefaults]setObject:vender forKey:@"vender"];
            
            
            if (isMainAccount) {
                if ((NSNull *)ower_id == [NSNull null]){
                    //查看设备状态(是否在线)
                    [self getDevStatus:model];
                    [self.session stopRunning];
                    self.scanningView.light_button.selected = NO;
                }else{
                    [self.session stopRunning];
                    self.scanningView.light_button.selected = NO;
                    //已经归属别人，跳转到归属别人的界面
                    ConfigOccupiedVC *occupiedVC = [[ConfigOccupiedVC alloc]init];
                    occupiedVC.configModel = model;
                    occupiedVC.title = NSLocalizedString(@"添加设备", nil);
                    [self.navigationController pushViewController:occupiedVC animated:YES];
                }
            }else{
                //查看设备状态(是否在线)
                [self getDevStatus:model];
            }
            
            
            
            
            
        }else{//ret == -1
            self.scanningView.light_button.selected = NO;
            [XHToast showCenterWithText:NSLocalizedString(@"无效的序列号", nil)];
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [self.session startRunning];
            });
        }
    } failure:^(NSError * _Nonnull error) {
        self.scanningView.light_button.selected = NO;
        [XHToast showCenterWithText:NSLocalizedString(@"扫描失败，请检查您的网络", nil)];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void){
            [self.session startRunning];
        });
    }];
    
}


#pragma mark - 查看设备状态(是否在线)
- (void)getDevStatus:(DeviceConfigModel *)configModel
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:configModel.deviceId forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getstatus" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
//        NSLog(@"获取设备在线状态responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            BOOL isLine = [bodyDic[@"status"] boolValue];
            NSLog(@"查询设备是否在线：%@",isLine?@"在线":@"不在线");
            if (!isLine) {
                //跳转到配置界面
                ConfigTypeVC *configVC = [[ConfigTypeVC alloc]init];
                configVC.configModel = configModel;
                [self.navigationController pushViewController:configVC animated:YES];
            }else{
                
                if (isMainAccount) {
                    //跳转到添加界面
                    ConfigSuccessVC *configVC = [[ConfigSuccessVC alloc]init];
                    configVC.configModel = configModel;
                    configVC.title = NSLocalizedString(@"添加设备", nil);
                    [self.navigationController pushViewController:configVC animated:YES];
                }else{
                    [XHToast showCenterWithText:@"设备已在您当前目录下"];
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                    dispatch_after(time, dispatch_get_main_queue(), ^(void){
                        [self.session startRunning];
                    });
                }
                
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"扫描失败，请检查您的网络", nil)];
    }];
}


@end

/*
 
 二维码扫描的步骤：
     1、创建设备会话对象，用来设置设备数据输入
     2、获取摄像头，并且将摄像头对象加入当前会话中
     3、实时获取摄像头原始数据显示在屏幕上
     4、扫描到二维码/条形码数据，通过协议方法回调
 
 AVCaptureSession 会话对象。此类作为硬件设备输入输出信息的桥梁，承担实时获取设备数据的责任
 AVCaptureDeviceInput 设备输入类。这个类用来表示输入数据的硬件设备，配置抽象设备的port
 AVCaptureMetadataOutput 输出类。这个支持二维码、条形码等图像数据的识别
 AVCaptureVideoPreviewLayer 图层类。用来快速呈现摄像头获取的原始数据
 二维码扫描功能的实现步骤是创建好会话对象，用来获取从硬件设备输入的数据，并实时显示在界面上。在扫描到相应图像数据的时候，通过AVCaptureVideoPreviewLayer类型进行返回
 
 */

