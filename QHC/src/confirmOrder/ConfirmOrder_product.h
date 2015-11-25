//
//  ConfirmOrder_product.h
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

@interface ConfirmOrder_product : UIView <UITableViewDelegate, UITableViewDataSource, APPPayOrderDelegate, ConfirmOrderViewPayResultDelegate, MyCardPackageViewControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>{
    NSDictionary *orderFormDetailInfoDic;
    
    UITableView *myTableView;
    
    NSMutableArray *payWaySignArray;
    
    NSInteger selectedPayWay;
    
    NSDictionary *orderInfoDic;
    
    HttpRequestManage *httpRequest;
    
    UIButton *payBtn;
    
    UITextField *buyCountTextField;
    UIButton *decBtn;
    UIButton *addBtn;
    
    NSInteger buyCount;
    
    BOOL keyboardShow;
}

@property (nonatomic, retain)NSDictionary *orderFormDetailInfoDic;

@property (nonatomic, retain)UITableView *myTableView;

@property (nonatomic, retain)NSMutableArray *payWaySignArray;

@property (nonatomic, retain)NSDictionary *orderInfoDic;

@property (nonatomic, retain) HttpRequestManage *httpRequest;

@property (nonatomic, retain)UIButton *payBtn;

@property (nonatomic, retain)UITextField *buyCountTextField;
@property (nonatomic, retain)UIButton *decBtn;
@property (nonatomic, retain)UIButton *addBtn;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderInfoDic;

@end
