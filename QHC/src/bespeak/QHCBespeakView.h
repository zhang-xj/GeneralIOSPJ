//
//  QHCBespeakView.h
//  QHC
//
//  Created by qhc2015 on 15/6/5.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRefreshTableView.h"
#import "HttpRequestManage.h"

@interface QHCBespeakView : UIView<MyRefreshTableViewDelegate, UIScrollViewDelegate>{
    UIScrollView        *scrollView;
    
    UIView              *contentView;
    
    HttpRequestManage       *httpRequest1;
    HttpRequestManage       *httpRequest2;
    HttpRequestManage       *httpRequest3;
    
    UIButton                *tabItem1;
    UIButton                *tabItem2;
    UIButton                *tabItem3;
    
    MyRefreshTableView         *tableWaitToCarryOn;
    MyRefreshTableView         *tableWaitToEvaluation;
    MyRefreshTableView         *tableAllBespeakOrder;
    
    BOOL         refreshTableWaitToCarryOn;
    BOOL         refreshTableWaitToEvaluation;
    BOOL         refreshTableAllBespeakOrder;
    
    int  intArray[3];
    int userSelectedTableViewIndex;
}
@property (nonatomic, retain)UIScrollView *scrollView;

@property (nonatomic, retain)UIView *contentView;

@property (nonatomic, retain)HttpRequestManage  *httpRequest1;
@property (nonatomic, retain)HttpRequestManage  *httpRequest2;
@property (nonatomic, retain)HttpRequestManage  *httpRequest3;

@property (nonatomic, retain)UIButton                *tabItem1;
@property (nonatomic, retain)UIButton                *tabItem2;
@property (nonatomic, retain)UIButton                *tabItem3;

@property (nonatomic, retain)MyRefreshTableView *tableWaitToCarryOn;
@property (nonatomic, retain)MyRefreshTableView *tableWaitToEvaluation;
@property (nonatomic, retain)MyRefreshTableView *tableAllBespeakOrder;

-(void)getContentTableViewInitData:(NSInteger)pageDataCount;

@end
