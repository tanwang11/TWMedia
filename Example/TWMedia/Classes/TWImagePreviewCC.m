//
//  TWImagePreviewCC.m
//  TWMedia_Example
//
//  Created by TW on 2021/3/17.
//  Copyright © 2021 tanwang11. All rights reserved.
//

#import "TWImagePreviewCC.h"
#import <Masonry/Masonry.h>
#import <TWUI/TWUI.h>


@implementation TWImagePreviewCC

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addViews];
        [self layoutSubviewsCustom];
    }
    return self;
}
- (void)layoutSubviewsCustom {
    
    [self.iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.selectBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(3);
        make.right.mas_equalTo(-3);
        make.width.mas_equalTo(self.selectBT.width);
        make.height.mas_equalTo(self.selectBT.height);
    }];
}

- (void)addViews {
    self.iconIV = ({
        UIImageView * iv = [UIImageView new];
        [self addSubview:iv];
        iv;
    });
    
    self.selectBT = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *nImage = [TWMediaImageBundle imageBundleNamed:@"photo_def_previewVc"];
        UIImage *sImage = [TWMediaImageBundle imageBundleNamed:@"photo_sel_photoPickerVc"];
        
        [button setImage:nImage forState:UIControlStateNormal];
        [button setImage:sImage forState:UIControlStateSelected];
        
        button.frame = CGRectMake(0, 0, nImage.size.width, nImage.size.height);
        [self addSubview:button];
        
        [button addTarget:self action:@selector(selectBTAction) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
}

- (void)selectBTAction {
    self.selectBT.selected = !self.selectBT.isSelected;
    self.weakEntity.ignore = !self.selectBT.isSelected;;
}

- (void)setImageEntity:(TWImageEntity *)entity {
    if (self.weakEntity != entity) {
        self.weakEntity        = entity;
        self.iconIV.image      = entity.smallImage;
    }
    self.selectBT.selected = !entity.isIgnore;
}

@end
