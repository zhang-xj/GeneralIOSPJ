//
//  QHCMeView.h
//  QHC
//
//  Created by qhc2015 on 15/6/5.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginView.h"

@interface QHCMeView : UIView<UITableViewDataSource, UITableViewDelegate, LoginDelegate, UIAlertViewDelegate> {
    NSArray             *tableCellTitleArray;
    UITableView *meTableView;
    NSIndexPath *selectedIndexPath;
}

@property (nonatomic, retain)    NSArray             *tableCellTitleArray;
@property (nonatomic, retain)UITableView *meTableView;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

-(void)refreshContentView;
@end
