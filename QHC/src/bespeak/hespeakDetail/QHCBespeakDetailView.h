//
//  QHCBespeakDetailView.h
//  QHC
//
//  Created by qhc2015 on 15/6/30.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "QHCStoreListViewController.h"
#import "MasterListViewController.h"
#import "BespeakTimeSelectView.h"

@interface QHCBespeakDetailView : UIView<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIAlertViewDelegate, QHCSelectedStoreDelegate, MasterListViewDelegate, BespeakTimeSelectViewDelegate> {
    NSDictionary        *detailDataDic;
    NSString *reservationid;
    NSInteger reservationStatus;
    UITableView *myTableView;
    
    NSMutableDictionary *bespeakInfoMutdic;
    
    UITextView *pingjiaTextView;
    
    HttpRequestManage *httpRequest;
    
    NSArray *bespeakDTArray;
    
    NSInteger level;
}

@property (nonatomic, retain)NSDictionary *detailDataDic;
@property (nonatomic, copy)NSString *reservationid;
@property (nonatomic, retain)UITableView *myTableView;
@property (nonatomic, retain)NSMutableDictionary *bespeakInfoMutdic;

@property (nonatomic, retain)UITextView *pingjiaTextView;

@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, retain)NSArray *bespeakDTArray;

-(id)initWithFrame:(CGRect)frame withData:(NSDictionary*)dataDic;
@end
