//
//  TWVideoProvider.h
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TWVideoProviderBlock)(NSURL * videoURL); // __BlockTypedef

@interface TWVideoProvider : NSObject

// present方式, 默认为: UIModalPresentationFullScreen
@property (nonatomic        ) UIModalPresentationStyle modalPresentationStyle;

@property (nonatomic, weak  ) UIImagePickerController * imagePC; // 图片采集器
@property (nonatomic, copy  ) TWVideoProviderBlock   hasTakeVideo;

@property (nonatomic, weak  ) UIViewController * superVC;
@property (nonatomic        ) UIImagePickerControllerQualityType qualityType;

- (void)takeVideoFromCamera;

- (void)closeImagePC;

@end

NS_ASSUME_NONNULL_END
