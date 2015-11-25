//
//  LoadingView.h
//  QHC
//
//  Created by qhc2015 on 15/6/17.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

+(LoadingView*)sharedLoadingView;

-(void)show;
-(void)hidden;
@end
