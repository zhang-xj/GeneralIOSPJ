//
//  MasterDetail.m
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MasterDetail.h"
#import "UIImageView+WebCache.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"
#import "QHCProjectListViewController.h"
#import "QHCProjectDetailViewController.h"
#import "AppDelegate.h"

@implementation MasterDetail

@synthesize masterInfoDic;

@synthesize myTableView;

@synthesize masterDetailInfoDic;

@synthesize httpRequest;

-(id)initWithFrame:(CGRect)frame andData:(NSDictionary*)masterDic {
    self = [super initWithFrame:frame];
    if (self) {
        self.masterInfoDic = masterDic;
        isShow = YES;
        
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height + 21) style:UITableViewStyleGrouped];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        self.myTableView.backgroundColor = [UIColor clearColor];
        [self addSubview:myTableView];
     
        [self getMasterDetailData];
    }
    return self;
}

-(void)getMasterDetailData {
    //创建异步请求
    NSString *urlStr = @"Saler/Details.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[masterInfoDic objectForKey:@"salerid"] forKey:@"salerid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}

#pragma mark ASIHTTPRequestDelegate 异步请求代理方法--->请求代理方法
-(void) requestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        self.masterDetailInfoDic = responseInfo;
        [self.myTableView reloadData];
        [self createProjectListViewWithData:[self.masterDetailInfoDic objectForKey:@"projectlist"]];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
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

}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    NSString *text = @"";
    if ([indexPath indexAtPosition:1] == 0) {
        return 86;
    } else if ([indexPath indexAtPosition:1] == 1) {
        text = [self.masterDetailInfoDic objectForKey:@"content"];
    } else if ([indexPath indexAtPosition:1] == 2) {
        text = [self.masterDetailInfoDic objectForKey:@"projectname"];
    } else if ([indexPath indexAtPosition:1] == 3) {
        text = [self.masterDetailInfoDic objectForKey:@"declaration"];
    }
    if (isShow) {
        if(text && (id)text != [NSNull null]) {
            CGSize size = [AppDelegate getStringInLabelSize:text andFont:[UIFont systemFontOfSize:13] andLabelWidth:tableView.frame.size.width - 58];
            return size.height + 35;
        }
    } else {
        return 0;
    }
    return 40;
}

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * showUserInfoCellIdentifier = [NSString stringWithFormat:@"masterDetailCell%ld%lu", (long)indexPath.section, (unsigned long)[indexPath indexAtPosition:1]] ;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    
    NSInteger subViewTag = (indexPath.section + 3) * 100 + [indexPath indexAtPosition:1];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        float cellHeight = 86;
        float leftPading = 15;
            if ([indexPath indexAtPosition:1] == 0) {
                //照片
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPading, 13, 60, 60)];
                [imgView setTag:subViewTag];
                [cell addSubview:imgView];
                //名字
                UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(leftPading + imgView.frame.size.width + 10, imgView.frame.origin.y, tableView.frame.size.width/2, 18)];
                [label_name setTag:subViewTag+1];
                label_name.font = [UIFont systemFontOfSize:16];
                [cell addSubview:label_name];
                //职称
                UILabel *label_gradeName = [[UILabel alloc] initWithFrame:CGRectMake(label_name.frame.origin.x, label_name.frame.origin.y + label_name.frame.size.height + 2, 90, 17)];
                [label_gradeName setTag:subViewTag+5];
                label_gradeName.font = LABEL_DEFAULT_TEXT_FONT;
                label_gradeName.textColor = LABEL_DEFAULT_TEXT_COLOR;
                [cell addSubview:label_gradeName];
                //星星
                UIImage *star = [UIImage imageNamed:@"start_master.png"];
                for (int i = 0; i < 5; i++) {
                    UIImageView *starsImg = [[UIImageView alloc] initWithFrame:CGRectMake(label_gradeName.frame.origin.x + label_gradeName.frame.size.width + i*25, label_gradeName.frame.origin.y, 20, 20)];
                    [starsImg setImage:star];
                    starsImg.hidden = YES;
                    [starsImg setTag:(subViewTag+i+6)];
                    [cell addSubview:starsImg];
                }
                //
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label_name.frame.origin.x, cellHeight - 32, tableView.frame.size.width - label_name.frame.origin.x - 35, 18)];
                [cell addSubview:view];
                
                UIImageView *signImg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 4, 13.5, 13.5)];
                [signImg setImage:[UIImage imageNamed:@"serviceNum.png"]];
                [view addSubview:signImg];
                
                UIFont *font = [UIFont systemFontOfSize:12];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(signImg.frame.origin.x + signImg.frame.size.width + 3, 1.0, view.frame.size.width / 2 - (signImg.frame.origin.x + signImg.frame.size.width + 3), 20)];
                [label setTag:subViewTag+3];
                label.font = font;
                [view addSubview:label];
                
                signImg = [[UIImageView alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width, 4.0, 13.5, 13.5)];
                [signImg setImage:[UIImage imageNamed:@"evaluateSign.png"]];
                [view addSubview:signImg];
                
                label = [[UILabel alloc] initWithFrame:CGRectMake(signImg.frame.origin.x + signImg.frame.size.width + 3, 1.0, view.frame.size.width / 2, 20)];
                [label setTag:subViewTag+4];
                label.font = font;
                [view addSubview:label];
        } else {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPading, 8, 15, 15)];
            [cell addSubview:imgView];
            if ([indexPath indexAtPosition:1] == 1) {
                [imgView setImage:[UIImage imageNamed:@"personal.png"]];
            } else if ([indexPath indexAtPosition:1] == 2) {
                [imgView setImage:[UIImage imageNamed:@"goodAt.png"]];
            } else if ([indexPath indexAtPosition:1] == 3) {
                [imgView setImage:[UIImage imageNamed:@"myText.png"]];
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 3, imgView.frame.origin.y, 200, 15)];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = [UIColor textColor_red1];
            [label setTag:subViewTag];
            [cell addSubview:label];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y + label.frame.size.height, tableView.frame.size.width - label.frame.origin.x - 25, 20)];
            label1.font = [UIFont systemFontOfSize:13];
            [label1 setTag:subViewTag+1];
            label1.numberOfLines = 0;
            [cell addSubview:label1];
        }
    }
    
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    cell.userInteractionEnabled = NO;
    
    if ([indexPath indexAtPosition:1] == 0) {
        //照片
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:subViewTag];
        [imgView sd_setImageWithURL:[NSURL URLWithString:[self.masterDetailInfoDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
        //名字
        UILabel *label_name = (UILabel*)[cell viewWithTag:subViewTag+1];
        label_name.text = [self.masterDetailInfoDic objectForKey:@"name"];
        //星星
        NSInteger starsCount = [((NSString*)[self.masterDetailInfoDic objectForKey:@"salerstar"]) integerValue];
        //职称
        UILabel *label_gradeName = (UILabel*)[cell viewWithTag:subViewTag+5];
        if (starsCount == 1) {
            label_gradeName.text = @"高级养生顾问";
        } else if (starsCount == 2) {
            label_gradeName.text = @"资深养生顾问";
        } else if (starsCount == 3) {
            label_gradeName.text = @"星级养生顾问";
        }
        for (int i = 0; i < starsCount; i++) {
            UIImageView *starsImg = (UIImageView*)[cell viewWithTag:(subViewTag+i+6)];
            starsImg.hidden = NO;
        }
        //
        UILabel *label = (UILabel*)[cell viewWithTag:subViewTag+3];
        NSString *textStr = [NSString stringWithFormat:@"接单 %@ 次", [masterDetailInfoDic objectForKey:@"ordercount"]];
        label.text = textStr;
        
        label = (UILabel*)[cell viewWithTag:subViewTag+4];
        textStr = [NSString stringWithFormat:@"顾客评价 %@ 次", [masterDetailInfoDic objectForKey:@"commentcount"]];
        label.text = textStr;
    } else {
        UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
        NSString *text = @"";
        if ([indexPath indexAtPosition:1] == 1) {
            label.text = @"个人介绍";
            text = [self.masterDetailInfoDic objectForKey:@"content"];
        } else if ([indexPath indexAtPosition:1] == 2) {
            label.text = @"擅长项目";
            text = [self.masterDetailInfoDic objectForKey:@"projectname"];
        } else if ([indexPath indexAtPosition:1] == 3) {
            label.text = @"美丽宣言";
            text = [self.masterDetailInfoDic objectForKey:@"declaration"];
        }
        
        UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
        if(text && (id)text != [NSNull null]) {
            CGSize size = [AppDelegate getStringInLabelSize:text andFont:label1.font andLabelWidth:label1.frame.size.width];
            label1.frame = CGRectMake(label1.frame.origin.x, label1.frame.origin.y, label1.frame.size.width, size.height);
            label1.text = text;
        }
    }
    
    return cell;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)createProjectListViewWithData:(NSArray*)proListData {
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.myTableView.frame.size.width, 80)];
    tableFooterView.backgroundColor = [UIColor viewBackgroundColor];
    UIButton *hide_show_btn = [[UIButton alloc] initWithFrame:CGRectMake(tableFooterView.frame.size.width *3/8 , -2.0, tableFooterView.frame.size.width/4, 20)];
    [hide_show_btn setBackgroundImage:[UIImage imageNamed:@"buttonHide.png"] forState:UIControlStateNormal];
//    [hide_show_btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [hide_show_btn setTitle:@"点击收起" forState:UIControlStateNormal];
    [hide_show_btn addTarget:self action:@selector(hideShowInfo:) forControlEvents:UIControlEventTouchUpInside];
    [hide_show_btn setTitleColor:[UIColor textColor_red1] forState:UIControlStateNormal];
    hide_show_btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [tableFooterView addSubview:hide_show_btn];
    
    
    UIView *plView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 15, tableFooterView.frame.size.width, 20)];
    NSInteger dataCount = [proListData count];
    float item_w = (self.frame.size.width - 45)/2;
    float item_h = item_w + 60.0;
    float pading = 15.0;
    for (NSInteger i = 0; i < dataCount; i++) {
        NSDictionary *dataDic = [proListData objectAtIndex:i];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i%2*item_w + pading*(i%2+1), i/2*(item_h + pading) + pading, item_w, item_h)];
        view.layer.cornerRadius = 4.0;
        view.backgroundColor = [UIColor tableViewBackgroundColor];
        view.clipsToBounds = YES;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, item_w, item_w)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:[dataDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
        [imgView setTag:(100+i)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProjectDetail:)];
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:tapGesture];
        [view addSubview:imgView];
        
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(5.0, item_w+5, item_w-10.0, 18.0)];
        [labelName setText:[dataDic objectForKey:@"name"]];
        labelName.font = [UIFont systemFontOfSize:15.0];
        [view addSubview:labelName];
        
        UILabel *labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(5.0, item_w + 25.0, item_w-10.0, 18.0)];
        [labelPrice setText: [NSString stringWithFormat:@"¥ %.2lf", ((NSString*)[dataDic objectForKey:@"price"]).floatValue]];
        labelPrice.font = [UIFont systemFontOfSize:15.0];
        labelPrice.textColor = [UIColor priceTextColor];
        [view addSubview:labelPrice];
        
        UILabel *labelSales = [[UILabel alloc] initWithFrame:CGRectMake(5.0, item_w + 30.0, item_w-10.0, 18.0)];
        [labelSales setText: [NSString stringWithFormat:@"%@人已购买", [dataDic objectForKey:@"sales"] ]];
        labelSales.font = [UIFont systemFontOfSize:10.0];
        labelSales.textColor = [UIColor grayColor];
        labelSales.textAlignment = NSTextAlignmentRight;
        [view addSubview:labelSales];
        
        [plView addSubview:view];
    }
    
    NSInteger rowCount = dataCount/2 + dataCount%2;
    CGRect rect = CGRectMake(plView.frame.origin.x, plView.frame.origin.y, plView.frame.size.width, rowCount*(item_h + pading));
    plView.frame = rect;
    
    [tableFooterView addSubview:plView];
    
    UIButton *showAllPro = [[UIButton alloc] initWithFrame:CGRectMake(20.0, plView.frame.origin.y + plView.frame.size.height + 10, tableFooterView.frame.size.width - 40, 30)];
    showAllPro.layer.cornerRadius = 4;
    showAllPro.backgroundColor = [UIColor titleBarBackgroundColor];
    showAllPro.titleLabel.font = BUTTON_TEXT_FONT;
//    [showAllPro setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showAllPro setTitle:@"查看全部产品" forState:UIControlStateNormal];
    
    [showAllPro addTarget:self action:@selector(showAllProject:) forControlEvents:UIControlEventTouchUpInside];
    [tableFooterView addSubview:showAllPro];
    
    tableFooterView.frame = CGRectMake(tableFooterView.frame.origin.x, tableFooterView.frame.origin.y, tableFooterView.frame.size.width, showAllPro.frame.origin.y + showAllPro.frame.size.height + 10);
    
    self.myTableView.tableFooterView = tableFooterView;
}

-(void)hideShowInfo:(id)sender {
    UIButton *btn = (UIButton*)sender;
    isShow = !isShow;
    if (isShow) {
        [btn setTitle:@"点击收起" forState:UIControlStateNormal];
    } else {
        [btn setTitle:@"点击展开" forState:UIControlStateNormal];
    }
    [self.myTableView reloadData];
}

//进入所有项目列表页面
-(void)showAllProject:(id)sender {
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"所有项目", @"-1", nil] forKeys:[NSArray arrayWithObjects:@"title", @"type", nil]];
    QHCProjectListViewController *faceCareProListViewControl = [[QHCProjectListViewController alloc] initWithData:params];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:faceCareProListViewControl animated:YES];
}

//进入项目详情
-(void)showProjectDetail:(id)sender {
    //这里进入项目详情页
    UIView * view = [((UITapGestureRecognizer*)sender) view];//这个就是被单击的视图
    NSInteger viewTag = view.tag;
    NSInteger index = viewTag - 100;
    
    NSArray *projectArray = [self.masterDetailInfoDic objectForKey:@"projectlist"];
    NSDictionary *proDic = [projectArray objectAtIndex:index];
    
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] init];
    [paramsDic setObject:[proDic objectForKey:@"name"] forKey:@"title"];
    [paramsDic setObject:[proDic objectForKey:@"projectid"] forKey:@"projectid"];
    NSString *address = [self.masterDetailInfoDic objectForKey:@"shopaddress"];
    if (!address) {
        address = @"-";
    }
    NSDictionary *storeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self.masterDetailInfoDic objectForKey:@"shopname"], [self.masterDetailInfoDic objectForKey:@"shopid"], address, nil] forKeys:[NSArray arrayWithObjects:@"name", @"shopid", @"address", nil]];
    [paramsDic setObject:storeDic forKey:@"store"];
    NSDictionary *masterDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self.masterDetailInfoDic objectForKey:@"name"], [self.masterDetailInfoDic objectForKey:@"salerid"], nil] forKeys:[NSArray arrayWithObjects:@"name", @"salerid", nil]];
    [paramsDic setObject:masterDic forKey:@"master"];
    
    QHCProjectDetailViewController *bdvController = [[QHCProjectDetailViewController alloc] initWithData:paramsDic];
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    [appDelegate.myRootController pushViewController:bdvController animated:YES];
}
@end
