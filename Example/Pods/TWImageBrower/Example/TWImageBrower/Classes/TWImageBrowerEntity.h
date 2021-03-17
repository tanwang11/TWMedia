//
//  TWImageBrowerEntity.h
//  TWImageBrower_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWImageBrowerEntity : NSObject

@property (nonatomic, strong) UIImage * smallImage;
@property (nonatomic, strong) UIImage * bigImage;

@property (nonatomic, strong) NSURL * smallImageUrl;
@property (nonatomic, strong) NSURL * bigImageUrl;

- (BOOL)isUseImage;

@end

NS_ASSUME_NONNULL_END
