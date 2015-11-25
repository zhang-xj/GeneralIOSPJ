//
//  QHCHomeViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/4.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//  主页

#import "QHCHomeViewController.h"
#import "AppDelegate.h"
#import "BWMCoverView.h"


@interface QHCHomeViewController ()

@end

@implementation QHCHomeViewController

@synthesize homeView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
//    self.view.backgroundColor = [UIColor whiteColor];
    self.homeView = [[QHCHomeView alloc]initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height - 49)];
    [self.view addSubview:homeView];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    BWMCoverView *coverView = (BWMCoverView*)[self.homeView viewWithTag:1688];
    [coverView stopAutoPlayWithBOOL:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BWMCoverView *coverView = (BWMCoverView*)[self.homeView viewWithTag:1688];
    [coverView stopAutoPlayWithBOOL:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"青花瓷  养生美容";
    
    UIButton *leftButton = (UIButton*)[titleView viewWithTag:LEFT_BUTTON];
    leftButton.hidden = NO;
    //获取上一次用户选择的城市
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *btnTitle = [userDefaults stringForKey:DEFAULT_CITY];
    if ([userDefaults objectForKey:USER_SELECTED_CITY]) {//如果用户已经选择过城市了，那么就显示用户选择的城市
        btnTitle = [userDefaults stringForKey:USER_SELECTED_CITY];
    } else if ([userDefaults objectForKey:LOCATION_CITY]) {//如果用户没有选择过城市，但定位到了城市，就显示定位的城市
        btnTitle = [userDefaults stringForKey:LOCATION_CITY];
    }
    CGSize size = [AppDelegate getStringInLabelSize:btnTitle andFont:BUTTON_TEXT_FONT  andLabelWidth:100];
    CGRect lbFrame = leftButton.frame;
    lbFrame.size.width = size.width + 25;
    leftButton.frame = lbFrame;
    [leftButton setTag:LEFT_BUTTON];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftButton.titleLabel.font = BUTTON_TEXT_FONT;
    
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(3, size.width + 10, 0, 0)];
    [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
    [leftButton setTitle:btnTitle forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"down_arrow.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(showCityList) forControlEvents:UIControlEventTouchUpInside];
    
    //右边按钮
    //    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(tvWidth - CONTENT_OFFSET - 5.0, 0.0, CONTENT_OFFSET, CONTENT_OFFSET)];
    //    [rightButton setTag:RIGHT_BUTTON];
    //    rightButton.hidden = YES;
    //    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    leftButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    //    [topView addSubview:rightButton];
    
    return titleView;
}

//添加顶部标题视图
-(void)addTopTitleView {
    float tvWidth = [UIScreen mainScreen].applicationFrame.size.width;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tvWidth, TOP_VIEW_H)];
    //背景图片
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tvWidth, TOP_VIEW_H)];
    [bgImgView setImage:[UIImage imageNamed:@"topTitleBg.png"]];
    [bgImgView setTag:TITLE_BACKGROUND];
    [topView addSubview:bgImgView];
    //左边按钮
    //获取上一次用户选择的城市
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *btnTitle = [userDefaults stringForKey:DEFAULT_CITY];
    if ([userDefaults objectForKey:USER_SELECTED_CITY]) {//如果用户已经选择过城市了，那么就显示用户选择的城市
        btnTitle = [userDefaults stringForKey:USER_SELECTED_CITY];
    } else if ([userDefaults objectForKey:LOCATION_CITY]) {//如果用户没有选择过城市，但定位到了城市，就显示定位的城市
        btnTitle = [userDefaults stringForKey:LOCATION_CITY];
    }
    CGSize size = [AppDelegate getStringInLabelSize:btnTitle andFont:BUTTON_TEXT_FONT  andLabelWidth:100];
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width + 25, CONTENT_OFFSET)];
    [leftButton setTag:LEFT_BUTTON];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftButton.titleLabel.font = BUTTON_TEXT_FONT;
    
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(3, size.width + 10, 0, 0)];
    [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
    [leftButton setTitle:btnTitle forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"down_arrow.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(showCityList) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftButton];
    
    
    //页面标题文字
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_OFFSET + 20.0, 0.0, tvWidth - 2*CONTENT_OFFSET, CONTENT_OFFSET)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"青花瓷  养生美容";
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    [topView addSubview:titleLabel];
    
    [self.view addSubview:topView];
}


//显示地区选项列表
-(void)showCityList {
    SelectCityViewController *scvController = [[SelectCityViewController alloc] init];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    scvController.delegate = self;
    [appDelegate.myRootController pushViewController:scvController animated:YES];
}


#pragma mark SelectCityViewControllerDelegate
-(void)selectedCity:(NSString *)cityName {
    UIButton *leftButton = (UIButton*)[self.view viewWithTag:LEFT_BUTTON];
    [leftButton setTitle:cityName forState:UIControlStateNormal];
    //保存用户选择的城市
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cityName forKey:USER_SELECTED_CITY];
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
