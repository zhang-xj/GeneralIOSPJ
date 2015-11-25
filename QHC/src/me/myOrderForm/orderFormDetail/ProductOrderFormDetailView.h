//
//  ProductOrderFormDetailView.h
//  QHC
//
//  Created by qhc2015 on 15/8/6.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPayOrder.h"
#import "HttpRequestManage.h"
#import "MyCardPackageViewController.h"
#import "AppDelegate.h"

@interface ProductOrderFormDetailView : UIView <UITableViewDelegate, UITableViewDataSource, APPPayOrderDelegate, UIAlertViewDelegate, MyCardPackageViewControllerDelegate, ConfirmOrderViewPayResultDelegate>{
    NSString *orderID;
    NSInteger orderStatus;
    
    UITableView *myTableView;
    
    NSMutableArray *payWaySignArray;
    
    NSInteger selectedPayWay;
    
    NSDictionary *orderInfoDic;
    
    HttpRequestManage *httpRequest;
    
    NSArray *bespeakDTArray;
    
    UIButton *payBtn;
    
    UIButton *cannelBtn;
}
@property (nonatomic, copy) NSString *orderID;

@property (nonatomic, retain)UITableView *myTableView;

@property (nonatomic, retain)NSMutableArray *payWaySignArray;

@property (nonatomic, retain)NSDictionary *orderInfoDic;

@property (nonatomic, retain) HttpRequestManage *httpRequest;

@property (nonatomic, retain)    NSArray *bespeakDTArray;

@property (nonatomic, retain) UIButton *payBtn;

@property (nonatomic, retain) UIButton *cannelBtn;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderInfoDic;
@end
