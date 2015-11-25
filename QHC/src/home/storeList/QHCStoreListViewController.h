//
//  QHCStoreListViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/17.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHCStoreListView.h"

@protocol  QHCSelectedStoreDelegate<NSObject>
@optional
-(void)selectedStoreInfo:(NSDictionary*)storeInfoDic;
@end

@interface QHCStoreListViewController : UIViewController <QHCStoreListViewDelegate>{
    NSDictionary *propertyDic;
    
    NSDictionary *selectedStoreInfoDic;
    BOOL    isSelected;
}

@property (nonatomic, assign)id <QHCSelectedStoreDelegate> delegate;

@property (nonatomic, retain)NSDictionary *propertyDic;
@property (nonatomic, retain)NSDictionary *selectedStoreInfoDic;


- (id)initWithProperty:(NSDictionary*)property isSelectedView:(BOOL)selected;
@end
