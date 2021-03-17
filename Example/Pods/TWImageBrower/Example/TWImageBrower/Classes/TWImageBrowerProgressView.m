//
//  TWImageBrowerProgressView.m
//  TWImageBrower_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import "TWImageBrowerProgressView.h"

@implementation TWImageBrowerProgressView {
    __weak id _observer;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.clipsToBounds = YES;
        __weak typeof(self) weakSelf = self;
        _observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf setNeedsDisplay];
        }];
    }
    
    return self;
}

+ (instancetype)progressView {
    TWImageBrowerProgressView *view = [[self alloc] initWithFrame:CGRectMake(0, 0, 96/2.0f, 96/2.0f)];
    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat radius = MIN(self.frame.size.width, self.frame.size.height)/2.0f;
    self.layer.cornerRadius = radius;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if(_progress>=1.0f) {
        return;
    }
    if(_progress<=0.0f) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.5f].CGColor);
    CGContextFillPath(context);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [circlePath setLineWidth:3.0];
    [[UIColor whiteColor] setStroke];
    [circlePath stroke];
    
    CGFloat radius = MIN(rect.size.width, rect.size.height)/2.0f - circlePath.lineWidth;
    CGPoint center = CGPointMake(rect.size.width/2.0f, rect.size.height/2.0f);
    CGFloat startAngle = 0;
    CGFloat endAngle = M_PI*2*_progress;
    UIBezierPath *piePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [piePath addLineToPoint:center];
    [piePath closePath];
    [[UIColor whiteColor] setFill];
    [piePath fill];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}


@end
