//
//  QHCMyOrderFormViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/30.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHCMyOrderFormViewController : UIViewController {
    NSInteger orderType;
}


- (id)initWithTitle:(NSString*)pageTitle pType:(NSInteger)type;
@end
