//
//  TWImagePreviewVC.m
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import "TWImagePreviewVC.h"
#import <TZImagePickerController/UIView+TZLayout.h>
#import <TWUI/TWUI.h>

@interface TWImagePreviewVC ()

@property (nonatomic, strong) UIView      * naviBar;
@property (nonatomic, strong) UIButton    * backButton;
@property (nonatomic, strong) UIButton    * selectButton;
@property (nonatomic, strong) UIView      * toolBar;
@property (nonatomic, strong) UIButton    * doneButton;

@property (nonatomic, strong) UIImageView * numberImageView;
@property (nonatomic, strong) UILabel     * numberLabel;
@property (nonatomic, strong) UIButton    * originalPhotoButton;
@property (nonatomic, strong) UILabel     * originalPhotoLabel;
@property (nonatomic        ) int         selectNum;


@property (nonatomic, getter=isShowTopBottomBar) BOOL showTopBottomBar;

@end


@implementation TWImagePreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.toolBarColor) {
        CGFloat rgb = 34.0/255.0;
        self.toolBarColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    }
    
    [self setupBlockEvent];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self delaySetCustomeUI];
    });
}

// 自己设置了单击事件
- (void)setupBlockEvent {
    __weak typeof(self) weakSelf = self;
    self.singleTapBlock = ^(TWImageBrower *browerController, NSInteger index) {
        [weakSelf customeSingleTapEventDuration:0.1];
    };
    self.scrollBlock = ^(TWImageBrower *browerController, NSInteger index) {
        TWImageEntity * entity = (TWImageEntity * )weakSelf.weakImageArray[index];
        weakSelf.selectButton.selected = !entity.isIgnore;
    };
}

- (void)delaySetCustomeUI {
    [self configCustomNaviBar];
    [self configBottomToolBar];
    self.selectNum = 0;
    for (TWImageEntity * entity in self.weakImageArray) {
        if (!entity.isIgnore) {
            self.selectNum ++;
        }
    }
    self.numberLabel.hidden     = self.selectNum <= 0;
    self.numberImageView.hidden = self.selectNum <= 0;
    self.numberLabel.text       = [NSString stringWithFormat:@"%i", self.selectNum];
    
    {
        self.showTopBottomBar   = NO;
        self.naviBar.y          = -self.naviBar.height;
        self.toolBar.bottom     = self.view.height;
        [self customeSingleTapEventDuration:0.1];
    }
    [self customeSvScrollBlockAction:self.index];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat naviBarHeight      = [UIDevice isIphoneXScreen] ? 88:64;

    self.naviBar.frame         = CGRectMake(0, 0, self.view.width, naviBarHeight);
    self.backButton.frame      = CGRectMake(10, naviBarHeight - 44, 44, 44);
    self.selectButton.frame    = CGRectMake(self.view.width - 54, self.backButton.y, 42, 42);

    // ???:
    CGFloat toolBarHeight      = 44;
    CGFloat toolBarTop         = self.view.height - toolBarHeight;
    self.toolBar.frame         = CGRectMake(0, toolBarTop, self.view.width, toolBarHeight);

    self.doneButton.frame      = CGRectMake(self.view.width - 44 - 12, 0, 44, 44);
    self.numberImageView.frame = CGRectMake(self.view.width - 56 - 28, 7, 30, 30);
    self.numberLabel.frame     = self.numberImageView.frame;
}

- (void)customeSingleTapEventDuration:(float)duration {
    self.showTopBottomBar = !self.isShowTopBottomBar;
    [[UIApplication sharedApplication] setStatusBarHidden:!self.isShowTopBottomBar withAnimation:UIStatusBarAnimationNone];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if (self.isShowTopBottomBar) {
            self.naviBar.y      = 0;
            self.toolBar.bottom = self.view.height;
        }else{
            self.naviBar.y      = -self.naviBar.height;
            self.toolBar.y      = self.view.height;
        }
    } completion:nil];
}

- (void)customeSvScrollBlockAction:(NSInteger)index {
    TWImageEntity * entity = (TWImageEntity *)self.weakImageArray[index];
    self.selectButton.selected = !entity.isIgnore;
    //NSLog(@"isIgnore:%li - %i", index, entity.isIgnore);
}

- (void)configCustomNaviBar {
    self.naviBar = ({
        UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = self.toolBarColor;
        
        [self.view addSubview:view];
        view;
    });
    self.backButton = ({
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectZero];
        [button setImage:[TWMediaImageBundle imageBundleNamed:@"navi_back"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self.naviBar addSubview:button];
        
        button;
    });
    
    self.selectButton = ({
        UIButton * button  = [[UIButton alloc] initWithFrame:CGRectZero];
        [button setImage:[TWMediaImageBundle imageBundleNamed:@"photo_def_previewVc"] forState:UIControlStateNormal];
        [button setImage:[TWMediaImageBundle imageBundleNamed:@"photo_sel_photoPickerVc"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.naviBar addSubview:button];
        
        button;
    });
}

- (void)configBottomToolBar {
    self.toolBar = ({
        UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = self.toolBarColor;
        
        [self.view addSubview:view];
        view;
    });
    self.doneButton = ({
        UIButton * button  = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
        
        [self.toolBar addSubview:button];
        
        button;
    });
    
    self.numberImageView = ({
        UIImageView * iv  = [[UIImageView alloc] initWithImage:[TWMediaImageBundle imageBundleNamed:@"photo_number_icon"]];
        iv.backgroundColor = [UIColor clearColor];
        
        [self.toolBar addSubview:iv];
        
        iv;
    });
    self.numberLabel = ({
        UILabel * l= [[UILabel alloc] init];
        l.font = [UIFont systemFontOfSize:15];
        l.textColor = [UIColor whiteColor];
        l.textAlignment = NSTextAlignmentCenter;
        l.backgroundColor = [UIColor clearColor];
        
        [self.toolBar addSubview:l];
        l;
    });
}

- (void)backButtonAction {
    //NSLog(@"WKQ 返回事件");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self close];
    });
}

- (void)doneButtonClick {
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.completeBlock) {
        self.completeBlock();
    }
}

- (void)selectButtonAction:(UIButton *)selectButton {
    TWImageEntity * entity = (TWImageEntity * )self.weakImageArray[self.index];
    selectButton.selected = !selectButton.isSelected;
    entity.ignore = !selectButton.isSelected;
    if (selectButton.isSelected) {
        self.selectNum ++;
    }else{
        self.selectNum --;
    }
    
    self.numberLabel.hidden     = self.selectNum <= 0;
    self.numberImageView.hidden = self.selectNum <= 0;
    self.numberLabel.text       = [NSString stringWithFormat:@"%i", self.selectNum];
    
    if (!entity.ignore) {
        [UIView showOscillatoryAnimationWithLayer:selectButton.imageView.layer type:TZOscillatoryAnimationToBigger];
    }
    [UIView showOscillatoryAnimationWithLayer:self.numberImageView.layer type:TZOscillatoryAnimationToSmaller];
}

@end
