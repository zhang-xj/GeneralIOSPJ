//
//  QHCHomeView.m
//  QHC
//
//  Created by qhc2015 on 15/6/4.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCHomeView.h"
#import "BWMCoverView.h"
#import "QHCProjectDetailViewController.h"
#import "QHCBeautifulViewController.h"
#import "MasterListViewController.h"
#import "QHCStoreListViewController.h"
#import "AppDelegate.h"
#import "QHCProjectListViewController.h"
#import "HomeProductViewController.h"
#import "QHBeatDetailProjectViewController.h"

@implementation QHCHomeView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        float height = [self createMainMenu:contentView];//菜单项
        height += [self createBWMCoverView:contentView];//图片轮播器
        [contentView setContentSize:CGSizeMake(contentView.frame.size.width, height + 15)];
        [self addSubview:contentView];
        
    }
    return self;
}



//创建主页菜单项
-(float)createMainMenu:(UIView*) superView {
    float wScale = self.frame.size.width/320;
    float y = COVER_VIEW_H*wScale;
    float x_y_Offset  = 6*wScale;
    
    
    //菜单父窗口
    UIView *sView = [[UIView alloc] init];
    [superView addSubview:sView];
    
    float itemW = (self.frame.size.width - 3*x_y_Offset)/2;
    
    float sViewH1 = x_y_Offset;
    //青花敲术
    UIImage *img = [UIImage imageNamed:@"qinghuaBeat.png"];
    float img_h = img.size.height;
    UIButton *qinghuaBeat = [[UIButton alloc] initWithFrame:CGRectMake(x_y_Offset, x_y_Offset, itemW, img_h*wScale)];
    [qinghuaBeat setBackgroundImage:img forState:UIControlStateNormal];
    [qinghuaBeat setBackgroundImage:[UIImage imageNamed:@"qinghuaBeat_sel.png"] forState:UIControlStateHighlighted];
    [qinghuaBeat addTarget:self action:@selector(qinghuaBeatAction:) forControlEvents:UIControlEventTouchUpInside];
    [sView addSubview:qinghuaBeat];
    sViewH1 += img_h*wScale;
    //面部护理
    sViewH1 += x_y_Offset;
    img = [UIImage imageNamed:@"faceCare.png"];
    img_h = img.size.height;
    UIButton *faceCare = [[UIButton alloc] initWithFrame:CGRectMake(x_y_Offset, sViewH1, itemW, img_h * wScale)];
    [faceCare setBackgroundImage:img forState:UIControlStateNormal];
    [faceCare setBackgroundImage:[UIImage imageNamed:@"faceCare_sel.png"] forState:UIControlStateHighlighted];
    [faceCare addTarget:self action:@selector(faceCareAction:) forControlEvents:UIControlEventTouchUpInside];
    [sView addSubview:faceCare];
    sViewH1 += img_h*wScale;
    //养生顾问
    sViewH1 += x_y_Offset;
    img = [UIImage imageNamed:@"lifeMaster.png"];
    img_h = img.size.height;
    UIButton *keepLifeMaster = [[UIButton alloc] initWithFrame:CGRectMake(x_y_Offset, sViewH1, itemW / 2 - x_y_Offset/2, img_h*wScale)];
    [keepLifeMaster setBackgroundImage:img forState:UIControlStateNormal];
    [keepLifeMaster setBackgroundImage:[UIImage imageNamed:@"lifeMaster_sel.png"] forState:UIControlStateHighlighted];
    [keepLifeMaster addTarget:self action:@selector(lifeMasterAction:) forControlEvents:UIControlEventTouchUpInside];
    [sView addSubview:keepLifeMaster];
    //门店分布
    img = [UIImage imageNamed:@"storeSpread.png"];
    img_h = img.size.height;
    UIButton *storeSpread = [[UIButton alloc] initWithFrame:CGRectMake(x_y_Offset + itemW / 2 + x_y_Offset/2, sViewH1, itemW/2-x_y_Offset/2, img_h*wScale)];
    [storeSpread setBackgroundImage:img forState:UIControlStateNormal];
    [storeSpread setBackgroundImage:[UIImage imageNamed:@"storeSpread_sel.png"] forState:UIControlStateHighlighted];
    [storeSpread addTarget:self action:@selector(storeSpreadAction:) forControlEvents:UIControlEventTouchUpInside];
    [sView addSubview:storeSpread];
    sViewH1 += img_h*wScale;
    
    float sViewH2 = x_y_Offset;
    float itemX = self.frame.size.width / 2 + x_y_Offset/2;
    //美丽私人定制
    img = [UIImage imageNamed:@"beautifulCustomization.png"];
    img_h = img.size.height;
    UIButton *beautifulCustomization = [[UIButton alloc] initWithFrame:CGRectMake(itemX, x_y_Offset, itemW, img_h*wScale)];
    [beautifulCustomization setBackgroundImage:img forState:UIControlStateNormal];
    [beautifulCustomization setBackgroundImage:[UIImage imageNamed:@"beautifulCustomization_sel.png"] forState:UIControlStateHighlighted];
    [beautifulCustomization addTarget:self action:@selector(beautifulCustomizationAction:) forControlEvents:UIControlEventTouchUpInside];
    [sView addSubview:beautifulCustomization];
    sViewH2 += img_h*wScale;
    //身体调养
    sViewH2 += x_y_Offset;
    img = [UIImage imageNamed:@"bodyCare.png"];
    img_h = img.size.height;
    UIButton *bodyCare = [[UIButton alloc] initWithFrame:CGRectMake(itemX, sViewH2, itemW, img_h*wScale)];
    [bodyCare setBackgroundImage:img forState:UIControlStateNormal];
    [bodyCare setBackgroundImage:[UIImage imageNamed:@"bodyCare_sel.png"] forState:UIControlStateHighlighted];
    [bodyCare addTarget:self action:@selector(bodyCareAction:) forControlEvents:UIControlEventTouchUpInside];
    [sView addSubview:bodyCare];
    sViewH2 += img_h*wScale;
    //家居产品
    sViewH2 += x_y_Offset;
    img = [UIImage imageNamed:@"homeProducts.png"];
    img_h = img.size.height;
    UIButton *homeProducts = [[UIButton alloc] initWithFrame:CGRectMake(itemX, sViewH2, itemW, img_h*wScale)];
    [homeProducts setBackgroundImage:img forState:UIControlStateNormal];
    [homeProducts setBackgroundImage:[UIImage imageNamed:@"homeProducts_sel.png"] forState:UIControlStateHighlighted];
    [homeProducts addTarget:self action:@selector(homeProductsAction:) forControlEvents:UIControlEventTouchUpInside];
    [sView addSubview:homeProducts];
    sViewH2 += img_h*wScale;
    
    float sViewH = sViewH1 > sViewH2 ? sViewH1 : sViewH2;
    CGRect rect = CGRectMake(0, y, superView.frame.size.width, sViewH);
    sView.frame = rect;
    return sViewH;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    CGRect cvFrame = CGRectMake(0.0, 0.0, self.frame.size.width, COVER_VIEW_H*(self.frame.size.width/320.0));
    BWMCoverView *coverView = [BWMCoverView coverViewWithModels:realArray andFrame:cvFrame andPlaceholderImageNamed:@"default_detail_img.png" andClickdCallBlock:^(NSInteger index) {
        
    }];
    [coverView setTag:1688];
    cvFrame = coverView.frame;
    [superView addSubview:coverView];
    
    
    // 滚动视图每一次滚动都会回调此方法
    [coverView setScrollViewCallBlock:^(NSInteger index) {
        //NSLog(@"当前滚动到第%d个页面", index);
    }];
    
    // 请打开下面的东西逐个调试
    [coverView setAutoPlayWithDelay:2.0]; // 设置自动播放
    [coverView stopAutoPlayWithBOOL:YES];
    
    return cvFrame.size.height;
}

//身体调养action
-(void)bodyCareAction:(id)sender{
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"身体护理", @"1", nil] forKeys:[NSArray arrayWithObjects:@"title", @"type", nil]];
    QHCProjectListViewController *bdvController = [[QHCProjectListViewController alloc] initWithData:params];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:bdvController animated:YES];
}
//面部护理action
-(void)faceCareAction:(id)sender{
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"面部护理", @"2", nil] forKeys:[NSArray arrayWithObjects:@"title", @"type", nil]];
    QHCProjectListViewController *faceCareProListViewControl = [[QHCProjectListViewController alloc] initWithData:params];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:faceCareProListViewControl animated:YES];
}
//家居产品action
-(void)homeProductsAction:(id)sender{
        NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"家居产品", @"3", nil] forKeys:[NSArray arrayWithObjects:@"title", @"type", nil]];
//    QHCProjectListViewController *productListViewControl = [[QHCProjectListViewController alloc] initWithData:params];
    HomeProductViewController *productListViewControl = [[HomeProductViewController alloc] initWithProperty:params];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:productListViewControl animated:YES];
}
//青花敲术action
-(void)qinghuaBeatAction:(id)sender{
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"青花敲术", @"10100026", nil] forKeys:[NSArray arrayWithObjects:@"title", @"projectid", nil]];
    QHBeatDetailProjectViewController *beatController = [[QHBeatDetailProjectViewController alloc] initWithData:params];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:beatController animated:YES];
}
//美丽定制action
-(void)beautifulCustomizationAction:(id)sender{
    QHCBeautifulViewController *beautifulViewCtrl = [[QHCBeautifulViewController alloc] init];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:beautifulViewCtrl animated:YES];
}
//门店分布action
-(void)storeSpreadAction:(id)sender{
    QHCStoreListViewController *sllController = [[QHCStoreListViewController alloc] initWithProperty:nil isSelectedView:NO];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:sllController animated:YES];
}
//养生顾问action
-(void)lifeMasterAction:(id)sender{

    MasterListViewController *mtlController = [[MasterListViewController alloc] init];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:mtlController animated:YES];
}

@end
