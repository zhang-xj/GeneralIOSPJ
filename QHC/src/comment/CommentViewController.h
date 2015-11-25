//
//  CommentViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/6.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UIViewController {
    NSString *objectId;
    NSString *objectType;
}

@property (nonatomic, copy)NSString *objectId;
@property (nonatomic, copy)NSString *objectType;

- (id)initWithProjectID:(NSString*)proId type:(NSString*)obType;
@end
