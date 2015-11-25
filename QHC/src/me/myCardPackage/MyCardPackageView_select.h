//
//  MyCardPackageView_select.h
//  QHC
//
//  Created by qhc2015 on 15/8/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRefreshTableView.h"
#import "HttpRequestManage.h"

@protocol MyCardPackageView_selectDelegate <NSObject>

@optional
-(void) selectedResult:(NSDictionary*)selectedCardDic;

@end

@interface MyCardPackageView_select : UIView<MyRefreshTableViewDelegate>{
    NSString *pageTitle;
    NSInteger orderType;
    
    MyRefreshTableView *refreshTableView;
    
    HttpRequestManage *httpRequest;
    
    NSInteger selectedIndex;
}

@property (nonatomic, assign) id<MyCardPackageView_selectDelegate> delegate;

@property (nonatomic, copy)NSString* pageTitle;

@property (nonatomic, retain) MyRefreshTableView *refreshTableView;

@property (nonatomic, retain) HttpRequestManage *httpRequest;
@end
