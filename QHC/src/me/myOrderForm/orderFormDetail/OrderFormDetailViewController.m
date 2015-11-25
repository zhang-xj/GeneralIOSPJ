//
//  OrderFormViewController.m
//  QHC
//
//  Created by qhc2015 on 15/7/14.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "OrderFormDetailViewController.h"
#import "AppDelegate.h"
#import "OrderFormDetailView.h"
#import "ProductOrderFormDetailView.h"

@interface OrderFormDetailViewController ()

@end

@implementation OrderFormDetailViewController

@synthesize orderInfoDic;

-(id)initWithOrderInfo:(NSDictionary*)orderInfo {
    self = [super init];
    if (self) {
        self.orderInfoDic = orderInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    NSString *orderid = [self.orderInfoDic objectForKey:@"orderid"];
    if ([orderid rangeOfString:@"P"].location == NSNotFound) {
        OrderFormDetailView *formDetailView = [[OrderFormDetailView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andOrderInfo:self.orderInfoDic];
        [self.view addSubview:formDetailView];
    } else {
        ProductOrderFormDetailView *productFormDetailView = [[ProductOrderFormDetailView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andOrderInfo:self.orderInfoDic];
        [self.view addSubview:productFormDetailView];
    }

}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"订单详情";
    
    UIButton *leftButton = (UIButton*)[titleView viewWithTag:LEFT_BUTTON];
    leftButton.hidden = NO;
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return titleView;
}

-(void)backAction:(id)sender {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
