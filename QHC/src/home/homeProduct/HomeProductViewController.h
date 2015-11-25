//
//  HomeProductViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/25.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeProductViewController : UIViewController {
        NSDictionary *propertyDic;
}
@property (nonatomic, retain)    NSDictionary *propertyDic;

- (id)initWithProperty:(NSDictionary*)property;

@end
