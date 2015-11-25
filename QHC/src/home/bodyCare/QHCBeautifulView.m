//
//  BodyCareView.m
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCBeautifulView.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"


@implementation QHCBeautifulView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [self addSubview:contentView];
        
        [self createContentView:contentView];
    }
    return self;
}

-(void)createContentView:(UIScrollView *)superView {
    UIImageView *contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, superView.frame.size.width, 492.5*(superView.frame.size.width/320))];
    contentImageView.contentMode = UIViewContentModeScaleToFill;
    [contentImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Image/ClientImage/beautiful.png", BASE_URL]]];
    [superView addSubview:contentImageView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0, contentImageView.frame.size.height, superView.frame.size.width, 88)];
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, superView.frame.size.width, 88)];
    bg.contentMode = UIViewContentModeScaleToFill;
    [bg  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Image/ClientImage/bottomBg.png", BASE_URL]]];
    [bottomView addSubview:bg];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((superView.frame.size.width - 215)/2, 17.5, 215, 25)];
    [btn setTitle:@"敬请莅临青花瓷门店咨询详情" forState:UIControlStateNormal];
    btn.titleLabel.font = BUTTON_TEXT_FONT;
    [btn setBackgroundImage:[UIImage imageNamed:@"logoutBtnBg.png"] forState:UIControlStateNormal];
    [bottomView addSubview:btn];
    [superView addSubview:bottomView];
    
    [superView setContentSize:CGSizeMake(superView.frame.size.width, contentImageView.frame.size.height + bottomView.frame.size.height)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
