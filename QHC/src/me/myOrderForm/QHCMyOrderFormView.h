//
//  QHCMyOrderFormView.h
//  QHC
//
//  Created by qhc2015 on 15/6/30.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRefreshTableView.h"
#import "HttpRequestManage.h"

@interface QHCMyOrderFormView : UIView<UIScrollViewDelegate, MyRefreshTableViewDelegate>{
    UIScrollView *pageScrollView;
    UISegmentedControl *segmentController;
    
    NSString *pageTitle;
    NSInteger orderType;
    
    MyRefreshTableView *refreshTableView_doing;
    MyRefreshTableView *refreshTableView_waitPay;
    MyRefreshTableView *refreshTableView_all;
    
    HttpRequestManage *httpRequest_doing;
    HttpRequestManage *httpRequest_waitPay;
    HttpRequestManage *httpRequest_all;
    
    NSMutableDictionary *selectedOrderListDic;
    
    UIView *footerView;//批量支付按钮视图
    
    BOOL refreshView_doing;
    BOOL refreshView_waitPay;
    BOOL refreshView_all;
    
    int intArray[3];
    int userSelectedTableViewIndex;
}
@property (nonatomic, retain)UIScrollView *pageScrollView;
@property (nonatomic, retain)UISegmentedControl *segmentController;
@property (nonatomic, copy)NSString* pageTitle;

@property (nonatomic, retain) MyRefreshTableView *refreshTableView_doing;
@property (nonatomic, retain) MyRefreshTableView *refreshTableView_waitPay;
@property (nonatomic, retain) MyRefreshTableView *refreshTableView_all;

@property (nonatomic, retain) HttpRequestManage *httpRequest_doing;
@property (nonatomic, retain) HttpRequestManage *httpRequest_waitPay;
@property (nonatomic, retain) HttpRequestManage *httpRequest_all;

@property (nonatomic, retain) NSMutableDictionary *selectedOrderListDic;

@property (nonatomic, retain)UIView *footerView;//批量支付按钮视图

-(id)initWithFrame:(CGRect)frame andTitle:(NSString*)title type:(NSInteger)type;

-(void)getContentTableViewInitData:(NSInteger)pageDataCount;
@end
