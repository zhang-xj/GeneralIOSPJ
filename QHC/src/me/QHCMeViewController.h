//
//  QHCMeViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/4.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHCMeView.h"

@interface QHCMeViewController : UIViewController {
    QHCMeView *meView;
}

@property (nonatomic, retain)     QHCMeView *meView;

@end
