//
//  BodyCareView.m
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCBodyCareView.h"
#import "AppDelegate.h"
#import "BWMCoverView.h"

@implementation QHCBodyCareView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, CONTENT_OFFSET, frame.size.width, frame.size.height - CONTENT_OFFSET)];
        //        contentView.backgroundColor = [UIColor blueColor];
        [self createBWMCoverView:contentView];
        [self addSubview:contentView];
        [self createTopTitleView];
        
        
        
    }
    return self;
}

-(void)backAction:(id)sender {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

//创建首页顶部标题视图
-(void)createTopTitleView {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, TOP_VIEW_H)];
    //背景图片
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, TOP_VIEW_H)];
    [bgImgView setImage:[UIImage imageNamed:@"topTitleBg.png"]];
    [topView addSubview:bgImgView];
    //返回按钮
    UIButton *changeAreaBtn = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 0.0, 40.0, CONTENT_OFFSET)];
    [changeAreaBtn setTitle:@"返回" forState:UIControlStateNormal];
    [changeAreaBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:changeAreaBtn];
    //页面标题文字
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, self.frame.size.width - 70, CONTENT_OFFSET)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"身体护理";
    [topView addSubview:titleLabel];
    
    [self addSubview:topView];
}

//图片轮播器
-(void)createBWMCoverView:(UIView*) superView{
    
    // 此数组用来保存BWMCoverViewModel
    NSMutableArray *realArray = [[NSMutableArray alloc] init];
    //pragma mark -- 可以通过更改 i 值来 改变图片滚动的数量
    for (int i = 0; i<4; i++) {
        //        NSString *imageStr = [NSString stringWithFormat:@"http://www.iphone567.com/wp-content/uploads/2014/10/image0%d.jpg", i+1];
        NSString *imageStr = [NSString stringWithFormat:@"bodyCarePoster%d.png", i+1];
        [realArray addObject:imageStr];
    }
    
    /**
     * 快速创建BWMCoverView
     * models是一个包含BWMCoverViewModel的数组
     * placeholderImageNamed为图片加载前的本地占位图片名
     不知道为什么这个视图会往下移20dp，所以在初始化时写－20.0
     */
    CGRect cvFrame = CGRectMake(0.0, -20.0, self.frame.size.width, COVER_VIEW_H*(self.frame.size.width/320.0));
    BWMCoverView *coverView = [BWMCoverView coverViewWithModels:realArray andFrame:cvFrame andPlaceholderImageNamed:@"bodyCarePoster1.png" andClickdCallBlock:^(NSInteger index) {
        
    }];
    cvFrame = coverView.frame;
    [superView addSubview:coverView];
    
    
    // 滚动视图每一次滚动都会回调此方法
    [coverView setScrollViewCallBlock:^(NSInteger index) {
        //NSLog(@"当前滚动到第%d个页面", index);
    }];
    
    // 请打开下面的东西逐个调试
    [coverView setAutoPlayWithDelay:3.0]; // 设置自动播放
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
