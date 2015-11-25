//
//  HomeProductView.h
//  QHC
//
//  Created by qhc2015 on 15/7/25.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "LoginView.h"

@interface HomeProductView : UIView<UITableViewDataSource, UITableViewDelegate, LoginDelegate> {
    UITableView *myTableView;
    UITableView *myTableView1;
    
    NSDictionary *aomaDetailDic;
    NSDictionary *haiDetailDic;
    
    HttpRequestManage *httpRequest;
    HttpRequestManage *httpRequest1;
}
@property (nonatomic, retain)UITableView *myTableView;
@property (nonatomic, retain)UITableView *myTableView1;
@property (nonatomic, retain) NSDictionary *aomaDetailDic;
@property (nonatomic, retain) NSDictionary *haiDetailDic;
@property (nonatomic, retain)    HttpRequestManage *httpRequest;
@property (nonatomic, retain)    HttpRequestManage *httpRequest1;

-(id)initWithFrame:(CGRect)frame andProperty:(NSDictionary*)property;
@end
