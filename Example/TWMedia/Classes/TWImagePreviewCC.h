//
//  TWImagePreviewCC.h
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWImageEntity.h"
#import "TWMediaPrefix.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWImagePreviewCC : UICollectionViewCell

@property (nonatomic, strong) UIImageView * iconIV;
@property (nonatomic, strong) UIButton    * selectBT;
@property (nonatomic, weak  ) TWImageEntity * weakEntity;

- (void)setImageEntity:(TWImageEntity *)entity;

@end

NS_ASSUME_NONNULL_END
