//
//  MasterDetailViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginView.h"
#import "HttpRequestManage.h"

@interface MasterDetailViewController : UIViewController<LoginDelegate> {
    NSDictionary *masterInfoDic;
    
    HttpRequestManage *httpRequest;
}

@property (nonatomic, retain)HttpRequestManage *httpRequest;
@property (nonatomic, retain)NSDictionary *masterInfoDic;

-(id)initWithData:(NSDictionary*)masterDic;
@end
