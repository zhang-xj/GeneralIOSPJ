//
//  PersonalInfoViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/3.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalInfoView.h"

@interface PersonalInfoViewController : UIViewController {
    PersonalInfoView *plInfoView;
}

@property (nonatomic, retain)PersonalInfoView *plInfoView;

@end
