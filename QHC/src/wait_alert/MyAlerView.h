//
//  MyAlerView.h
//  LearnEnglish
//
//  Created by zhixu jia on 12-3-31.
//  Copyright (c) 2012年 xuling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAlerView : UIView
{
    NSTimeInterval _delay;
}

+ (id) sharedAler;
- (void) ViewShow:(NSString *)info;

@end
