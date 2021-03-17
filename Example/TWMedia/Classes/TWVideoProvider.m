//
//  TWVideoProvider.m
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import "TWVideoProvider.h"
#import <UIKit/UIKit.h>

// 拍摄视频
#import <MobileCoreServices/MobileCoreServices.h>
#import <TWUI/TWUI.h>
#import <TWFoundation/TWFoundation.h>

@interface TWVideoProvider ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end


@implementation TWVideoProvider

- (id)init {
    if (self = [super init]) {
        _qualityType = -1;
    }
    return self;
}

- (void)closeImagePC {
    if (self.imagePC) {
        [self.imagePC dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)takeVideoFromCamera {
    //self.isNeedSavePhoto = YES;
    [UIDevice isHaveSysPermissionCameraBlock:^(BOOL isFirst, BOOL isHavePermission) {
        if (isHavePermission) {
            [UIDevice isHaveSysPermissionAudioBlock:^(BOOL isFirst, BOOL isHavePermission) {
                if (isHavePermission) {
                    [self showTakeVideoFromCameraEvent];
                }
            }];
        }
    }];
}

- (void)showTakeVideoFromCameraEvent {
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        UIImagePickerController *controller;
        
        controller = [[UIImagePickerController alloc]init];
        controller.sourceType   = UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
        
        // 清晰度
        //controller.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
        //controller.videoQuality = UIImagePickerControllerQualityTypeIFrame960x540;
        if (self.qualityType >= UIImagePickerControllerQualityTypeHigh) {
            controller.videoQuality = self.qualityType;
        }else{
            controller.videoQuality = UIImagePickerControllerQualityType640x480;
        }
        if ([self isRearCameraAvailable]) {
            controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
        }
        {
            controller.mediaTypes        = @[(NSString *)kUTTypeMovie];
            controller.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
            controller.allowsEditing     = YES;//允许编辑
            controller.delegate          = self;//设置代理，检测操作
        }
        
        self.imagePC = controller;
        
        controller.delegate = self;
        controller.modalPresentationStyle = self.modalPresentationStyle;
        
        [self.superVC presentViewController:controller animated:YES completion:^(void){
            //NSLog(@"Picker View Controller is presented");
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        //NSLog(@"video...");
        NSURL * url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        __weak typeof(self) weakSelf = self;
        [UIDevice isHaveSysPowerForAlbumAlert:NO block:^(BOOL isFirst, BOOL isHavePermission) {
            if (isHavePermission) {
                [UIDevice saveImage:nil imageUrl:nil videoUrl:url collectionName:nil showAlert:NO];
            }
        }];
        
        if(weakSelf.hasTakeVideo){
            weakSelf.hasTakeVideo(url);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

@end
