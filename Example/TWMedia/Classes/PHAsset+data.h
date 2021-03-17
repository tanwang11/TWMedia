//
//  PHAsset+data.h
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (data)

+ (void)getImageFromPHAsset:(PHAsset *)asset finish:(void (^)(NSData *data))block;

@end

NS_ASSUME_NONNULL_END
