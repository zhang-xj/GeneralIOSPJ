//
//  ConfirmOrderViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmOrderViewController : UIViewController {
    NSDictionary *orderFormDetailDic;
}

@property (nonatomic, retain)NSDictionary *orderFormDetailDic;


-(id)initWithOrderInfo:(NSDictionary*)orderInfoDic;
@end
