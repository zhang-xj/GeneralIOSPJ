//
//  LoadingView.m
//  QHC
//
//  Created by qhc2015 on 15/6/17.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "LoadingView.h"

#ifndef LOADING_VIEW_TAG
#define LOADING_VIEW_TAG 12345
#endif

@implementation LoadingView

+(LoadingView*)sharedLoadingView{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    LoadingView *loadingView = (LoadingView *)[window.rootViewController.view viewWithTag:LOADING_VIEW_TAG];
    
    if (!loadingView) {
        loadingView = [[LoadingView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        loadingView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
        loadingView.tag = LOADING_VIEW_TAG;
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((loadingView.frame.size.width - 80)/2, loadingView.frame.size.height/3, 80, 80)];
        indicatorView.tag = LOADING_VIEW_TAG*10 + 1;
        [loadingView addSubview:indicatorView];
        
        [window.rootViewController.view addSubview:loadingView];
        loadingView.hidden = YES;
    }
    
    return loadingView;
}

-(void)show{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    LoadingView *loadingView = (LoadingView *)[window.rootViewController.view viewWithTag:LOADING_VIEW_TAG];
    if (loadingView) {
        loadingView.hidden = NO;
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[loadingView viewWithTag:(LOADING_VIEW_TAG*10+1)];
        [indicatorView startAnimating];
        [window.rootViewController.view bringSubviewToFront:loadingView];
    }
}
-(void)hidden{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *loadingView = (LoadingView *)[window.rootViewController.view viewWithTag:LOADING_VIEW_TAG];
    if (loadingView) {
        loadingView.hidden = YES;
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[loadingView viewWithTag:(LOADING_VIEW_TAG*10+1)];
        [indicatorView stopAnimating];
        [window.rootViewController.view sendSubviewToBack:loadingView];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
