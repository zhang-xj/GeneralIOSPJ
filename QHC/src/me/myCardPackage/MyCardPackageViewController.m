//
//  MyCardPackageViewController.m
//  QHC
//
//  Created by qhc2015 on 15/7/27.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MyCardPackageViewController.h"
#import "AppDelegate.h"
#import "MyCardPackageView.h"

@interface MyCardPackageViewController ()

@end

@implementation MyCardPackageViewController

@synthesize  selectedCardDic;

-(id) initWithProperty:(NSDictionary*)property {
    self = [super init];
    if (self) {
        isSelect = [@"yes" isEqualToString:[property objectForKey:@"selected"]];
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
    
    if (isSelect) {
        MyCardPackageView_select *cardPackageView = [[MyCardPackageView_select alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height)];
        cardPackageView.delegate = self;
        [self.view addSubview:cardPackageView];
    } else {
        MyCardPackageView *cardPackageView = [[MyCardPackageView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height)];
        [self.view addSubview:cardPackageView];
    }
    
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"我的卡包";
    
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

-(void)selectedCardAction:(id)sender {
    if (self.delegate) {
        [self.delegate selectedCardPackageResult:selectedCardDic];
        [self backAction:nil];
    }
}

#pragma mark MyCardPackageView_selectDelegate
-(void) selectedResult:(NSDictionary*)selectedDic {
    self.selectedCardDic = selectedDic;
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
