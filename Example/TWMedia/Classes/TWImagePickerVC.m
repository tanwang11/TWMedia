//
//  TWImagePickerVC.m
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

// 本M基本上是复制的SKFCamera.m文件,需要在此基础上修改程序.

#define KScreenSize   [UIScreen mainScreen].bounds.size
#define KScreenwidth  [UIScreen mainScreen].bounds.size.width
#define KScreenheight [UIScreen mainScreen].bounds.size.height
#define IsIphone6P    KScreenSize.width==414
#define IsIphone6     KScreenSize.width==375
#define IsIphone5S    KScreenSize.height==568
#define IsIphone5     KScreenSize.height==568
//456字体大小
#define KIOS_Iphone456(iphone6p,iphone6,iphone5s,iphone5,iphone4s) (IsIphone6P?iphone6p:(IsIphone6?iphone6:((IsIphone5S||IsIphone5)?iphone5s:iphone4s)))
//宽高
#define KIphoneSize_Widith(iphone6) (IsIphone6P?1.104*iphone6:(IsIphone6?iphone6:((IsIphone5S||IsIphone5)?0.853*iphone6:0.853*iphone6)))
#define KIphoneSize_Height(iphone6) (IsIphone6P?1.103*iphone6:(IsIphone6?iphone6:((IsIphone5S||IsIphone5)?0.851*iphone6:0.720*iphone6)))


#import "TWImagePickerVC.h"
#import "TOCropViewController.h"
#import "TWImagePreviewCC.h"
#import "TWImagePreviewVC.h"
#import <TWUI/TWUI.h>
#import "TWImageEntity.h"


@import CoreMotion;

@interface TWImagePickerVC ()<TOCropViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

// 获取当前设备方向
@property (nonatomic, strong) CMMotionManager * motionManager;
@property (nonatomic, copy  ) TWImagePickerFinishBlock finishBlock;

@end

@implementation TWImagePickerVC

// 大于1张的话,不开启编辑图片功能.
- (id)initWithMaxNum:(int)maxNum singleOrigin:(BOOL)singleOrigin finishBlock:(TWImagePickerFinishBlock)block {
    if (self = [super init]) {
        _maxNum       = maxNum;
        _singleOrigin = singleOrigin;
        _finishBlock  = block;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.camera start];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_motionManager startDeviceMotionUpdates];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_motionManager stopDeviceMotionUpdates];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame  = self.view.frame;
    self.snapButton.frame   = CGRectMake((KScreenwidth-KIphoneSize_Widith(75))/2, KScreenheight-KIphoneSize_Widith(90), KIphoneSize_Widith(75), KIphoneSize_Widith(75));
    self.flashButton.frame  = CGRectMake((KScreenwidth-KIphoneSize_Widith(36))/2, 25, KIphoneSize_Widith(36), KIphoneSize_Widith(44));
    self.switchButton.frame = CGRectMake(KScreenwidth-50, KScreenheight-KIphoneSize_Widith(75), KIphoneSize_Widith(45), KIphoneSize_Widith(45));
    self.backButton.frame   = CGRectMake(5, KScreenheight-KIphoneSize_Widith(75), KIphoneSize_Widith(45), KIphoneSize_Widith(45));
    
    //self.completeBT.frame = CGRectMake(CGRectGetMaxX(self.backButton.frame) + 20, self.backButton.frame.origin.y, self.backButton.frame.size.width, self.backButton.frame.size.height);
    if (self.maxNum > 1) {
        self.completeBT.center = CGPointMake(CGRectGetMaxX(self.backButton.frame) + 20 + self.completeBT.frame.size.width/2, self.backButton.center.y);
        self.previewCV.bottom = self.snapButton.y - 15;
    }
    if (self.appearBlock) {
        CGRect availableRect = CGRectMake(0, self.flashButton.bottom, self.view.width, self.snapButton.top-self.flashButton.bottom);
        self.appearBlock(self, availableRect);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startMotionManager];
    [self InitializeCamera];
    [self addViews];
    
    // 假如没有权限这里会触发跳转set方法.
    [UIDevice isHaveSysPermissionCameraBlock:^(BOOL isFirst, BOOL isHavePermission) {
        if (isHavePermission) {
            
        }
    }];
}

- (void)addViews {
    //拍照按钮
    if (!self.snapButton) {
        self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.snapButton.clipsToBounds = YES;
        self.snapButton.layer.cornerRadius =75 / 2.0f;
        [self.snapButton setImage:[TWMediaImageBundle imageBundleNamed:@"cameraButton"] forState:UIControlStateNormal];
        [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.snapButton];
    }
    //闪关灯按钮
    if (!self.flashButton) {
        
        self.flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        self.flashButton.tintColor = [UIColor whiteColor];
        
        [self.flashButton setImage:[TWMediaImageBundle imageBundleNamed:@"camera-flash"] forState:UIControlStateNormal];
        self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.flashButton];
        
        
    }
    UIImage * backImage = [TWMediaImageBundle imageBundleNamed:@"closeButton"];
    if (!self.backButton) {
        if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
            //摄像头转换按钮
            self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            // self.switchButton.tintColor = [UIColor whiteColor];
            [self.switchButton setImage:[TWMediaImageBundle imageBundleNamed:@"swapButton"] forState:UIControlStateNormal];
            [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.switchButton];
            //返回按钮
            self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [self.backButton setImage:backImage forState:UIControlStateNormal];
            [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.backButton];
        }
    }
    if (self.maxNum > 1) {
        if (!self.completeBT) {
            self.completeBT = [UIButton buttonWithType:UIButtonTypeSystem];
            self.completeBT.hidden = YES;
            self.completeBT.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
            self.completeBT.titleLabel.font = [UIFont systemFontOfSize:15];
            [self.completeBT setTitle:@"完成" forState:UIControlStateNormal];
            [self.completeBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            // 0X38404a
            [self.completeBT setBackgroundColor:[UIColor colorWithRed:0.219 green:0.251 blue:0.29 alpha:0.5]];
            // [self.completeBT setBackgroundColor:RGB16A(0X38404a, 0.5)];
            self.completeBT.layer.cornerRadius = self.completeBT.frame.size.width/2;
            self.completeBT.clipsToBounds = YES;
            
            [self.completeBT addTarget:self action:@selector(multiImageCompleteEvent) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.completeBT];
            
            self.imageArray = [NSMutableArray new];
        }
        if (!self.previewCV) {
            self.previewCV = [self addCV];
            self.previewCV.hidden = YES;
        }
    }
}

- (UICollectionView *)addCV {
    float gap   = 10;
    int colume  = 4;
    float width = (KScreenSize.width - gap*(colume-1))/colume;
    self.ccSize = CGSizeMake(width, width);
    
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    //layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 20);
    //该方法也可以设置itemSize
    //layout.itemSize =CGSizeMake(110, 150);
    
    //2.初始化collectionView
    UICollectionView * cv = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.ccSize.height+ 12) collectionViewLayout:layout];
    cv.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    cv.indicatorStyle  = UIScrollViewIndicatorStyleWhite;
    cv.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -1.5, 0);
    
    [self.view addSubview:cv];
    //cv.backgroundColor = [UIColor clearColor];
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [cv registerClass:[TWImagePreviewCC class] forCellWithReuseIdentifier:@"cellId"];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    //[cv registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    
    //4.设置代理
    cv.delegate   = self;
    cv.dataSource = self;
    
    //    __weak typeof (self) weakSelf = self;
    //    [cv mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.center.equalTo(weakSelf.view);
    //        make.edges.mas_offset(UIEdgeInsetsMake(0, 0, 0, 0));
    //    }];
    
    return cv;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TWImagePreviewCC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    TWImageEntity * entity = self.imageArray[indexPath.row];
    //NSLog(@"cell index: %i, 小hash:%li, 大hash:%li", (int)indexPath.row, entity.smallImage.hash, entity.bigImage.hash);
    [cell setImageEntity:entity];
    return cell;
}

#pragma layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.ccSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
#pragma mark - 打开图片大图
    @weakify(self);
    @weakify(collectionView);
    TWImagePreviewVC *photoBrower = [[TWImagePreviewVC alloc] initWithIndex:indexPath.item copyImageArray:nil weakImageArray:self.imageArray presentVC:self originImageBlock:^UIImageView *(TWImageBrower *browerController, NSInteger index) {
        @strongify(self);
        @strongify(collectionView);
        
        NSIndexPath * ip = [NSIndexPath indexPathForItem:index inSection:0];
        [collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        TWImagePreviewCC *cell = (TWImagePreviewCC *)[collectionView cellForItemAtIndexPath:ip];
        // 这里的cell会在关闭的block中返回nil,找不到原因.
        return cell.iconIV;
        
    } disappearBlock:^(TWImageBrower *browerController, NSInteger index) {
        @strongify(collectionView);
        
        [collectionView reloadData];
        
    } placeholderImageBlock:^UIImage *(TWImageBrower *browerController) {
        //return [UIImage imageNamed:@"placeholder"];
        return nil;
    }];
    photoBrower.completeBlock = ^{
        @strongify(self);
        [self multiImageCompleteEvent];
    };
    [photoBrower show];
}

#pragma mark   ------------- 初始化相机--------------
-(void)InitializeCamera {
    CGRect screenRect = self.view.frame;
    
    // 创建一个相机, 这里和原作者方式不一样,不需要获取用户的Aduio权限
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh position:LLCameraPositionRear videoEnabled:NO];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    @weakify(self);
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        @strongify(self);
        
        //NSLog(@"Device changed.");
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            self.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                self.flashButton.selected = NO;
            } else {
                self.flashButton.selected = YES;
            }
        } else {
            self.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        @strongify(self);
        
        NSLog(@"TWMedia Camera error: %@", error);
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission) {
                if(self.errorLabel) {
                    [self.errorLabel removeFromSuperview];
                }
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"未获取相机权限";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                self.errorLabel = label;
                [self.view addSubview:self.errorLabel];
            }
        }
    }];
}

//作者：redihd
//链接：https://www.jianshu.com/p/692e7a490747
//來源：简书
//著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button {
    [self.camera togglePosition];
}

-(void)backButtonPressed:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)flashButtonPressed:(UIButton *)button {
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    } else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

#pragma mark   -------------拍照--------------
- (void)snapButtonPressed:(UIButton *)button {
    @weakify(self);
    if (self.maxNum == 1) {
        // 去裁剪
        [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            @strongify(self);
            
            //NSLog(@"拍照结束");
            if(!error) {
                // 修正屏幕方向
                image = [self correctImageOritation:image];
                if (self.isSingleOrigin) {
                    if (self.finishBlock) {
                        self.finishBlock(@[image]);
                    }
                    // !!! 需要修改,单张的和多张的处理方式不一样.
                    [self dismissViewControllerAnimated:NO completion:nil];
                }else{
                    TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:image];
                    cropController.delegate = self;
                    [self presentViewController:cropController animated:YES completion:nil];
                }
            }
            else {
                NSLog(@"TWMedia An error has occured: %@", error);
            }
        } exactSeenImage:YES];
    }else if (self.maxNum > 1) {
        [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            @strongify(self);
            //NSLog(@"拍了一张照片");
            if(!error) {
                // 修正屏幕方向
                image = [self correctImageOritation:image];
                
                TWImageEntity * entity = [TWImageEntity new];
                entity.bigImage   = image;
                entity.smallImage = [UIImage imageFromImage:image size:self.ccSize];
                entity.ignore     = NO;
                
                [self.imageArray addObject:entity];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"得到了刚刚拍摄的的图片.");
                    self.completeBT.hidden = NO;
                    self.previewCV.hidden  = NO;
                    [self.previewCV reloadData];
                    
                    [self.previewCV selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.imageArray.count-1 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionRight];
                });
            }else {
                NSLog(@"TWMedia An error has occured: %@", error);
            }
        } exactSeenImage:YES];
    }
}

- (UIImage *)correctImageOritation:(UIImage *)image {
    UIDeviceOrientation orientation = [self handleDeviceMotion:self.motionManager.deviceMotion];
    //NSLog(@"oritation: %i", (int)orientation);
    UIImageOrientation imageOritation;
    switch (orientation) {
            
        case UIDeviceOrientationLandscapeLeft:
            imageOritation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOritation = UIImageOrientationDown;
            break;
            
            // 这几个都处理成默认
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            imageOritation = UIImageOrientationRight;
            break;
        default:
            imageOritation = UIImageOrientationRight;
            break;
    }
    image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:imageOritation];
    
    [UIDevice isHaveSysPowerForAlbumAlert:NO block:^(BOOL isFirst, BOOL isHavePermission) {
        if (isHavePermission) {
            //[UIDevice saveImageToPhotos:image showAlert:NO];
            [UIDevice saveImage:image imageUrl:nil videoUrl:nil collectionName:nil showAlert:NO];
        }
    }];
    
    return image;
    //image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:image.imageOrientation];
}

#pragma mark - 陀螺仪检测
- (void)startMotionManager {
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    // 以下代码是为了处理实时检测,本代码只需要最后一步检测,所以不需要这么频繁
    //    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    //    __weak typeof(self) weakSelf = self;
    //    if (_motionManager.deviceMotionAvailable) {
    //        NSLog(@"Device Motion Available");
    //        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
    //            [weakSelf performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
    //        }];
    //    } else {
    //        NSLog(@"No device motion on device.");
    //        [self setMotionManager:nil];
    //    }
}

- (UIDeviceOrientation)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    
    //    UIInterfaceOrientation orientation;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0){
            // UIDeviceOrientationPortraitUpsideDown;
            //NSLog(@"UIDeviceOrientationPortraitUpsideDown");
            return UIDeviceOrientationPortraitUpsideDown;
        } else{
            // UIDeviceOrientationPortrait;
            //NSLog(@"UIDeviceOrientationPortrait");
            return UIDeviceOrientationPortrait;
        }
    } else {
        if (x >= 0){
            // UIDeviceOrientationLandscapeRight;
            //NSLog(@"UIDeviceOrientationLandscapeRight");
            return UIDeviceOrientationLandscapeRight;
        } else{
            // UIDeviceOrientationLandscapeLeft;
            //NSLog(@"UIDeviceOrientationLandscapeLeft");
            return UIDeviceOrientationLandscapeLeft;
        }
    }
}
//作者：redihd
//链接：https://www.jianshu.com/p/692e7a490747
//來源：简书
//著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

- (void)multiImageCompleteEvent {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.finishBlock) {
            NSMutableArray * array = [NSMutableArray new];
            for (TWImageEntity * entity in self.imageArray) {
                if (!entity.isIgnore) {
                    [array addObject:entity.bigImage];
                }
            }
            self.finishBlock(array);
        }
    }];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle{
    self.view.alpha = 0;
    // MARK: 单张拍摄完成
    if (self.finishBlock) {
        self.finishBlock(@[image]);
    }
    
    // !!! 需要修改,单张的和多张的处理方式不一样.
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
