//
//  SelectCityViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/22.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCityView.h"
@protocol  SelectCityViewControllerDelegate<NSObject>
@optional
-(void)selectedCity:(NSString*)cityName;
@end

@interface SelectCityViewController : UIViewController<SelectCityViewDelegate> 

@property (nonatomic, assign)id<SelectCityViewControllerDelegate> delegate;
@end
