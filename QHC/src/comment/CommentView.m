//
//  CommentView.m
//  QHC
//
//  Created by qhc2015 on 15/7/6.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "CommentView.h"
#import "LoadingView.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@implementation CommentView

@synthesize httpRequest1;
@synthesize httpRequest2;
@synthesize httpRequest3;
@synthesize httpRequest4;

@synthesize pageScrollView;
@synthesize allCommentList;
@synthesize goodCommentList;
@synthesize normolCommentList;
@synthesize badCommentList;

@synthesize objectId;
@synthesize objectType;

@synthesize topTabView;


-(id)initWithFrame:(CGRect)frame withProjectID:(NSString*)pjId type:(NSString*)obType{
    self = [super initWithFrame:frame];
    if (self) {
        [self createTabItem];
        [self createContentView];
        self.objectId = pjId;
        self.objectType = obType;
        
        [self changeTabItemStatus:0];
        [self getData:PAGE_DATA_COUNT];
    }
    return self;
}

-(void)createContentView{
    self.pageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 35.0, self.frame.size.width, self.frame.size.height - 35.0)];
    pageScrollView.pagingEnabled = YES;
    pageScrollView.delegate = self;
    
    self.allCommentList = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, pageScrollView.frame.size.height) rowHeight:-2];
    allCommentList.delegate = self;
    [allCommentList setPageDataCount:PAGE_DATA_COUNT];
    allCommentList.backgroundColor = [UIColor clearColor];
    [pageScrollView addSubview:allCommentList];

    self.goodCommentList = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0.0, self.frame.size.width, pageScrollView.frame.size.height) rowHeight:-2];
    goodCommentList.delegate = self;
    [goodCommentList setPageDataCount:PAGE_DATA_COUNT];
    goodCommentList.backgroundColor = [UIColor clearColor];
    [pageScrollView addSubview:goodCommentList];
    
    self.normolCommentList = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(self.frame.size.width*2, 0.0, self.frame.size.width, pageScrollView.frame.size.height) rowHeight:-2];
    normolCommentList.delegate = self;
    [normolCommentList setPageDataCount:PAGE_DATA_COUNT];
    normolCommentList.backgroundColor = [UIColor clearColor];
    [pageScrollView addSubview:normolCommentList];
    
    self.badCommentList = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(self.frame.size.width*3, 0.0, self.frame.size.width, pageScrollView.frame.size.height) rowHeight:-2];
    badCommentList.delegate = self;
    [badCommentList setPageDataCount:PAGE_DATA_COUNT];
    badCommentList.backgroundColor = [UIColor clearColor];
    [pageScrollView addSubview:badCommentList];
    
    [pageScrollView setContentSize:CGSizeMake(pageScrollView.frame.size.width*4, pageScrollView.frame.size.height)];
    [self addSubview:pageScrollView];
}

-(void)makeTabWithFrame:(CGRect)frame title:(NSString*)title itemTag:(NSInteger)itemTag bColor:(UIColor*)backColor backTag:(NSInteger)tag superView:(UIView*)sView{
    
    UIButton *tabBtn = [[UIButton alloc] initWithFrame:frame];
    [tabBtn setTitle:title forState:UIControlStateNormal];
    tabBtn.titleLabel.font = BUTTON_TEXT_FONT;
    [tabBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [tabBtn setTag:itemTag];
    [tabBtn addTarget:self action:@selector(tabItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [sView addSubview:tabBtn];
    
    UIView *bView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x + 8, frame.origin.y + frame.size.height - 2, frame.size.width - 16, 2)];
    bView.backgroundColor = backColor;
    [bView setTag:tag];
    [sView addSubview:bView];
}

//创建tab选项菜单
-(void)createTabItem {
    float v_h = 35.0;
    self.topTabView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, v_h)];
    [self addSubview:topTabView];
    
    NSInteger baseTag = 2000;
    
    [self makeTabWithFrame:CGRectMake(0, 0, self.frame.size.width/4, v_h) title:@"全部" itemTag:baseTag bColor:[UIColor titleBarBackgroundColor] backTag:baseTag*10 superView:topTabView];
    
    [self makeTabWithFrame:CGRectMake(self.frame.size.width/4, 0, self.frame.size.width/4, v_h) title:@"好评" itemTag:baseTag+1 bColor:[UIColor clearColor] backTag:baseTag*10+1 superView:topTabView];
    
    [self makeTabWithFrame:CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/4, v_h) title:@"中评" itemTag:baseTag+2 bColor:[UIColor clearColor] backTag:baseTag*10+2 superView:topTabView];
    
    [self makeTabWithFrame:CGRectMake(self.frame.size.width*3/4, 0, self.frame.size.width/4, v_h) title:@"差评" itemTag:baseTag+3 bColor:[UIColor clearColor] backTag:baseTag*10+3 superView:topTabView];
}

#pragma tabItem action
-(void)tabItemAction:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 2000:
                [pageScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                [self changeTabItemStatus:0];
                break;
            case 2001:
                [pageScrollView setContentOffset:CGPointMake(pageScrollView.frame.size.width, 0) animated:YES];
                [self changeTabItemStatus:1];
                break;
            case 2002:
                [pageScrollView setContentOffset:CGPointMake(pageScrollView.frame.size.width*2, 0) animated:YES];
                [self changeTabItemStatus:2];
                break;
            case 2003:
                [pageScrollView setContentOffset:CGPointMake(pageScrollView.frame.size.width*2, 0) animated:YES];
                [self changeTabItemStatus:3];
                break;
        }
    }
}

-(void) changeTabItemStatus:(NSInteger)selected{
    NSInteger baseTag = 2000;
    UIButton *item = (UIButton*)[topTabView viewWithTag:baseTag];
    [item setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [topTabView viewWithTag:baseTag*10].backgroundColor = [UIColor clearColor];
    
    item = (UIButton*)[topTabView viewWithTag:baseTag+1];
    [item setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [topTabView viewWithTag:baseTag*10+1].backgroundColor = [UIColor clearColor];
    
    item = (UIButton*)[topTabView viewWithTag:baseTag+2];
    [item setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [topTabView viewWithTag:baseTag*10+2].backgroundColor = [UIColor clearColor];
    
    item = (UIButton*)[topTabView viewWithTag:baseTag+3];
    [item setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [topTabView viewWithTag:baseTag*10+3].backgroundColor = [UIColor clearColor];
    
    [self setTabItemSelected:selected];
}

-(void)setTabItemSelected:(NSInteger)selectIndex{
    NSInteger baseTag = 2000;
    UIButton *item = (UIButton*)[topTabView viewWithTag:(baseTag + selectIndex)];
    [item setTitleColor:[UIColor titleBarBackgroundColor] forState:UIControlStateNormal];
    [topTabView viewWithTag:(baseTag*10 + selectIndex)].backgroundColor = [UIColor titleBarBackgroundColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)getData:(NSInteger)pageDataCount {
    [[LoadingView sharedLoadingView] show];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", pageDataCount];
    [self getAllCommentData:@"1" count:pageDataCountStr];
    [self getGoodCommentData:@"1" count:pageDataCountStr];
    [self getNormolCommentData:@"1" count:pageDataCountStr];
    [self getBadCommentData:@"1" count:pageDataCountStr];
}

-(NSMutableDictionary*)getRequestParams:(NSString*)lv pageId:(NSString*)page count:(NSString*)count {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:objectId forKey:@"projectid"];
    [param setObject:objectType forKey:@"type"];
    [param setObject:lv forKey:@"lv"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    return param;
}

-(void)getAllCommentData:(NSString*)page count:(NSString*)count {

    //创建异步请求
    NSString *urlStr = @"Comment/List.aspx";
    self.httpRequest1 = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [self getRequestParams:@"0" pageId:page count:count];
    
    [httpRequest1 setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest1 setRequestFinishCallBack:@selector(allCommentRequestFinish:)];
    //设置请求失败的回调方法
    [httpRequest1 setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest1 sendHttpRequestByPost:urlStr params:param];
}

-(void)getGoodCommentData:(NSString*)page count:(NSString*)count {
    //创建异步请求
    NSString *urlStr = @"Comment/List.aspx";
    self.httpRequest2 = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [self getRequestParams:@"1" pageId:page count:count];
    
    [httpRequest2 setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest2 setRequestFinishCallBack:@selector(goodCommentRequestFinish:)];
    //设置请求失败的回调方法
    [httpRequest2 setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest2 sendHttpRequestByPost:urlStr params:param];
}

-(void)getNormolCommentData:(NSString*)page count:(NSString*)count {
    //创建异步请求
    NSString *urlStr = @"Comment/List.aspx";
    self.httpRequest3 = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [self getRequestParams:@"2" pageId:page count:count];
    
    [httpRequest3 setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest3 setRequestFinishCallBack:@selector(normolCommentRequestFinish:)];
    //设置请求失败的回调方法
    [httpRequest3 setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest3 sendHttpRequestByPost:urlStr params:param];
}

-(void)getBadCommentData:(NSString*)page count:(NSString*)count {
    //创建异步请求
    NSString *urlStr = @"Comment/List.aspx";
    self.httpRequest4 = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [self getRequestParams:@"3" pageId:page count:count];
    
    [httpRequest4 setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest4 setRequestFinishCallBack:@selector(badCommentRequestFinish:)];
    //设置请求失败的回调方法
    [httpRequest4 setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest4 sendHttpRequestByPost:urlStr params:param];
}

#pragma mark ASIHTTPRequestDelegate
//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}


-(void) allCommentRequestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        NSArray *commentData = [responseInfo objectForKey:@"commentslist"];
        [self.allCommentList appendTableData:commentData];
        [self.allCommentList reload];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    [[LoadingView sharedLoadingView] hidden];
}

-(void) goodCommentRequestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        NSArray *commentData = [responseInfo objectForKey:@"commentslist"];
        [self.goodCommentList appendTableData:commentData];
        [self.goodCommentList reload];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

-(void) normolCommentRequestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        NSArray *commentData = [responseInfo objectForKey:@"commentslist"];
        [self.normolCommentList appendTableData:commentData];
        [self.normolCommentList reload];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

-(void) badCommentRequestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        NSArray *commentData = [responseInfo objectForKey:@"commentslist"];
        [self.badCommentList appendTableData:commentData];
        [self.badCommentList reload];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}


#pragma table delegate

-(float)getTableCellHeight:(NSObject*)cellData{
    if (cellData && [cellData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)cellData;
        UIFont *font = [UIFont systemFontOfSize:15.0];
        NSString *content = (NSString*)[dic objectForKey:@"content"];
        CGSize lSize = [AppDelegate getStringInLabelSize:content andFont:font andLabelWidth:self.frame.size.width - 30];
        return 60.0 + lSize.height;
    }
    return 44;
}

- (void) refreshData:(UITableView*)tableView oldDataCount:(NSInteger)oldDataCount onePageDataCount:(NSInteger)onePageDataCount{
    NSString *pageIndexStr = [NSString stringWithFormat:@"%ld", (oldDataCount / onePageDataCount + 1)];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", onePageDataCount];
    if (tableView == self.allCommentList.refreshTableView) {//全部
        [self getAllCommentData:pageIndexStr count:pageDataCountStr];
    } else if (tableView == self.allCommentList.refreshTableView) {//好评
        [self getGoodCommentData:pageIndexStr count:pageDataCountStr];
    } else if (tableView == self.allCommentList.refreshTableView) {//中评
        [self getNormolCommentData:pageIndexStr count:pageDataCountStr];
    } else if (tableView == self.allCommentList.refreshTableView) {//差评
        [self getBadCommentData:pageIndexStr count:pageDataCountStr];
    }
    
}
- (void) tableView:(UITableView *)tableView didSelectRowData:(NSObject *)selectRowData andIndexPath:(NSIndexPath *)indexPath{
    //    NSDictionary *selectCellDataDic = (NSDictionary*)selectRowData;
    NSLog(@"selected");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellsData:(NSObject*)cellData cellForRowAtIndex:(NSInteger)index{
    static NSString * showUserInfoCellIdentifier = @"showMoreInfo";

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        UIImageView *userImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 5.0, 38.0, 38.0)];
        [userImgView setTag:10];
        [cell addSubview:userImgView];
        
        UILabel *labelUser = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 100, 18)];
        UIFont *font = [UIFont systemFontOfSize:16.0];
        labelUser.font = font;
        [labelUser setTag:11];
        [cell addSubview:labelUser];
        
        UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(170, 15, self.frame.size.width - 180, 18)];
        [labelTime setTag:12];
        font = [UIFont systemFontOfSize:12.0];
        labelTime.font = font;
        [cell addSubview:labelTime];
        
        UILabel *labeltext = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, self.frame.size.width - 30, 18)];
        [labeltext setTag:13];
        font = [UIFont systemFontOfSize:15.0];
        labeltext.font = font;
        [cell addSubview:labeltext];
    }
    
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    
    if (cellData && [cellData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)cellData;
        UIImageView *userImgView = (UIImageView*)[cell viewWithTag:10];
        [userImgView sd_setImageWithURL:[dic objectForKey:@"userimg"] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
        UILabel *labelUser = (UILabel*)[cell viewWithTag:11];
        if ([dic objectForKey:@"userNick"]) {
            [labelUser setText:[dic objectForKey:@"userNick"]];
        } else {
            [labelUser setText:[dic objectForKey:@"userid"]];
        }
        UILabel *labelTime = (UILabel*)[cell viewWithTag:12];
        [labelTime setText:[dic objectForKey:@"dt"]];

        UILabel *labelText = (UILabel*)[cell viewWithTag:13];
        labelText.numberOfLines = 0;
        NSString *content = (NSString*)[dic objectForKey:@"content"];
        CGSize lSize = [AppDelegate getStringInLabelSize:content andFont:labelText.font andLabelWidth:labelText.frame.size.width];
        labelText.frame = CGRectMake(labelText.frame.origin.x, labelText.frame.origin.y, labelText.frame.size.width, lSize.height);
        [labelText setText:content];
    }
    
    
    return cell;
}


#pragma UIScrollViewDelegate
// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //    NSLog([NSString stringWithFormat:@"scrollViewDidEndDecelerating scrollView.x = %f", scrollView.contentOffset.x]);
    NSInteger selectedIndex = (NSInteger)scrollView.contentOffset.x / 320;
    [self changeTabItemStatus:selectedIndex];
}
@end
