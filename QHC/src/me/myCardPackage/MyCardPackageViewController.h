//
//  MyCardPackageViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/27.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCardPackageView_select.h"

@protocol MyCardPackageViewControllerDelegate <NSObject>

@optional
-(void) selectedCardPackageResult:(NSDictionary*)selectedCardDic;

@end

@interface MyCardPackageViewController : UIViewController <MyCardPackageView_selectDelegate> {
    BOOL isSelect;
    
    NSDictionary *selectedCardDic;
}

@property (nonatomic, retain)NSDictionary *selectedCardDic;

@property (nonatomic, assign) id<MyCardPackageViewControllerDelegate> delegate;

-(id) initWithProperty:(NSDictionary*)property;
@end
