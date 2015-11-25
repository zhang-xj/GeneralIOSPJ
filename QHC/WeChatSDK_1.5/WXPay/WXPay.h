//
//  WXPay.h
//  QHC
//
//  Created by qhc2015 on 15/7/27.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WXPay : NSObject


- (void)sendPay:(NSDictionary*)dict;
@end
