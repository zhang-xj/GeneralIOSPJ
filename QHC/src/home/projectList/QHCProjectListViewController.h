//
//  BodyCareViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHCProjectListView.h"
#import "LoginView.h"

@interface QHCProjectListViewController : UIViewController<QHCProjectListViewDelegate, LoginDelegate> {
    NSDictionary *bundleDataDic;
    
    UIScrollView *contentScrollView;
}
@property (nonatomic, retain)NSDictionary *bundleDataDic;

@property (nonatomic, retain)UIScrollView *contentScrollView;

- (id)initWithData:(NSDictionary*)initDic;
@end
