//
//  MasterDetail.h
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"

@interface MasterDetail : UIView <UITableViewDataSource, UITableViewDelegate> {
    NSDictionary *masterInfoDic;
    
    UITableView *myTableView;
    
    NSDictionary *masterDetailInfoDic;
    
    HttpRequestManage *httpRequest;
    
    BOOL        isShow;
}

@property (nonatomic, retain)NSDictionary *masterInfoDic;

@property (nonatomic, retain)UITableView *myTableView;

@property (nonatomic, retain)NSDictionary *masterDetailInfoDic;

@property (nonatomic, retain)HttpRequestManage *httpRequest;

-(id)initWithFrame:(CGRect)frame andData:(NSDictionary*)masterDic;
@end
