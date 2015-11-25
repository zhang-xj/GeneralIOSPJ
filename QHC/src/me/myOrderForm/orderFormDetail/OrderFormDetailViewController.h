//
//  OrderFormViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/14.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderFormDetailViewController : UIViewController {
    NSDictionary *orderInfoDic;
}

@property (nonatomic, retain) NSDictionary *orderInfoDic;

-(id)initWithOrderInfo:(NSDictionary*)orderInfo;
@end
