//
//  StatementViewController.h
//  QHC
//
//  Created by qhc2015 on 15/8/8.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"

@interface StatementViewController : UIViewController {
    UIScrollView *contentScrollView;
    
    HttpRequestManage *httpRequest;
}

@property (nonatomic, retain)UIScrollView *contentScrollView;

@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, retain)UILabel *infoLabel;
@end
