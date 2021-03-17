//
//  TWMedia.h
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAsset+data.h"
#import "TWImagePickerVC.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "TWMediaPrefix.h"


NS_ASSUME_NONNULL_BEGIN

@class PHAsset;

typedef void(^TWImageFinishBlock)(NSArray *images, NSArray *assets, BOOL origin);
typedef void(^TWVideoFinishBlock)(NSURL * videoURL, NSString * videoPath, NSData *imageData, UIImage *image, PHAsset * phAsset, CGFloat time, CGFloat videoSize);

@class TWVideoProvider;


@interface TWMedia : NSObject

// present方式, 默认为: UIModalPresentationFullScreen
@property (nonatomic        ) UIModalPresentationStyle modalPresentationStyle;

@property (nonatomic, copy  ) TWImageFinishBlock    TWImageFinishBlock;
@property (nonatomic, strong) TWVideoProvider       * imageProvider;

// 拍摄的时候增加一个浮层使用,只针对单拍使用.

#pragma mark - image
- (void)showImageACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc maxCount:(int)maxCount origin:(BOOL)origin finish:(TWImageFinishBlock)finish;
// 可以增加自定义actions
- (void)showImageACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc maxCount:(int)maxCount origin:(BOOL)origin actions:(NSArray *)actions finish:(TWImageFinishBlock)finish;

- (void)showImageACTitle:(NSString *)title
                 message:(NSString *)message
                      vc:(UIViewController *)vc
                maxCount:(int)maxCount
                  origin:(BOOL)origin
                 actions:(NSArray *)actions
                  finish:(TWImageFinishBlock)finish
                  camera:(TWImagePickerCameraBlock)cameraAppearBlock
                   album:(TWImagePickerAlbumBlock)albumAppearBlock;

#pragma mark - video
- (void)showVideoACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc videoIconSize:(CGSize)size qualityType:(UIImagePickerControllerQualityType)qualityType finish:(TWVideoFinishBlock)finish;
// 可以增加自定义actions
- (void)showVideoACTitle:(NSString *)title message:(NSString *)message vc:(UIViewController *)vc videoIconSize:(CGSize)size qualityType:(UIImagePickerControllerQualityType)qualityType actions:(NSArray *)actions finish:(TWVideoFinishBlock)finish;

@end

NS_ASSUME_NONNULL_END
