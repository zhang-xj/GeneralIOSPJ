//
//  CommentView.h
//  QHC
//
//  Created by qhc2015 on 15/7/6.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRefreshTableView.h"
#import "HttpRequestManage.h"

@interface CommentView : UIView <MyRefreshTableViewDelegate, UIScrollViewDelegate> {
    UIScrollView *pageScrollView;
    
    MyRefreshTableView *allCommentList;
    MyRefreshTableView *goodCommentList;
    MyRefreshTableView *normolCommentList;
    MyRefreshTableView *badCommentList;
    
    HttpRequestManage *httpRequest1;
    HttpRequestManage *httpRequest2;
    HttpRequestManage *httpRequest3;
    HttpRequestManage *httpRequest4;
    
    
    UIView *topTabView;
    
    NSString *objectType;
    NSString *objectId;
}
@property (nonatomic, retain)UIScrollView *pageScrollView;

@property (nonatomic,retain) MyRefreshTableView *allCommentList;
@property (nonatomic,retain) MyRefreshTableView *goodCommentList;
@property (nonatomic,retain) MyRefreshTableView *normolCommentList;
@property (nonatomic,retain) MyRefreshTableView *badCommentList;

@property (nonatomic, retain)HttpRequestManage *httpRequest1;
@property (nonatomic, retain)HttpRequestManage *httpRequest2;
@property (nonatomic, retain)HttpRequestManage *httpRequest3;
@property (nonatomic, retain)HttpRequestManage *httpRequest4;

@property (nonatomic, retain)UIView *topTabView;

@property (nonatomic, copy)NSString *objectId;
@property (nonatomic, copy)NSString *objectType;

-(id)initWithFrame:(CGRect)frame withProjectID:(NSString*)pjId type:(NSString*)obType;
@end
