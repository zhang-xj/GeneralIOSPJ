//
//  QHCMeView.m
//  QHC
//
//  Created by qhc2015 on 15/6/5.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCMeView.h"
#import "AppDelegate.h"
#import "QHCMyOrderFormViewController.h"
#import "PersonalInfoViewController.h"
#import "MyCollectViewController.h"
#import "MyCardPackageViewController.h"
#import "UIImageView+WebCache.h"

@implementation QHCMeView

#ifndef CELL_HEIGHT
#define CELL_HEIGHT 40
#endif

@synthesize tableCellTitleArray;
@synthesize meTableView;
@synthesize selectedIndexPath;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentView];
    }
    return self;
}

//创建内容视图
-(void)createContentView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, self.frame.size.width, self.frame.size.height)];
    
    self.tableCellTitleArray = [[NSArray alloc] initWithObjects:@"我的订单", @"我的卡包", @"我的收藏", nil];
    
    self.meTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, contentView.frame.size.width, contentView.frame.size.height - 49) style:UITableViewStyleGrouped];
    meTableView.delegate = self;
    meTableView.dataSource = self;
    meTableView.backgroundColor = [UIColor clearColor];
    
//    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, contentView.frame.size.width, 210*(contentView.frame.size.width/320))];
//    [bgImgView setImage:[UIImage imageNamed:@"topBackground.png"]];
//    meTableView.tableHeaderView = bgImgView;
    
    [contentView addSubview:meTableView];
    
    [self addSubview:contentView];
}

-(void)refreshContentView {
    [self.meTableView reloadData];
}

//进入登录页
-(void)showLoginView {
    LoginView *loginView = [[LoginView alloc ]initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    loginView.delegate = self;
    [self addSubview:loginView];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, CONTENT_OFFSET, CONTENT_OFFSET)];
    [closeBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeLoginView:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTag:123];
    [self addSubview:closeBtn];
}
-(void)closeLoginView:(id)sender {
    [[self viewWithTag:LOGIN_VIEW_TAG] removeFromSuperview];
    [[self viewWithTag:123] removeFromSuperview];
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        AppDelegate *appDelegate = APPDELEGATE;
        appDelegate.tabBarController.selectedIndex = 1;
    }
}

//进入用户访问的页面
-(void)showSelectedContentView:(NSIndexPath*)indexPath{
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    NSInteger index = [indexPath indexAtPosition:1];
    if(index == 0){
        PersonalInfoViewController *plivController = [[PersonalInfoViewController alloc] init];
        [appDelegate.myRootController pushViewController:plivController animated:YES];
    } else if (index == 1) {//订单
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:NOT_RESERVATION]) {//还有未评价的预约单
            UIAlertView *alert = [[UIAlertView alloc]
                                  
                                  initWithTitle:@"提示"
                                  
                                  message:@"亲，您还有未评价的预约单哦，马上到“预约”－“未评价”里评价吧。"
                                  
                                  delegate: self
                                  
                                  cancelButtonTitle:@"取消"
                                  
                                  otherButtonTitles:@"好的",nil];
            
            [alert show]; //显示
        } else {
            QHCMyOrderFormViewController *ofController = [[QHCMyOrderFormViewController alloc] initWithTitle:@"我的订单" pType:1];
            [appDelegate.myRootController pushViewController:ofController animated:YES];
        }
    } else if (index == 2) {//卡包
        MyCardPackageViewController *cardPKController = [[MyCardPackageViewController alloc] init];
        [appDelegate.myRootController pushViewController:cardPKController animated:YES];
    } else if (index == 3) {//收藏
        MyCollectViewController *collectController = [[MyCollectViewController alloc] init];
        [appDelegate.myRootController pushViewController:collectController animated:YES];
    }
}

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [tableCellTitleArray count];
    return count + 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * showUserInfoCellIdentifier = @"showMeInfo";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加向右剪头
        cell.backgroundColor = [UIColor tableViewBackgroundColor];
        if ([indexPath indexAtPosition:1] == 0) {
            UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 120)];
            [bgImg setImage:[UIImage imageNamed:@"firstcellbg.png"]];
            [bgImg setContentMode:UIViewContentModeScaleToFill];
            [cell addSubview:bgImg];
            
            UIView *loginView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, 120)];
            
            UIImageView *logoImg = [[UIImageView alloc] initWithFrame:CGRectMake(50, (loginView.frame.size.height - 70)/2, 70, 70)];
            [logoImg setTag:101];
            [loginView addSubview:logoImg];
            
            
            UILabel *labelickName = [[UILabel alloc] initWithFrame:CGRectMake(logoImg.frame.origin.x + logoImg.frame.size.width + 20, logoImg.frame.origin.y + 40, 120, 20)];
            labelickName.font = LABEL_DEFAULT_TEXT_FONT;
            labelickName.textColor = LABEL_DEFAULT_TEXT_COLOR;
            [labelickName setTag:103];
            
            UILabel *labelAccount = [[UILabel alloc] initWithFrame:CGRectMake(labelickName.frame.origin.x, logoImg.frame.origin.y + 10, 120, 20)];
            [labelAccount setTag:102];
            labelAccount.font = LABEL_LARGE_TEXT_FONT;
            labelAccount.textColor = LABEL_DEFAULT_TEXT_COLOR;
            [loginView addSubview:labelAccount];
            [loginView addSubview:labelickName];

            UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake((loginView.frame.size.width - 160)/2 + 40, (loginView.frame.size.height - 20)/2, 120, 20)];
            loginLabel.textAlignment = NSTextAlignmentCenter;
            [loginLabel setTag:104];
            [loginView addSubview:loginLabel];
            [cell addSubview:loginView];
        } else {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 30, 30)];
            [cell addSubview:imgView];
            NSString *imgName;
            if ([indexPath indexAtPosition:1] == 1) {//订单
                imgName = @"myOrder.png";
            } else if ([indexPath indexAtPosition:1] == 2) {//卡包
                imgName = @"myKabao.png";
            } else if ([indexPath indexAtPosition:1] == 3) {//收藏
                imgName = @"myShouCang.png";
            }
            [imgView setImage:[UIImage imageNamed:imgName]];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.size.width + imgView.frame.origin.x + 5, 0, 90, 40)];
            [cell addSubview:label];
            label.font = LABEL_LARGE_TEXT_FONT;
            label.textColor = LABEL_DEFAULT_TEXT_COLOR;
            [label setTag:100];
            
            if ([indexPath indexAtPosition:1] == 2) {//卡包
                UIImageView *sign = [[UIImageView alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width, 5, 7.5, 7.5)];
                [cell addSubview:sign];
            }
        }
    }
    
    if ([indexPath indexAtPosition:1] == 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userId = [userDefaults objectForKey:@"userId"];
        NSString *account = [userDefaults objectForKey:@"account"];
        NSString *nickName = [userDefaults objectForKey:@"nickname"];
        NSString *userHeadImgUrl = [userDefaults objectForKey:@"headImgUrl"];
        UIImageView *logoImg = (UIImageView*) [cell viewWithTag:101];
        logoImg.layer.masksToBounds = YES;
        logoImg.layer.cornerRadius = logoImg.frame.size.width / 2;
        [logoImg setContentMode:UIViewContentModeScaleToFill];
        if (userId && userId.length > 0) {
            if (userHeadImgUrl) {
                [logoImg sd_setImageWithURL:[NSURL URLWithString:userHeadImgUrl] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
            } else {
                NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"headImage.png"];
                UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
                if (savedImage) {
                    [logoImg setImage:savedImage];
                } else {
                    [logoImg setImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];//如果用户没有设置头像，那就使用默认头像
                }
            }
            [cell viewWithTag:104].hidden = YES;
            UILabel *labelickName = (UILabel*)[cell viewWithTag:103];
            labelickName.hidden = NO;
            if (nickName && nickName.length > 0) {
                labelickName.text = nickName;
            } else {
                labelickName.text = @"未设置昵称";
            }
            UILabel *labelAccount = (UILabel*)[cell viewWithTag:102];
            labelAccount.hidden = NO;
            labelAccount.text = account;
        } else {
            [logoImg setImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];//未登录的图片
            [cell viewWithTag:102].hidden = YES;
            [cell viewWithTag:103].hidden = YES;
            UILabel *loginLabel = (UILabel*)[cell viewWithTag:104];
            loginLabel.hidden = NO;
            loginLabel.textAlignment = NSTextAlignmentCenter;
            loginLabel.text = @"去登录";
        }
    } else {
        UILabel *label = (UILabel*)[cell viewWithTag:100];
        label.text = [tableCellTitleArray objectAtIndex:[indexPath indexAtPosition:1] - 1];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

#pragma table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{//修改group之间的间距
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{//修改group之间的间距
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//点击后恢复原有背景状态
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    if (userId && userId.length > 0) {
        [self showSelectedContentView:indexPath];
    } else {
        self.selectedIndexPath = indexPath;
        [self showLoginView];
    }
    
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    if ([indexPath indexAtPosition:1] == 0) {
        return 120;
    }
    return CELL_HEIGHT;
}

#pragma LoginSuccess delegate
-(void)loginSuccess:(UIView*)view{
    //进入用户反馈界面
    [self closeLoginView:nil];
    if (self.selectedIndexPath) {
        if ([selectedIndexPath indexAtPosition:1] == 0) {
            [self.meTableView reloadData];
        } else {
            [self showSelectedContentView:selectedIndexPath];
        }
        self.selectedIndexPath = nil;
    }
}
@end
