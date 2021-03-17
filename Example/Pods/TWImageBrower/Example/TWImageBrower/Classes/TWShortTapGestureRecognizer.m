//
//  TWShortTapGestureRecognizer.m
//  TWImageBrower_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import "TWShortTapGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@implementation TWShortTapGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.28 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.state != UIGestureRecognizerStateRecognized){
            self.state = UIGestureRecognizerStateFailed;
        }
    });
}

@end
