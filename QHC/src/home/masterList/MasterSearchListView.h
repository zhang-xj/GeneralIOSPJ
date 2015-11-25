//
//  MasterSearchListView.h
//  QHC
//
//  Created by qhc2015 on 15/7/23.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "MyRefreshTableView.h"

@interface MasterSearchListView : UIView<MyRefreshTableViewDelegate> {
    MyRefreshTableView             *mRfTableView;
    
    HttpRequestManage       *httpRequest;
    
    NSString *sortType;
    NSString *salerStar;
    NSString *searchKey;
    UIView *classSelectView;
    
    BOOL refreshTable;
}

@property (nonatomic, retain)MyRefreshTableView *mRfTableView;
@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, copy)NSString *sortType;
@property (nonatomic, copy)NSString *salerStar;
@property (nonatomic, copy)NSString *searchKey;
@property (nonatomic, retain)UIView *classSelectView;

-(id)initWithFrame:(CGRect)frame andSearchKey:(NSString*)search_key;

@end
