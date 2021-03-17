//
//  TWImagePickerVC.h
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SKFCamera/LLSimpleCamera.h>
#import "TWMediaPrefix.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^TWImagePickerFinishBlock) (NSArray * array);


@interface TWImagePickerVC : UIViewController

@property (nonatomic, strong) LLSimpleCamera   *camera;
@property (strong, nonatomic) UILabel          *errorLabel;
@property (strong, nonatomic) UIButton         *snapButton;
@property (strong, nonatomic) UIButton         *switchButton;
@property (strong, nonatomic) UIButton         *flashButton;
@property (strong, nonatomic) UIButton         *backButton;

@property (nonatomic, strong) UIButton         *completeBT;

@property (nonatomic, strong) NSMutableArray   *imageArray;// 针对连拍图片数组
@property (nonatomic        ) int              maxNum;
@property (nonatomic, strong) UICollectionView *previewCV;
@property (nonatomic        ) CGSize           ccSize;

@property (nonatomic, getter=isSingleOrigin) BOOL             singleOrigin;//单拍照片是否使用原图

@property (nonatomic, copy  ) TWImagePickerCameraBlock appearBlock;

// 大于1张的话,不开启编辑图片功能.
- (id)initWithMaxNum:(int)maxNum singleOrigin:(BOOL)singleOrigin finishBlock:(TWImagePickerFinishBlock)block;

@end

NS_ASSUME_NONNULL_END
