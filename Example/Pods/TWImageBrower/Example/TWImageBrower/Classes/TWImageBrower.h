//
//  TWImageBrower.h
//  TWImageBrower_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TWImageBrowerEntity.h"
#import "TWImageBrowerBundle.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TWImageBrowerStatus) {
    TWImageBrowerUnShow,//未显示
    TWImageBrowerWillShow,//将要显示出来
    TWImageBrowerDidShow,//已经显示出来
    TWImageBrowerWillHide,//将要隐藏
    TWImageBrowerDidHide,//已经隐藏
};

@class TWImageBrower;

extern NSTimeInterval const SWPhotoBrowerAnimationDuration;

typedef UIImageView *_Nullable(^TWImageBrowerIVBlock)(TWImageBrower *browerController, NSInteger index);
typedef UIImage * _Nullable    (^TWImageBrowerImageBlock)(TWImageBrower *browerController);
typedef void         (^TWImageBrowerVoidBlock)(TWImageBrower *browerController, NSInteger index);


@interface TWImageBrower : UIViewController <UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>

@property (nonatomic, copy  ) TWImageBrowerIVBlock    originImageBlock;
@property (nonatomic, copy  ) TWImageBrowerImageBlock placeholderImageBlock;

@property (nonatomic, copy  ) TWImageBrowerVoidBlock  willDisappearBlock;
@property (nonatomic, copy  ) TWImageBrowerVoidBlock  disappearBlock;
@property (nonatomic, copy  ) TWImageBrowerVoidBlock  singleTapBlock;
@property (nonatomic, copy  ) TWImageBrowerVoidBlock  scrollBlock;

//保存是哪个控制器弹出的图片浏览器,解决self.presentingViewController在未present之前取到的值为nil的情况
@property (nonatomic, weak,readonly) UIViewController *presentVC;
/**
 显示状态
 */
@property (nonatomic, readonly) TWImageBrowerStatus photoBrowerControllerStatus;

/**
 当前图片的索引
 */
@property (nonatomic, readonly) NSInteger index;

@property (nonatomic, readonly,copy) NSArray<TWImageBrowerEntity *> * myImageArray;
@property (nonatomic, weak) NSArray<TWImageBrowerEntity *> * weakImageArray;
/**
 小图的大小
 */
@property (nonatomic, readonly) CGSize normalImageViewSize;

- (instancetype)initWithIndex:(NSInteger)index
               copyImageArray:(NSArray<TWImageBrowerEntity *> *)copyImageArray
                    presentVC:(UIViewController *)presentVC
             originImageBlock:(TWImageBrowerIVBlock _Nonnull)originImageBlock
               disappearBlock:(TWImageBrowerVoidBlock _Nullable)disappearBlock
        placeholderImageBlock:(TWImageBrowerImageBlock _Nullable)placeholderImageBlock;

// weakImageArray, 用于第二次开发,传递weakImageArray的时候,就不需要copyImageArray了
- (instancetype)initWithIndex:(NSInteger)index
               copyImageArray:(NSArray<TWImageBrowerEntity *> *)copyImageArray
               weakImageArray:(NSArray<TWImageBrowerEntity *> *)weakImageArray
                    presentVC:(UIViewController *)presentVC
             originImageBlock:(TWImageBrowerIVBlock _Nonnull)originImageBlock
               disappearBlock:(TWImageBrowerVoidBlock _Nullable)disappearBlock
        placeholderImageBlock:(TWImageBrowerImageBlock _Nullable)placeholderImageBlock;

- (instancetype)initWithIndex:(NSInteger)index
               copyImageArray:(NSArray<TWImageBrowerEntity *> *)copyImageArray
               weakImageArray:(NSArray<TWImageBrowerEntity *> *)weakImageArray
                    presentVC:(UIViewController *)presentVC
             originImageBlock:(TWImageBrowerIVBlock _Nonnull)originImageBlock
           willDisappearBlock:(TWImageBrowerVoidBlock _Nullable)willDisappearBlock
               disappearBlock:(TWImageBrowerVoidBlock _Nullable)disappearBlock
        placeholderImageBlock:(TWImageBrowerImageBlock _Nullable)placeholderImageBlock;

// 没有放置到初始化函数中的参数.
@property (nonatomic) BOOL saveImageEnable; //是否禁止保存图片, 默认为YES
@property (nonatomic) BOOL showDownloadImageError;//是否显示下载图片出错信息, 默认为YES

/**
 显示图片浏览器
 */
- (void)show;

- (void)close;

// 不推荐使用的接口
- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder __unavailable;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new __unavailable;


@end

NS_ASSUME_NONNULL_END
