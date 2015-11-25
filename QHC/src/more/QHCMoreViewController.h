//
//  QHCMoreViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/4.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "QHCMoreView.h"

@interface QHCMoreViewController : UIViewController <ShowLoginViewDelegate, LoginDelegate> {
    QHCMoreView *moreView;
}

@property (nonatomic, retain)QHCMoreView *moreView;

@end
