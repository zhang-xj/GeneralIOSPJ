//
//  StoreDetailView.h
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"

@interface StoreDetailView : UIView <UITableViewDataSource, UITableViewDelegate> {
    
    HttpRequestManage *httpRequest;
    
    UITableView *myTableView;
    NSDictionary *tableData;
    
    NSString *storeId;
    NSString *storeName;
    
    UIView *headView;
    
}

@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, retain)UITableView *myTableView;
@property (nonatomic, retain)NSDictionary *tableData;

@property (nonatomic, copy)NSString *storeId;
@property (nonatomic, copy)NSString *storeName;

@property (nonatomic, retain)    UIView *headView;

-(id)initWithFrame:(CGRect)frame andStoreName:(NSString*)name storeID:(NSString*)index;
@end
