//
//  TWImageBrower.m
//  TWImageBrower_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import "TWImageBrower.h"
#import "TWImageBrowerCell.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "TWImageBrowerBundle.h"

NSTimeInterval const SWPhotoBrowerAnimationDuration = 0.3f;

@interface MyCollectionView : UICollectionView

@end

@implementation MyCollectionView

- (void)dealloc {
    //    NSLog(@"%s",__func__);
}

@end


@interface TWImageBrower () <UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic        ) UIInterfaceOrientation        originalOrientation;
@property (nonatomic        ) BOOL                          flag;
@property (nonatomic, weak  ) id                            observer;
@property (nonatomic, strong) UIImageView                   *originalImageView;//用来保存小图
@property (nonatomic        ) BOOL                          statusBarHidden;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGesture;
@property (nonatomic, weak  ) UIView                        *containerView;


//当前图片的索引
@property (nonatomic        ) NSInteger                     index;
@property (nonatomic,strong ) UIImageView                   *tempImageView;
@property (nonatomic        ) TWImageBrowerStatus           photoBrowerControllerStatus;
@property (nonatomic,strong ) UICollectionView              *collectionView;
@property (nonatomic        ) UIDeviceOrientation           currentOrientation;
@property (nonatomic,strong ) NSMutableDictionary           *originalImageViews;//原始imageView字典
@property (nonatomic,strong ) NSMutableDictionary           *originalImages;//原始imageView的图片字典

@property (nonatomic, getter=isPresentAnimation) BOOL       presentAnimation;

@end


@implementation TWImageBrower

- (instancetype)initWithIndex:(NSInteger)index
               copyImageArray:(NSArray<TWImageBrowerEntity *> *)copyImageArray
                    presentVC:(UIViewController *)presentVC
             originImageBlock:(TWImageBrowerIVBlock _Nonnull)originImageBlock
               disappearBlock:(TWImageBrowerVoidBlock _Nullable)disappearBlock
        placeholderImageBlock:(TWImageBrowerImageBlock _Nullable)placeholderImageBlock
{
    return [self initWithIndex:index
                copyImageArray:copyImageArray
                weakImageArray:nil
                     presentVC:presentVC
              originImageBlock:originImageBlock
                disappearBlock:disappearBlock
         placeholderImageBlock:placeholderImageBlock];
}

// weakImageArray, 用于第二次开发
- (instancetype)initWithIndex:(NSInteger)index
               copyImageArray:(NSArray<TWImageBrowerEntity *> *)copyImageArray
               weakImageArray:(NSArray<TWImageBrowerEntity *> *)weakImageArray
                    presentVC:(UIViewController *)presentVC
             originImageBlock:(TWImageBrowerIVBlock _Nonnull)originImageBlock
               disappearBlock:(TWImageBrowerVoidBlock _Nullable)disappearBlock
        placeholderImageBlock:(TWImageBrowerImageBlock _Nullable)placeholderImageBlock {
    
    return [self initWithIndex:index
                copyImageArray:copyImageArray
                weakImageArray:weakImageArray
                     presentVC:presentVC
              originImageBlock:originImageBlock
            willDisappearBlock:nil
                disappearBlock:disappearBlock
         placeholderImageBlock:placeholderImageBlock];
}

- (instancetype)initWithIndex:(NSInteger)index
               copyImageArray:(NSArray<TWImageBrowerEntity *> *)copyImageArray
               weakImageArray:(NSArray<TWImageBrowerEntity *> *)weakImageArray
                    presentVC:(UIViewController *)presentVC
             originImageBlock:(TWImageBrowerIVBlock _Nonnull)originImageBlock
           willDisappearBlock:(TWImageBrowerVoidBlock _Nullable)willDisappearBlock
               disappearBlock:(TWImageBrowerVoidBlock _Nullable)disappearBlock
        placeholderImageBlock:(TWImageBrowerImageBlock _Nullable)placeholderImageBlock;
{
    
    if(self = [super initWithNibName:nil bundle:nil]) {
        NSAssert(presentVC != nil, @"presentVC 不能为nil");
        _presentVC = presentVC;
        //保存原来的屏幕旋转状态
        self.originalOrientation = [[presentVC valueForKey:@"interfaceOrientation"] integerValue];
        _index                   = index;
        _myImageArray            = copyImageArray;
        if (weakImageArray) {
            _weakImageArray      = weakImageArray;
        }else{
            _weakImageArray      = _myImageArray;
        }
        
        _originImageBlock        = originImageBlock;
        _willDisappearBlock      = willDisappearBlock;
        _disappearBlock          = disappearBlock;
        _placeholderImageBlock   = placeholderImageBlock;
        
        _saveImageEnable         = YES;
        _showDownloadImageError  = YES;
        
        [self initCommonSection];
    }
    
    return self;
}
- (void)initCommonSection {
    // checkImageEntity
    for (TWImageBrowerEntity * entity in self.weakImageArray) {
        if (entity.isUseImage) {
            entity.smallImage    = entity.smallImage?:entity.bigImage;
            entity.bigImage      = entity.bigImage?:entity.smallImage;
        }else{
            entity.smallImageUrl = entity.smallImageUrl?:entity.bigImageUrl;
            entity.bigImageUrl   = entity.bigImageUrl?:entity.smallImageUrl;
        }
    }
    //获取小图
    self.originalImageView  = self.originImageBlock(self, self.index);
    _normalImageViewSize    = self.originalImageView.frame.size;
    self.currentOrientation = [UIDevice currentDevice].orientation;
    __weak typeof(self) weakSelf = self;
    //warning:在下拉屏幕的时候也会触发UIDeviceOrientationDidChangeNotification,所以如果当前屏幕旋转状态没有改变就不用刷新UI
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if(!weakSelf.isViewLoaded) {
            return;
        }
        if([UIDevice currentDevice].orientation == weakSelf.currentOrientation) {
            return;
        }
        weakSelf.currentOrientation = [UIDevice currentDevice].orientation;
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:weakSelf.index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.presentVC setNeedsStatusBarAppearanceUpdate];
}

- (void)setupUI {
    self.collectionView = ({
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        MyCollectionView * cv = [[MyCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width+16, self.view.frame.size.height) collectionViewLayout:flow];
        if (@available(iOS 11, *)) {
            if([cv respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]){
                cv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        cv.autoresizingMask               = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        flow.minimumLineSpacing           = 0;
        cv.delegate                       = self;
        cv.dataSource                     = self;
        cv.showsHorizontalScrollIndicator = NO;
        cv.showsVerticalScrollIndicator   = NO;
        cv.pagingEnabled                  = YES;
        cv.backgroundColor                = [UIColor clearColor];
        cv.hidden                         = YES;//一开始先隐藏浏览器,做法放大动画再显示
        [cv registerClass:[TWImageBrowerCell class] forCellWithReuseIdentifier:@"cell"];
        [self.view addSubview:cv];
        
        cv;
    });
    
    //添加平移手势
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullDownGRAction:)];
    self.panGesture.delegate = self;
    [self.view addGestureRecognizer:self.panGesture];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flow.itemSize = CGSizeMake(self.view.frame.size.width+16, self.view.frame.size.height);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(!self.flag){
        self.flag = YES;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:false];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.weakImageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TWImageBrowerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //已知bug：cellForItemAtIndexPath这里的indexPath有可能是乱序，不能在这里进行下载
    return cell;
}

#pragma mark 设置ImageURL 或者Image
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(TWImageBrowerCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"%@",indexPath);
    cell.browerVC = self;
    TWImageBrowerEntity * entity = self.weakImageArray[indexPath.row];
    if (entity.isUseImage) {
        [cell adjustImageViewWithImage:entity.bigImage];
        //开启缩放
        cell.scrollView.maximumZoomScale = 2.0f;
    }else{
        //先设置小图
        cell.smallImageUrl = entity.smallImageUrl;
        //后设置大图
        cell.bigImageUrl    = entity.bigImageUrl;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(TWImageBrowerCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<NSIndexPath *> *visibleIndexPaths = [collectionView indexPathsForVisibleItems];
    if(visibleIndexPaths.lastObject.item != indexPath.item){
        [cell.scrollView setZoomScale:1.0f animated:NO];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger index = ABS(targetContentOffset->x/(self.view.frame.size.width + 16));
    self.index = index;
    if (self.scrollBlock) {
        self.scrollBlock(self, self.index);
    }
    // MARK: 滑动,索取父视图图片
    // 有时候取值会失败,这里有一次挽留的机会.注意问题1的前提
    UIImageView *imageView = self.originImageBlock(self, index);
    if (imageView) {
        [self.originalImageViews enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, UIImageView*  _Nonnull imgV, BOOL * _Nonnull stop) {
            imgV.image = [self.originalImages objectForKey:key];
        }];
        [self.originalImageViews removeAllObjects];
        [self.originalImages removeAllObjects];
        NSString *key = [NSString stringWithFormat:@"%ld",(long)index];
        if(imageView.image){
            [self.originalImages setObject:imageView.image forKey:key];
        }
        imageView.image = nil;
        [self.originalImageViews setObject:imageView forKey:key];
        _normalImageViewSize = imageView.frame.size;
    }
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if([self isIPhoneXSeries]) {
        return UIStatusBarStyleLightContent;
    }
    return self.presentVC.preferredStatusBarStyle;
}

- (BOOL)isIPhoneXSeries {
    static BOOL flag;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width  = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        if((width == 375 && height == 812) || (height == 375 && width == 812)) {//iPhone X,iPhone XS
            flag = YES;
        }else if ((width == 414 && height == 896) || (height == 896 && width == 414)){//iPhone XR,iPhone XS Max
            flag = YES;
        }
    });
    return flag;
}

//用于创建一个和当前点击图片一模一样的imageView
- (UIImageView *)tempImageView {
    if(!_tempImageView) {
        _tempImageView = [[UIImageView alloc] init];
        _tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        _tempImageView.clipsToBounds = YES;
    }
    return _tempImageView;
}

#pragma mark - present动画
- (void)doPresentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.photoBrowerControllerStatus = TWImageBrowerWillShow;
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [UIColor blackColor];
    self.containerView = containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:toView];
    
    CGFloat duration = SWPhotoBrowerAnimationDuration;
    TWImageBrowerEntity * entity = self.weakImageArray[_index];
    UIImage *image;
    if (entity.isUseImage) {
        image = entity.bigImage ? : entity.smallImage;
    }else{
        //先从缓存中获取大图
        image = [[SDImageCache sharedImageCache] imageFromCacheForKey:entity.bigImageUrl.absoluteString];
        
        if(image == nil){
            image = [[SDImageCache sharedImageCache] imageFromCacheForKey:entity.smallImageUrl.absoluteString];
            if(image == nil){//小图大图都没有找到
                if (self.placeholderImageBlock) {
                    image = self.placeholderImageBlock(self);
                }
                duration = 0;
            }
        }
    }
    
    //获取转换之后的坐标
    CGRect convertFrame = [self.originalImageView.superview convertRect:self.originalImageView.frame toCoordinateSpace:[UIScreen mainScreen].coordinateSpace];
    self.tempImageView.frame = convertFrame;
    self.tempImageView.image = image;
    [toView addSubview:self.tempImageView];
    //计算临时图片放大之后的frame
    CGRect toFrame = [self getTempImageViewFrameWithImage:image];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.tempImageView.frame = toFrame;
        //更新状态栏,iphoneX不要隐藏状态栏
        if(![self isIPhoneXSeries]){
            self.statusBarHidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } completion:^(BOOL finished) {
        //移除图片
        [self.tempImageView removeFromSuperview];
        //显示图片浏览器
        self.collectionView.hidden = NO;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        self.photoBrowerControllerStatus = TWImageBrowerDidShow;
        
        // MARK: 打开动画结束,索取父视图图片
        UIImageView *imageView = self.originImageBlock(self, self.index);
        if (imageView) {
            NSString *key = [NSString stringWithFormat:@"%ld",(long)self.index];
            if(imageView.image){
                [self.originalImages setObject:imageView.image forKey:key];
            }
            [self.originalImageViews setObject:imageView forKey:key];
            imageView.image = nil;
        }
    }];
}

- (void)doDismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.photoBrowerControllerStatus = TWImageBrowerWillHide;
    //一定要在获取到imageView的frame之前改变状态栏，否则动画会出现跳一下的现象
    if(![self isIPhoneXSeries]){
        self.statusBarHidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    //获取当前屏幕可见cell的indexPath
    NSIndexPath *visibleIndexPath = self.collectionView.indexPathsForVisibleItems.lastObject;
    _index = visibleIndexPath.item;
    
    TWImageBrowerCell *cell = (TWImageBrowerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_index inSection:0]];
    self.tempImageView.image = cell.imagView.image;
    CGRect fromRect = [cell.imagView.superview convertRect:cell.imagView.frame toCoordinateSpace:[UIScreen mainScreen].coordinateSpace];
    self.tempImageView.frame = fromRect;
    self.collectionView.hidden = YES;
    UIView *containerView = [transitionContext containerView];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [fromView addSubview:self.tempImageView];
    
    UIImageView *imageView = self.originImageBlock(self, self.index);
    if (!imageView) {
        // 有时候取值会失败,这里有一次挽留的机会.注意答案1
        NSString *key = [NSString stringWithFormat:@"%ld",(long)index];
        imageView = [self.originalImageViews objectForKey:key];
    }
    _normalImageViewSize = imageView.frame.size;
    CGRect convertFrame  = [imageView.superview convertRect:imageView.frame toCoordinateSpace:[UIScreen mainScreen].coordinateSpace];
    CGFloat duration     = SWPhotoBrowerAnimationDuration;
    
    TWImageBrowerEntity * entity = self.weakImageArray[_index];
    if (entity.isUseImage) {
        
    }else{
        if(![[SDImageCache sharedImageCache] imageFromCacheForKey:entity.bigImageUrl.absoluteString] &&
           ![[SDImageCache sharedImageCache] imageFromCacheForKey:entity.smallImageUrl.absoluteString]){
            duration = 0;
        }
    }
    
    if(CGRectEqualToRect(convertFrame, CGRectZero)){
        duration = 0;
    }
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (self.willDisappearBlock) {
            self.willDisappearBlock(self, self.index);
        }
        if(duration != 0){
            self.tempImageView.frame = convertFrame;
        }
        containerView.backgroundColor = [UIColor clearColor];
        //旋转屏幕至原来的状态
        [[UIDevice currentDevice] setValue:@(self.originalOrientation) forKey:@"orientation"];
    } completion:^(BOOL finished) {
        // MARK: 销毁
        if (self.disappearBlock) {
            self.disappearBlock(self, self.index);
        }
        
        [fromView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        self.photoBrowerControllerStatus = TWImageBrowerDidHide;
        [self.originalImageViews enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, UIImageView*  _Nonnull imgV, BOOL * _Nonnull stop) {
            imgV.image = [self.originalImages objectForKey:key];
        }];
        [self.originalImageViews removeAllObjects];
        [self.originalImages removeAllObjects];
    }];
}

- (CGRect)getTempImageViewFrameWithImage:(UIImage *)image {
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat scale = 1.0f;
    if(image != nil) {
        scale = image.size.height/image.size.width;
    }
    CGFloat imageHeight = screenWidth*scale;
    CGFloat inset = 0;
    if(imageHeight<screenHeight) {
        inset = (screenHeight - imageHeight)*0.5f;
    }
    return CGRectMake(0, inset, screenWidth, imageHeight);
}

#pragma mark - pop动画


#pragma mark - UIViewControllerTransitioningDelegate
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    UIPresentationController *controller = [[UIPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return controller;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.presentAnimation = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.presentAnimation = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return SWPhotoBrowerAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if(self.isPresentAnimation){
        [self doPresentAnimation:transitionContext];
    }else{
        [self doDismissAnimation:transitionContext];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - 打开关闭
- (void)show {
    if(self.photoBrowerControllerStatus != TWImageBrowerUnShow) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        {
            self.transitioningDelegate = self;
            self.modalPresentationStyle = UIModalPresentationCustom;
            [self.presentVC presentViewController:self animated:YES completion:nil];
        }
    });
}

- (void)close {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate 关闭手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    TWImageBrowerCell *cell = [[self.collectionView visibleCells] firstObject];
    if(cell.scrollView.zoomScale > 1.0f) {
        //NSLog(@"g 开始询问 NO");
        return NO;
    }
    CGPoint velocity = [self.panGesture velocityInView:self.panGesture.view];
    if(velocity.y < 0){
        return NO;//禁止上滑
    }
    
    TWImageBrowerEntity * entity = self.weakImageArray[_index];
    if (entity.isUseImage) {
        
    }else{
        if(![[SDImageCache sharedImageCache] imageFromCacheForKey:entity.bigImageUrl.absoluteString] &&
           ![[SDImageCache sharedImageCache] imageFromCacheForKey:entity.smallImageUrl.absoluteString]){
            return NO;
        }
    }
    
    return YES;
}

//这个方法返回YES，第一个和第二个互斥时，第二个会失效
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //NSLog(@"g1: %@, g2: %@", NSStringFromClass([gestureRecognizer class]), NSStringFromClass([otherGestureRecognizer class]));
    TWImageBrowerCell *cell = [[self.collectionView visibleCells] firstObject];
    if(otherGestureRecognizer == cell.scrollView.panGestureRecognizer){
        if(cell.scrollView.contentOffset.y <= 0) {
            //NSLog(@"YES g1: %@, g2: %@", NSStringFromClass([gestureRecognizer class]), NSStringFromClass([otherGestureRecognizer class]));
            return YES;
        }
    }
    //NSLog(@"NO  g1: %@, g2: %@", NSStringFromClass([gestureRecognizer class]), NSStringFromClass([otherGestureRecognizer class]));
    return NO;
}


#pragma mark - HandleGesture
- (void)pullDownGRAction:(UIPanGestureRecognizer *)panGesture {
    CGPoint point = [panGesture translationInView:panGesture.view];
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    TWImageBrowerCell *cell = [[self.collectionView visibleCells] firstObject];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            //更改状态栏
            self.statusBarHidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            [self setNeedsStatusBarAppearanceUpdate];
            
            //设置anchorPoint和position
            CGPoint location = [panGesture locationInView:panGesture.view];
            CGPoint anchorPoint = CGPointMake(location.x/panGesture.view.bounds.size.width, location.y/panGesture.view.bounds.size.height);
            cell.scrollView.layer.anchorPoint = anchorPoint;
            CGPoint position = cell.scrollView.layer.position;
            position.x = cell.scrollView.center.x + (anchorPoint.x - 0.5) * cell.scrollView.bounds.size.width;
            position.y = cell.scrollView.center.y + (anchorPoint.y - 0.5) * cell.scrollView.bounds.size.height;
            cell.scrollView.layer.position = position;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            double percent = 1 - fabs(point.y)/self.view.frame.size.height;
            percent = MAX(percent, 0);
            double s = MAX(percent, 0.5);//最低不能缩小原来的0.5倍
            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x, point.y);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
            //合并两个transform
            CGAffineTransform concatTransform = CGAffineTransformConcat(scale, translation);
            cell.scrollView.transform = concatTransform;
            double alpha = 1.0 - MIN(1.0, point.y/(self.view.frame.size.height/2.0f));
            self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if(fabs(point.y) > 200 || fabs(velocity.y) > 500){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                //恢复图片到原来的属性
                self.collectionView.userInteractionEnabled = NO;
                if(![self isIPhoneXSeries]){
                    self.statusBarHidden = YES;
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
                }
                [UIView animateWithDuration:SWPhotoBrowerAnimationDuration delay:0 options:0 animations:^{
                    self.containerView.backgroundColor = [UIColor blackColor];
                    //还原anchorPoint和position
                    cell.scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                    cell.scrollView.layer.position = CGPointMake(cell.scrollView.bounds.size.width/2.0f, cell.scrollView.bounds.size.height/2.0f);
                    cell.scrollView.transform = CGAffineTransformIdentity;
                    [cell adjustImageViewWithImage:cell.imagView.image];
                    [self setNeedsStatusBarAppearanceUpdate];
                } completion:^(BOOL finished) {
                    self.collectionView.userInteractionEnabled = YES;
                }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)dealloc {
    //    NSLog(@"%s",__func__);
    [[SDWebImageManager sharedManager] cancelAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

#pragma mark - get set
- (NSMutableDictionary *)originalImages {
    if(!_originalImages){
        _originalImages = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _originalImages;
}

- (NSMutableDictionary *)originalImageViews {
    if(!_originalImageViews) {
        _originalImageViews = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _originalImageViews;
}

@end
