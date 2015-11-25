//
//  MyCardPackageView.h
//  QHC
//
//  Created by qhc2015 on 15/7/27.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRefreshTableView.h"
#import "HttpRequestManage.h"

@interface MyCardPackageView : UIView<UIScrollViewDelegate, MyRefreshTableViewDelegate>{
    UIScrollView *pageScrollView;
    UISegmentedControl *segmentController;
    
    NSString *pageTitle;
    NSInteger orderType;
    
    MyRefreshTableView *refreshTableView;
    UIScrollView *integralMallView;
    
    HttpRequestManage *httpRequest;
    HttpRequestManage *httpRequest1;
}
@property (nonatomic, retain)UIScrollView *pageScrollView;
@property (nonatomic, retain)UISegmentedControl *segmentController;
@property (nonatomic, copy)NSString* pageTitle;

@property (nonatomic, retain) MyRefreshTableView *refreshTableView;
@property (nonatomic, retain) UIScrollView *integralMallView;

@property (nonatomic, retain) HttpRequestManage *httpRequest;
@property (nonatomic, retain) HttpRequestManage *httpRequest1;



@end
