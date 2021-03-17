//
//  TWImagePreviewVC.h
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <TWImageBrower/TWImageBrower.h>
#import "TWImageEntity.h"
#import <TWFoundation/Block+twPrefix.h>
#import "TWMediaPrefix.h"


NS_ASSUME_NONNULL_BEGIN

@interface TWImagePreviewVC : TWImageBrower

@property (nonatomic, strong) UIColor * toolBarColor;
@property (nonatomic, copy  ) BlockPVoid completeBlock; // 完成按钮事件

@end

NS_ASSUME_NONNULL_END
