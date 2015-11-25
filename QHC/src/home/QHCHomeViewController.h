//
//  QHCHomeViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/4.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHCHomeView.h"
#import <MAMapKit/MAMapKit.h>
#import "SelectCityViewController.h"

@interface QHCHomeViewController : UIViewController<SelectCityViewControllerDelegate> {
    QHCHomeView *homeView;
}

@property (nonatomic, retain)QHCHomeView *homeView;

@end
