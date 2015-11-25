//
//  QHCQinghuaBeatView.h
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "LoginView.h"
#import "QHCStoreListViewController.h"
#import "MasterListViewController.h"
#import "BespeakTimeSelectView.h"

@interface QHCProjectDetailView : UIView<UITableViewDataSource, UITableViewDelegate, LoginDelegate, QHCSelectedStoreDelegate, QHCSelectedMasterDelegate, BespeakTimeSelectViewDelegate>{
    NSString *projectId;
    
    UITableView *contentTableView;
    
    HttpRequestManage *httpRequest;
    
    NSDictionary  *contentDataDic;
    
    NSMutableDictionary *bespeakInfoMutdic;
    
    NSArray *bespeakDTArray;
    
    UIView *tableFooterView;
    
    NSInteger loginReponseType;//这个标记是点击购买还是点击收藏跳到登录界面 1:购买 2:收藏
    UIButton *userClickPayButton;//用户选择的购买方式
}
@property (nonatomic, retain)UIButton *userClickPayButton;

@property (nonatomic,retain) UITableView *contentTableView;

@property (nonatomic, copy) NSString* projectId;

@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, retain)NSDictionary *contentDataDic;
@property (nonatomic, retain) NSMutableDictionary *bespeakInfoMutdic;
@property (nonatomic, retain)NSArray *bespeakDTArray;

@property (nonatomic, retain)UIView *tableFooterView;

-(id)initWithFrame:(CGRect)frame withData:(NSDictionary*)dataDic;

-(void)refreshFirstBuyBtnStatus;
@end
