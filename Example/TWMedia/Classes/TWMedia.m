//
//  TWMedia.m
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import "TWMedia.h"

#import "TWVideoProvider.h"
#import <Photos/Photos.h>
//#import "NSFileManager+pTool.h"
#import <TWFoundation/TWFoundation.h>
#import <TWUI/TWUI.h>


@implementation TWMedia

- (instancetype)init {
    if (self = [super init]) {
        _modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)showImageACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc maxCount:(int)maxCount origin:(BOOL)origin finish:(TWImageFinishBlock)finish {
    [self showImageACTitle:title message:message vc:vc maxCount:maxCount origin:origin actions:nil finish:finish];
}

- (void)showImageACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc maxCount:(int)maxCount origin:(BOOL)origin actions:(NSArray *)actions finish:(TWImageFinishBlock)finish {
    [self showImageACTitle:title message:message vc:vc maxCount:maxCount origin:origin actions:actions finish:finish camera:nil album:nil];
}

- (void)showImageACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc maxCount:(int)maxCount origin:(BOOL)origin actions:(NSArray *)actions finish:(TWImageFinishBlock)finish camera:(TWImagePickerCameraBlock)cameraAppearBlock album:(TWImagePickerAlbumBlock)albumAppearBlock
{
    __weak typeof(vc) weakVC       = vc;
    __weak typeof(self) weakSelf   = self;
    weakSelf.TWImageFinishBlock = finish;
    
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * camerAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
#if TARGET_IPHONE_SIMULATOR//模拟器
        AlertToastTitle(@"禁止启动");
#elif TARGET_OS_IPHONE//真机
        TWImagePickerVC * pickVC = [[TWImagePickerVC alloc] initWithMaxNum:maxCount singleOrigin:origin finishBlock:^(NSArray *array) {
            [weakSelf hasSelectImages:array assets:nil origin:origin];
        }];
        if (maxCount == 1) {
            pickVC.appearBlock = cameraAppearBlock;
        }
        pickVC.modalPresentationStyle = weakSelf.modalPresentationStyle;
        [weakVC presentViewController:pickVC animated:YES completion:nil];
#endif
    }];
    UIAlertAction * albumAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //NSLog(@"使用相册");
        
        TZImagePickerController *imageVC = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
        imageVC.allowPickingImage         = YES;
        imageVC.allowPickingVideo         = NO;
        imageVC.allowTakePicture          = NO;
        imageVC.allowPickingOriginalPhoto = origin;
        imageVC.isSelectOriginalPhoto     = YES;
        
        if (albumAppearBlock) {
            albumAppearBlock(imageVC);
        }
        
        [imageVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            [weakSelf hasSelectImages:photos assets:assets origin:isSelectOriginalPhoto];
        }];
        imageVC.modalPresentationStyle = weakSelf.modalPresentationStyle;
        [weakVC presentViewController:imageVC animated:YES completion:nil];
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:camerAction];
    [oneAC addAction:albumAction];
    for (UIAlertAction * oneAction in actions) {
        [oneAC addAction:oneAction];
    }
    [weakVC presentViewController:oneAC animated:YES completion:nil];
}

#pragma mark 上传图片
- (void)hasSelectImages:(NSArray *)images assets:(NSArray *)assets origin:(BOOL)origin {
    if (self.TWImageFinishBlock) {
        self.TWImageFinishBlock(images, assets, origin);
    }
}

#pragma mark - video
- (void)showVideoACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc videoIconSize:(CGSize)size qualityType:(UIImagePickerControllerQualityType)qualityType finish:(TWVideoFinishBlock)finish {
    [self showVideoACTitle:title message:message vc:vc videoIconSize:size qualityType:qualityType actions:nil finish:finish];
}

- (void)showVideoACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc videoIconSize:(CGSize)size qualityType:(UIImagePickerControllerQualityType)qualityType actions:(NSArray *)actions finish:(TWVideoFinishBlock)finish{
    
    __weak typeof(vc) weakVC = vc;
    __weak typeof(self) weakSelf = self;
    
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction * albumAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //NSLog(@"使用相册");
        // 视频目前只能单独选择
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
        imagePickerVC.allowPickingImage         = NO;
        imagePickerVC.allowPickingVideo         = YES;
        imagePickerVC.allowTakePicture          = NO;
        imagePickerVC.allowPickingOriginalPhoto = NO;
        
        [imagePickerVC setDidFinishPickingVideoHandle:^(UIImage *coverImage, id asset) {
            //NSLog(@"1");
            
            [TWMedia iosVideoUrlWithPHAsset:asset block:^(NSURL *fileURL, NSString *fileTitle) {
                //NSLog(@"2");
                //NSLog(@"fileUrl:%@, fileTitle:%@", fileURL.absoluteString, fileTitle);
                
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                option.normalizedCropRect = CGRectMake(0, 0, size.width*2, size.height*2);
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.networkAccessAllowed = NO;
                
                option.synchronous = NO;
                
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    [weakSelf feedbackVideoUrl:fileURL imageData:imageData image:nil phAsset:asset finish:finish];
                }];
            }];
        }];
        imagePickerVC.modalPresentationStyle = weakSelf.modalPresentationStyle;
        [weakVC presentViewController:imagePickerVC animated:YES completion:nil];
        
    }];
    
    UIAlertAction * cameraAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
#if TARGET_IPHONE_SIMULATOR//模拟器
        AlertToastTitle(@"禁止启动");
#elif TARGET_OS_IPHONE//真机
        if (!weakSelf.imageProvider) {
            TWVideoProvider * imageProvider = [[TWVideoProvider alloc] init];
            imageProvider.superVC = weakVC;
            imageProvider.modalPresentationStyle = weakSelf.modalPresentationStyle;
            imageProvider.qualityType = qualityType;
            [imageProvider setHasTakeVideo:^(NSURL * videoURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage * image = [TWMedia thumbnailImageForVideo:videoURL atTime:0.1];
                    [weakSelf feedbackVideoUrl:videoURL imageData:nil image:image phAsset:nil finish:finish];
                });
            }];
            weakSelf.imageProvider = imageProvider;
        }
        
        [weakSelf.imageProvider takeVideoFromCamera];
#endif
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:cameraAction];
    [oneAC addAction:albumAction];
    
    for (UIAlertAction * oneAction in actions) {
        [oneAC addAction:oneAction];
    }
    
    [vc presentViewController:oneAC animated:YES completion:nil];
}

- (void)feedbackVideoUrl:(NSURL *)videoURL imageData:(NSData *)imageData image:(UIImage *)image phAsset:(PHAsset *)phAsset finish:(TWVideoFinishBlock)finish{
    if(finish){
        if (!videoURL) {
            AlertToastTitle(@"获取视频信息出错");
            finish(nil, nil, nil, nil, nil, 0, 0);
            return;
        }
        
        NSString * videoPath;
        if ([videoURL.absoluteString hasPrefix:@"file://"]) {
            videoPath = [videoURL.absoluteString substringFromIndex:7];
        }else{
            videoPath = videoURL.absoluteString;
        }
        
        CGFloat time;
        CGFloat videoSize;
        {
            videoSize = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil].fileSize;
            // 视频长度
            NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
            double second = urlAsset.duration.value / urlAsset.duration.timescale;
            time = (int)second;
        }
        videoSize = videoSize/1024.0f/1024.0f;
        finish(videoURL, videoPath, imageData, image, phAsset, time, videoSize);
    }
}

+ (void)iosVideoUrlWithPHAsset:(PHAsset *)phAsset block:(void(^)(NSURL *fileURL, NSString *fileTitle))block
{
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        // Use the AVAsset avAsset
        // AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
        // AVPlayer *videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        AVURLAsset * urlAsset = (AVURLAsset*)avAsset;
        //NSLog(@"url: %@", urlAsset.URL.absoluteString);
        //NSLog(@"fileName: %@", [NSFileManager getFileName:urlAsset.URL.absoluteString]);
        
        if (block) {
            block(urlAsset.URL, urlAsset.URL.absoluteString.lastPathComponent);
        }
    }];
}

+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef){
        //NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    }
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

@end
