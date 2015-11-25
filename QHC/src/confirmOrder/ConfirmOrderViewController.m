//
//  ConfirmOrderViewController.m
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "ConfirmOrderView.h"
#import "AppDelegate.h"
#import "ConfirmOrder_product.h"
#import "BatchConfirmOrder.h"

@interface ConfirmOrderViewController ()

@end

@implementation ConfirmOrderViewController

@synthesize orderFormDetailDic;

-(id)initWithOrderInfo:(NSDictionary*)orderInfoDic {
    self = [super init];
    if (self) {
        self.orderFormDetailDic = orderInfoDic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    
    if ([self.orderFormDetailDic objectForKey:@"productid"]) {//家具产品
        ConfirmOrder_product *formDetailView = [[ConfirmOrder_product alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andOrderInfo:orderFormDetailDic];
        [self.view addSubview:formDetailView];
    } else if ([self.orderFormDetailDic objectForKey:@"projectlist"] || [self.orderFormDetailDic objectForKey:@"orderlist"]) {//批量支付或购买
        BatchConfirmOrder *formDetailView = [[BatchConfirmOrder alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andOrderInfo:orderFormDetailDic];
        [self.view addSubview:formDetailView];
    } else {//单个项目购买
        ConfirmOrderView *formDetailView = [[ConfirmOrderView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andOrderInfo:orderFormDetailDic];
        [self.view addSubview:formDetailView];
    }
    

    // Do any additional setup after loading the view.
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"订单确认";
    
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
