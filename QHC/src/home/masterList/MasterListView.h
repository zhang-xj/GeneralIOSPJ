//
//  MasterListView.h
//  QHC
//
//  Created by qhc2015 on 15/6/16.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "MyRefreshTableView.h"

@protocol  MasterListViewDelegate<NSObject>
@optional
-(void)selectedMaster:(NSDictionary*)masterInfoDic;
@end

@interface MasterListView : UIView<MyRefreshTableViewDelegate> {
    MyRefreshTableView             *mRfTableView;
    
    HttpRequestManage       *httpRequest;
    
    
    NSDictionary *propertyDic;
    NSString *storeIndex;
    BOOL    isSelected;
    
    UIButton *oldSelectedBox;
    
    NSString *sortType;
    NSString *salerStar;
    
    UIView *classSelectView;
    
    NSInteger selectCellIndex;
    
    BOOL refreshTableData;
}

@property (nonatomic, assign)   id <MasterListViewDelegate>  delegate;

@property (nonatomic, retain)MyRefreshTableView *mRfTableView;
@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, retain) NSDictionary *propertyDic;
@property (nonatomic, copy)NSString *storeIndex;
@property (nonatomic, retain)UIButton *oldSelectedBox;

@property (nonatomic, copy)NSString *sortType;
@property (nonatomic, copy)NSString *salerStar;

@property (nonatomic, retain)UIView *classSelectView;

-(id)initWithFrame:(CGRect)frame andProperty:(NSDictionary*)property storeID:(NSString*)storeId isSelectedView:(BOOL)selected;
@end
