//
//  QHCStoreListView.h
//  QHC
//
//  Created by qhc2015 on 15/6/17.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "MyRefreshTableView.h"

@protocol  QHCStoreListViewDelegate<NSObject>
@optional
-(void)selectedStore:(NSDictionary*)storeInfoDic;
@end

@interface QHCStoreListView : UIView<MyRefreshTableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    MyRefreshTableView             *mRfTableView;
    
    HttpRequestManage       *httpRequest;
    
    NSDictionary *propertyDic;
    BOOL    isSelected;
    
    UIButton *oldSelectedBox;
    
    UIView *classSelectView;
    
    NSArray *areaArray;
    NSString *areaName;
    NSString *storeName;
    
    BOOL keyboardShow;
    
    NSInteger selectCellIndex;
    
    BOOL refreshTabelView;
}

@property (nonatomic, assign)   id <QHCStoreListViewDelegate>  delegate;

@property (nonatomic, retain)MyRefreshTableView *mRfTableView;
@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, retain) NSDictionary *propertyDic;
@property (nonatomic, retain)UIButton *oldSelectedBox;

@property (nonatomic, retain)UIView *classSelectView;

@property (nonatomic, retain)NSArray *areaArray;
@property (nonatomic, copy) NSString *areaName;
@property (nonatomic, copy) NSString *storeName;

-(id)initWithFrame:(CGRect)frame andProperty:(NSDictionary*)property isSelectedView:(BOOL)selected;
@end
