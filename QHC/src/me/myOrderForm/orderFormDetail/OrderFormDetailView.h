//
//  OrderFormView.h
//  QHC
//
//  Created by qhc2015 on 15/7/14.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPayOrder.h"
#import "HttpRequestManage.h"
#import "QHCStoreListViewController.h"
#import "MasterListViewController.h"
#import "BespeakTimeSelectView.h"
#import "MyCardPackageViewController.h"
#import "AppDelegate.h"


@interface OrderFormDetailView : UIView <UITableViewDelegate, UITableViewDataSource, APPPayOrderDelegate, QHCSelectedStoreDelegate, MasterListViewDelegate, BespeakTimeSelectViewDelegate, UIAlertViewDelegate, MyCardPackageViewControllerDelegate, ConfirmOrderViewPayResultDelegate>{
    NSString *orderID;
    NSInteger orderStatus;
    
    UITableView *myTableView;
    
    NSMutableArray *payWaySignArray;
    
    NSInteger selectedPayWay;
    
    NSDictionary *orderInfoDic;
    
    HttpRequestManage *httpRequest;
    
    NSMutableDictionary *bespeakInfoMutdic;
    
    NSArray *bespeakDTArray;
    
    UIButton *payBtn;
    
    UIButton *cannelBtn;
    
    UIButton *besBtn;
    
    NSInteger thisTimeAddBesOrderCount;//本次新增预约单数目
}
@property (nonatomic, copy) NSString *orderID;

@property (nonatomic, retain)UITableView *myTableView;

@property (nonatomic, retain)NSMutableArray *payWaySignArray;

@property (nonatomic, retain)NSDictionary *orderInfoDic;

@property (nonatomic, retain) HttpRequestManage *httpRequest;

@property (nonatomic, retain)NSMutableDictionary *bespeakInfoMutdic;

@property (nonatomic, retain)    NSArray *bespeakDTArray;

@property (nonatomic, retain) UIButton *payBtn;

@property (nonatomic, retain) UIButton *cannelBtn;

@property (nonatomic, retain) UIButton *besBtn;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderInfoDic;

@end
