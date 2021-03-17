//
//  TWImageEntity.h
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <TWImageBrower/TWImageBrower.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWImageEntity : TWImageBrowerEntity

@property (nonatomic, getter=isIgnore) BOOL ignore;  // 是否忽略,用于NSObject+PickImage

@end

NS_ASSUME_NONNULL_END
