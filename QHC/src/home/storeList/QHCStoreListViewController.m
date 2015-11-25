//
//  QHCStoreListViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/17.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCStoreListViewController.h"
#import "QHCStoreListView.h"
#import "AppDelegate.h"

@interface QHCStoreListViewController ()

@end

@implementation QHCStoreListViewController

@synthesize propertyDic;
@synthesize selectedStoreInfoDic;

- (id)initWithProperty:(NSDictionary*)property isSelectedView:(BOOL)selected {
    self = [super init];
    if (self) {
        self.propertyDic = property;
        isSelected = selected;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
//    UIView *contentView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
//    [self.view addSubview:contentView];
//    [self addTopTitleView:contentView];
    
    QHCStoreListView *slView = [[QHCStoreListView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andProperty:self.propertyDic isSelectedView:isSelected];
    slView.delegate = self;
    [self.view addSubview:slView];
}

-(void)backAction:(id)sender {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

-(void)selectedStoreAction:(id)sender {
    if (self.delegate && selectedStoreInfoDic) {
        [self.delegate selectedStoreInfo:selectedStoreInfoDic];
        [self backAction:nil];
    }
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"门店";
    
    UIButton *leftButton = (UIButton*)[titleView viewWithTag:LEFT_BUTTON];
    leftButton.hidden = NO;
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (isSelected) {
        UIButton *rightButton = (UIButton*)[titleView viewWithTag:RIGHT_BUTTON];
        rightButton.hidden = NO;
        [rightButton setTitle:@"确定" forState:UIControlStateNormal];
        rightButton.titleLabel.font = BUTTON_TEXT_FONT;
        [rightButton addTarget:self action:@selector(selectedStoreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return titleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark QHCStoreListViewDelegate
-(void)selectedStore:(NSDictionary*)storeInfoDic {
    self.selectedStoreInfoDic = storeInfoDic;
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
