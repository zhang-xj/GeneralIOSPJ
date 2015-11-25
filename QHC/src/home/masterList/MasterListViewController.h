//
//  MasterListViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/16.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterListView.h"

@protocol  QHCSelectedMasterDelegate<NSObject>
@optional
-(void)selectedMasterInfo:(NSDictionary*)storeInfoDic;
@end

@interface MasterListViewController : UIViewController <MasterListViewDelegate, UITextFieldDelegate> {
    NSDictionary *propertyDic;
    NSDictionary *selectedMasterInfoDic;
    NSString *storeIndex;
    BOOL    isSelected;
    
    UIView *masterSearchView;
}

@property (nonatomic, assign)id <QHCSelectedMasterDelegate> delegate;

@property (nonatomic, retain)NSDictionary *propertyDic;
@property (nonatomic, retain)NSDictionary *selectedMasterInfoDic;
@property (nonatomic, copy)NSString *storeIndex;

@property (nonatomic, retain)UIView *masterSearchView;

- (id)initWithProperty:(NSDictionary*)property storeID:(NSString*)storeId isSelectedView:(BOOL)selected;
@end
