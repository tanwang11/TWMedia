//
//  TWImageBrowerCell.h
//  TWImageBrower_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWImageBrowerEntity.h"

NS_ASSUME_NONNULL_BEGIN

@class TWImageBrower;

@interface TWImageBrowerCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView     *scrollView;
@property (nonatomic, strong) UIImageView      *imagView;
@property (nonatomic, strong) NSURL            *bigImageUrl;
@property (nonatomic, strong) NSURL            *smallImageUrl;
@property (nonatomic, weak  ) TWImageBrower    *browerVC;

- (void)adjustImageViewWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
