//
//  MasterSearchListViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/23.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterSearchListViewController : UIViewController{
    
    NSString *searchKey;
}

@property (nonatomic, retain)NSString *searchKey;

- (id)initWithProperty:(NSString*)search_key;

@end
