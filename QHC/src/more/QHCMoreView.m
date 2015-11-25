//
//  QHCMoreView.m
//  QHC
//
//  Created by qhc2015 on 15/6/5.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCMoreView.h"
#import "ServicePurviewController.h"
#import "UserFeedbackController.h"
#import "AboutWeViewController.h"
#import "MyAlerView.h"
#import "QHCStoreListViewController.h"

@implementation QHCMoreView

@synthesize tableCellTitleArray;
@synthesize changeAccountBtn;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentView];
    }
    return self;
}

//创建界面内容视图
-(void)createContentView {
    self.tableCellTitleArray = [[NSArray alloc] initWithObjects:@"服务范围", @"投诉／反馈", @"关于我们", nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:tableView];
}



-(void)changeAccount:(id)sender {
    [self.delegate showLoginView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableCellTitleArray.count + 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"aaaaa"];
    cell.backgroundColor = [UIColor whiteColor];
//    if ([indexPath indexAtPosition:1] == 0) {
//        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 210.5)];
//        [imgView setImage:[UIImage imageNamed:@"moreIcon.png"]];
//        [cell addSubview:imgView];
//        cell.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
//    } else
    if ([indexPath indexAtPosition:1] == 3) {
        self.changeAccountBtn = [[UIButton alloc] initWithFrame:CGRectMake((tableView.frame.size.width - 215) / 2, 15, 215, 30)];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userId = [userDefaults stringForKey:@"userId"];
        if (!userId || [userId length] <= 0) {//还没登陆
            [changeAccountBtn setTitle:@"马上登录" forState:UIControlStateNormal];
        } else {
            [changeAccountBtn setTitle:@"切换其他账号" forState:UIControlStateNormal];
        }

        changeAccountBtn.titleLabel.font = BUTTON_TEXT_FONT;
        [changeAccountBtn addTarget:self action:@selector(changeAccount:) forControlEvents:UIControlEventTouchUpInside];
        [changeAccountBtn setBackgroundImage:[UIImage imageNamed:@"logoutBtnBg.png"] forState:UIControlStateNormal];
        [cell addSubview:changeAccountBtn];
    } else {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 40, 40)];
        if ([indexPath indexAtPosition:1] == 0) {
            [imgView setImage:[UIImage imageNamed:@"serviceArea.png"]];
        } else if ([indexPath indexAtPosition:1] == 1) {
            [imgView setImage:[UIImage imageNamed:@"userFeedback.png"]];
        } else if ([indexPath indexAtPosition:1] == 2) {
            [imgView setImage:[UIImage imageNamed:@"aboutWe.png"]];
        }
        [cell addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 10, 22, 120, 16)];
        label.font = LABEL_LARGE_TEXT_FONT;
        label.textColor = LABEL_DEFAULT_TEXT_COLOR;
        label.text = [tableCellTitleArray objectAtIndex:[indexPath indexAtPosition:1]];
        [cell addSubview:label];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加向右剪头
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

        NSInteger index = [indexPath indexAtPosition:1];
        AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
        if (index == 1) {
            NSString *userId = [userDefaults stringForKey:@"userId"];
            if (!userId || [userId length] <= 0) {//还没登陆
                [self.delegate showLoginView];
            } else {//已经登陆
                UserFeedbackController *fbController = [[UserFeedbackController alloc] init];
                [appDelegate.myRootController pushViewController:fbController animated:YES];
            }

        } else if (index == 0) {
            
            QHCStoreListViewController *sllController = [[QHCStoreListViewController alloc] initWithProperty:nil isSelectedView:NO];
            AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
            [appDelegate.myRootController pushViewController:sllController animated:YES];
        } else if (index == 2) {
            AboutWeViewController *awController = [[AboutWeViewController alloc] init];
            [appDelegate.myRootController pushViewController:awController animated:YES];
        }
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
//    if ([indexPath indexAtPosition:1] == 0) {
//        return 225;
//    }
    return 60;
}



@end
