//
//  ConfirmOrderView.h
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "APPayOrder.h"
#import "AppDelegate.h"
#import "MyCardPackageViewController.h"

@interface ConfirmOrderView : UIView <UITableViewDelegate, UITableViewDataSource, APPPayOrderDelegate, ConfirmOrderViewPayResultDelegate, MyCardPackageViewControllerDelegate>{
    NSDictionary *orderFormDetailInfoDic;
    
    UITableView *myTableView;
    
    NSMutableArray *payWaySignArray;
    
    NSInteger selectedPayWay;
    
    NSDictionary *orderInfoDic;
    
    HttpRequestManage *httpRequest;
    
    UIButton *payBtn;
}

@property (nonatomic, retain)NSDictionary *orderFormDetailInfoDic;

@property (nonatomic, retain)UITableView *myTableView;

@property (nonatomic, retain)NSMutableArray *payWaySignArray;

@property (nonatomic, retain)NSDictionary *orderInfoDic;

@property (nonatomic, retain) HttpRequestManage *httpRequest;

@property (nonatomic, retain)UIButton *payBtn;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderInfoDic;
@end
