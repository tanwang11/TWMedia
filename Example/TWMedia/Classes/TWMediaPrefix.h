//
//  TWMediaPrefix.h
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#ifndef TWMediaPrefix_h
#define TWMediaPrefix_h

#import <UIKit/UIKit.h>
#import "TWMediaImageBundle.h"

#import <ReactiveObjC/ReactiveObjC.h>

@class TWImagePickerVC;
@class TZImagePickerController;

typedef void(^TWImagePickerCameraBlock)(TWImagePickerVC * vc, CGRect availableRect);
typedef void(^TWImagePickerAlbumBlock)(TZImagePickerController * vc);

#endif /* TWMediaPrefix_h */
