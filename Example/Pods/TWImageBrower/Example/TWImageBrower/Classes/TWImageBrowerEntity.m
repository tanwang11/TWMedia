//
//  TWImageBrowerEntity.m
//  TWImageBrower_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import "TWImageBrowerEntity.h"

@implementation TWImageBrowerEntity

- (BOOL)isUseImage {
    return self.smallImage||self.bigImage;
}

@end
