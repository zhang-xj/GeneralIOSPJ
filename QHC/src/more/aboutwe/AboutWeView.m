//
//  AboutWeView.m
//  QHC
//
//  Created by qhc2015 on 15/7/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "AboutWeView.h"
#import "AppDelegate.h"
#import "BWMCoverView.h"
#import "CZNewFeatureController.h"

@implementation AboutWeView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentView];
    }
    return self;
}


-(void)showNewFeature:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CZNewFeatureController *vc = [[CZNewFeatureController alloc]initWithType:1];
    [appDelegate.myRootController pushViewController:vc animated:YES];
}

-(void)createContentView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:scrollView];
    
    float contentHeight = 0.0;
    contentHeight = [self createBWMCoverView:scrollView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, contentHeight, scrollView.frame.size.width, 120)];
    view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    [scrollView addSubview:view];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width/4, view.frame.size.height - 34, view.frame.size.width / 2, 25)];
    btn.titleLabel.font = BUTTON_TEXT_FONT;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"查看：三姐妹“励志传奇”" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"aboutBtn.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showNewFeature:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    float x_offset = 5;
    float item_w = 67.5;
    float item_h = 68;
    float first_x = (view.frame.size.width - 3*item_w - 2*x_offset) / 2;
    for (int i = 0; i < 3; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(first_x + i*(item_w + x_offset), 12, item_w, item_h)];
        [imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"aboutIcon%d.png", i+1]]];
        [view addSubview:imgView];
    }
    
    contentHeight = view.frame.origin.y + view.frame.size.height;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, contentHeight, scrollView.frame.size.width, 80)];
    view1.backgroundColor = [UIColor whiteColor];

    UILabel *label=[[UILabel alloc]init];
    label.font=[UIFont systemFontOfSize:13];
    label.numberOfLines=0;
    CGSize strsize= CGSizeMake(view1.frame.size.width-30, MAXFLOAT);
    NSString *str=@"▪   青花瓷健康管理有限公司创立于2004年，是一家集“女子健康养生”的直营门店经营公司，传承中华艾灸经络精髓，您的健康，精心守护。\r\n▪   “艾灸”与“经络”养生美容，安全有效，自然调养，天然卫生生物制品，简单，高效，环保，门店全员合伙，为来自社会基层的青花瓷员工建立一个造梦平台，为每一位平凡的姑娘提供机会实现人生价值。\r\n▪    青花瓷始终坚持“打造健康青花瓷，快乐青花瓷，幸福青花瓷” 的企业使命，致力于成为全球社区健康管理第一品牌。";
    CGSize size = [AppDelegate getStringInLabelSize:str andFont:label.font andLabelWidth:strsize.width];
    label.frame = CGRectMake(15, 10, size.width, size.height);
    label.text = str;
    
    float view1_height =label.frame.size.height+label.frame.origin.y;
    UIView *line=[[UIImageView alloc]initWithFrame:CGRectMake(0, view1_height + 60, view1.frame.size.width, 1)];
    line.backgroundColor=RGBA(204, 204, 204, 255);
    
    UIImageView *icon=[[UIImageView alloc]initWithFrame:CGRectMake(0, view1_height + 10, view1.frame.size.width, 100)];
    icon.contentMode=UIViewContentModeScaleAspectFit;
    icon.image=[UIImage imageNamed:@"aboutIcon4.png"];
    
    view1_height = icon.frame.size.height+icon.frame.origin.y;
    UILabel *temp=[[UILabel alloc]initWithFrame:CGRectMake(0.0, view1_height+10,scrollView.frame.size.width,15)];
    NSString *versiongString = [NSString stringWithFormat:@"青花瓷 v%@", [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    temp.text= versiongString;
    temp.textAlignment=NSTextAlignmentCenter;
    temp.font=[UIFont systemFontOfSize:13];
    
    view1_height = temp.frame.size.height+temp.frame.origin.y + 10;
    [view1 addSubview:label];
    [view1 addSubview:line];
    [view1 addSubview:icon];
    [view1 addSubview:temp];
    view1.frame = CGRectMake(view1.frame.origin.x, view1.frame.origin.y, view1.frame.size.width, view1_height);
    [scrollView addSubview:view1];

    contentHeight = view1.frame.origin.y + view1.frame.size.height;
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, contentHeight, scrollView.frame.size.width, 60)];
    view2.backgroundColor = RGBA(191, 193, 194, 255);
    [scrollView addSubview:view2];
    
    UILabel *lb1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 14, view2.frame.size.width, 15)];
    lb1.font = [UIFont systemFontOfSize:13];
    lb1.textAlignment = NSTextAlignmentCenter;
    lb1.text = @"© 2015 ALL TIGHTS RESERVED";
    [view2 addSubview:lb1];
    UILabel *lb2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, lb1.frame.size.height + lb1.frame.origin.y, view2.frame.size.width, 15)];
    lb2.font = [UIFont systemFontOfSize:13];
    lb2.textAlignment = NSTextAlignmentCenter;
    lb2.text = @"www.gzqhc.com  400-836-8362";
    [view2 addSubview:lb2];
    
    contentHeight += view2.frame.size.height;
    scrollView.contentSize=CGSizeMake(scrollView.frame.size.width, contentHeight);
    
}

//图片轮播器
-(float)createBWMCoverView:(UIView*) superView{
    
    // 此数组用来保存BWMCoverViewModel
    NSMutableArray *realArray = [[NSMutableArray alloc] init];
    //pragma mark -- 可以通过更改 i 值来 改变图片滚动的数量
    for (int i = 0; i<3; i++) {
        NSString *imageStr = [NSString stringWithFormat:@"%@Image/ClientImage/IndexImage%d.png", BASE_URL, i+1];
        //        NSString *imageStr = [NSString stringWithFormat:@"cover_image%d.png", i+1];
        [realArray addObject:imageStr];
    }
    
    /**
     * 快速创建BWMCoverView
     * models是一个包含BWMCoverViewModel的数组
     * placeholderImageNamed为图片加载前的本地占位图片名
     */
    CGRect cvFrame = CGRectMake(0.0, -0.0, self.frame.size.width, COVER_VIEW_H*(self.frame.size.width/320.0));
    BWMCoverView *coverView = [BWMCoverView coverViewWithModels:realArray andFrame:cvFrame andPlaceholderImageNamed:@"cover_image1.png" andClickdCallBlock:^(NSInteger index) {
        
    }];
    cvFrame = coverView.frame;
    [superView addSubview:coverView];
    
    
    // 滚动视图每一次滚动都会回调此方法
    [coverView setScrollViewCallBlock:^(NSInteger index) {
        //NSLog(@"当前滚动到第%d个页面", index);
    }];
    
    // 请打开下面的东西逐个调试
    [coverView setAutoPlayWithDelay:2.0]; // 设置自动播放
    
    return COVER_VIEW_H*(self.frame.size.width/320.0);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
