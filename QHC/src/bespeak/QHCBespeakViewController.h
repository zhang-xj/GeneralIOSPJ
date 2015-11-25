//
//  QHCBespeakViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/4.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginView.h"
#import "QHCBespeakView.h"


@interface QHCBespeakViewController : UIViewController<LoginDelegate>{
    LoginView *loginView;
    QHCBespeakView *bespeakView;
}

@property (nonatomic, retain)QHCBespeakView *bespeakView;
@property (nonatomic, retain)LoginView *loginView;
@end
