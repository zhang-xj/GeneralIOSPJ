//
//  StoreDetailViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "LoginView.h"

@interface StoreDetailViewController : UIViewController<LoginDelegate> {
    NSString *storeId;
    
    HttpRequestManage *httpRequest;
}

@property (nonatomic, retain)HttpRequestManage *httpRequest;
@property (nonatomic, retain)NSString *storeId;

-(id)initWithTitle:(NSString*)title andStoreId:(NSString*)storeId;
@end
