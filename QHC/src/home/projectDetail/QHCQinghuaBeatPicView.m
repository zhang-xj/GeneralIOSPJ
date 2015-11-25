//
//  QHCQinghuaBeatPicView.m
//  QHC
//
//  Created by qhc2015 on 15/6/25.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//  展示青花敲术发展史图片的视图

#import "QHCQinghuaBeatPicView.h"

@implementation QHCQinghuaBeatPicView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        [imageView setImage:[UIImage imageNamed:@"qinghuaBeatProcess.png"]];
        [self addSubview:imageView];
        
        UIButton *exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
        [exitBtn setTitle:@"关" forState:UIControlStateNormal];
        [exitBtn addTarget:self action:@selector(exitAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:exitBtn];
    }
    return  self;
}

-(void)exitAction:(id)sender{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
