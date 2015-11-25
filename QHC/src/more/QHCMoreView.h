//
//  QHCMoreView.h
//  QHC
//
//  Created by qhc2015 on 15/6/5.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginView.h"
#import "AppDelegate.h"

@interface QHCMoreView : UIView<UITableViewDataSource, UITableViewDelegate>{
    NSArray             *tableCellTitleArray;
    
    UIButton *changeAccountBtn;
}

@property (nonatomic, assign)   id <ShowLoginViewDelegate>  delegate;

@property (nonatomic, retain) NSArray *tableCellTitleArray;

@property (nonatomic, retain)UIButton *changeAccountBtn;

@end
