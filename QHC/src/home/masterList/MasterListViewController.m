//
//  MasterListViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/16.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MasterListViewController.h"
#import "MasterSearchListViewController.h"
#import "MasterListView.h"
#import "AppDelegate.h"

@interface MasterListViewController ()

@end

@implementation MasterListViewController

@synthesize propertyDic;
@synthesize selectedMasterInfoDic;
@synthesize storeIndex;

@synthesize masterSearchView;

- (id)initWithProperty:(NSDictionary*)property storeID:(NSString*)storeId isSelectedView:(BOOL)selected {
    self = [super init];
    if (self) {
        self.propertyDic = property;
        self.storeIndex = storeId;
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
    
    //初始化养生顾问列表页面
    MasterListView *mlView = [[MasterListView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andProperty:propertyDic storeID:storeIndex isSelectedView:isSelected];
    mlView.delegate = self;
    [self.view addSubview:mlView];
    
    //初始化模糊搜索养生顾问页面
    self.masterSearchView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.masterSearchView.hidden = YES;
    self.masterSearchView.backgroundColor = [UIColor viewBackgroundColor];
    [self.view addSubview:masterSearchView];
    [self initSearchView];
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"养生顾问";
    
    UIButton *leftButton = (UIButton*)[titleView viewWithTag:LEFT_BUTTON];
    leftButton.hidden = NO;
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightButton = (UIButton*)[titleView viewWithTag:RIGHT_BUTTON];
    rightButton.hidden = NO;
    if (isSelected) {
        [rightButton setTitle:@"确定" forState:UIControlStateNormal];
        rightButton.titleLabel.font = BUTTON_TEXT_FONT;
        [rightButton addTarget:self action:@selector(selectedMasterAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [rightButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(searchMasterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return titleView;
}

-(void)backAction:(id)sender {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

-(void)selectedMasterAction:(id)sender {
    if (self.delegate && selectedMasterInfoDic) {
        [self.delegate selectedMasterInfo:selectedMasterInfoDic];
        [self backAction:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  MasterListViewDelegate
-(void)selectedMaster:(NSDictionary*)masterInfoDic {
    self.selectedMasterInfoDic = masterInfoDic;
}

//查找养生顾问动作
-(void)searchMasterAction:(id)sender {
    self.masterSearchView.hidden = NO;
    UITextField *textField = (UITextField*)[masterSearchView viewWithTag:7777];
    [textField setReturnKeyType:UIReturnKeySearch];//设置return键类型
    [textField becomeFirstResponder];//自动打开软键盘
}

-(void)hideSearchView:(id)sender{
    [((UITextField*)[masterSearchView viewWithTag:7777]) resignFirstResponder];//隐藏软键盘
    self.masterSearchView.hidden = YES;
    
}

-(void)initSearchView {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.masterSearchView.frame.size.width, 50)];
    view.backgroundColor = [UIColor tableViewBackgroundColor];
    [self.masterSearchView addSubview:view];
    
    //输入框
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 8.0, view.frame.size.width - 64, 34)];
    searchField.layer.borderColor = [UIColor viewBackgroundColor].CGColor;
    searchField.layer.borderWidth = 1;
    searchField.layer.cornerRadius = 4;
    [searchField setTag:7777];
    searchField.delegate = self;
    searchField.placeholder = @"请输入养生师名字";
    [view addSubview:searchField];
    
    //取消按钮
    UIButton *cannel = [[UIButton alloc] initWithFrame:CGRectMake(searchField.frame.size.width + 16, 0, 40, view.frame.size.height)];
    [cannel setTitle:@"取消" forState:UIControlStateNormal];
    [cannel setTitleColor:[UIColor priceTextColor] forState:UIControlStateNormal];
    cannel.titleLabel.font = BUTTON_TEXT_FONT;
    [cannel addTarget:self action:@selector(hideSearchView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cannel];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *text = textField.text;
    if (text) {
        text =[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//去前后空格
    }
    if (text.length > 0) {
        MasterSearchListViewController *searchResultViewController = [[MasterSearchListViewController alloc] initWithProperty:textField.text];
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.myRootController pushViewController:searchResultViewController animated:YES];
    }
    return YES;
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
