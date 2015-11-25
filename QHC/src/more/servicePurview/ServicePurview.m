//
//  ServicePurview.m
//  QHC
//
//  Created by qhc2015 on 15/7/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "ServicePurview.h"
#import "AppDelegate.h"

@implementation ServicePurview

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentView];
    }
    return self;
}

-(void)createContentView {
//    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CONTENT_OFFSET, self.frame.size.width, self.frame.size.height - CONTENT_OFFSET)];
    UIWebView *serPurview = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width - 10, self.frame.size.height)];
    serPurview.backgroundColor = [UIColor tabBarBackgroundColor];
    serPurview.layer.cornerRadius = 6;
    [self addSubview:serPurview];
}

@end
