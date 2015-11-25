//
//  CZNewFeatureCell.m
//
//
//  Created by apple on 15-3-7.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "CZNewFeatureCell.h"
#import "AppDelegate.h"

@interface CZNewFeatureCell ()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIButton *shareButton;

@property (nonatomic, weak) UIButton *startButton;

@end

@implementation CZNewFeatureCell

- (UIButton *)startButton
{
    if (_startButton == nil) {
        UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (self.backType == 0) {
            [startBtn setTitle:@"立即体验" forState:UIControlStateNormal];
        } else {
            [startBtn setTitle:@"点击返回" forState:UIControlStateNormal];
        }
        startBtn.layer.cornerRadius = 4;
        startBtn.backgroundColor = [UIColor titleBarBackgroundColor];
        [startBtn sizeToFit];
        [startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:startBtn];
        _startButton = startBtn;

    }
    return _startButton;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        
        UIImageView *imageV = [[UIImageView alloc] init];
        
        _imageView = imageV;
        
        // 注意:一定要加载contentView
        [self.contentView addSubview:imageV];
        
    }
    return _imageView;
}

// 布局子控件的frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    
    // 分享按钮
    self.shareButton.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.8);
    
    
    // 开始按钮
     self.startButton.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.85);
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.imageView.image = image;
}

// 判断当前cell是否是最后一页
- (void)setIndexPath:(NSIndexPath *)indexPath count:(int)count
{
    if (indexPath.row == count - 1) { // 最后一页,显示分享和开始按钮
        self.shareButton.hidden = NO;
        self.startButton.hidden = NO;
        
        
    }else{ // 非最后一页，隐藏分享和开始按钮
        self.shareButton.hidden = YES;
        self.startButton.hidden = YES;
    }
}

// 点击开始微博的时候调用
- (void)start
{
    //存储已使用过标记，在以后再启动应用时不再显示NewFeature（宣传画）界面
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"true" forKey:@"notFirstUse"];
    // 进入主页
    // 切换根控制器:可以直接把之前的根控制器清空
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (self.backType == 0) {
        delegate.window.rootViewController = delegate.myRootController;
    } else {
        [delegate.myRootController popViewControllerAnimated:YES];
    }

}

@end
