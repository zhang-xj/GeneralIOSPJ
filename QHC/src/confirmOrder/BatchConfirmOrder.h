//
//  BatchConfirmOrder.h
//  QHC
//
//  Created by qhc2015 on 15/8/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "APPayOrder.h"
#import "AppDelegate.h"
#import "MyCardPackageViewController.h"

@interface BatchConfirmOrder : UIView<UITableViewDelegate, UITableViewDataSource, APPPayOrderDelegate, ConfirmOrderViewPayResultDelegate, MyCardPackageViewControllerDelegate>{
    NSDictionary *orderFormDetailInfoDic;
    
    UITableView *myTableView;
    
    NSMutableArray *payWaySignArray;
    
    NSInteger selectedPayWay;
    
    HttpRequestManage *httpRequest;
    
    UIButton *payBtn;
    
    NSString *listKey;
    
    BOOL isBatchBuy;
}

@property (nonatomic, retain)NSDictionary *orderFormDetailInfoDic;

@property (nonatomic, retain)UITableView *myTableView;

@property (nonatomic, retain)NSMutableArray *payWaySignArray;

@property (nonatomic, retain) HttpRequestManage *httpRequest;

@property (nonatomic, retain)UIButton *payBtn;

@property (nonatomic, copy)NSString *listKey;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderInfoDic;

@end
