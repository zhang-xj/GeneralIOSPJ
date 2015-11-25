//
//  AppDelegate.h
//  QHC
//
//  Created by qhc2015 on 15/6/3.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "WXApi.h"

@protocol  ConfirmOrderViewPayResultDelegate<NSObject>
@optional
-(void)WXPayResult:(NSInteger)resultColde;
@end

@protocol ShowLoginViewDelegate <NSObject>
@optional
-(void)showLoginView;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, WXApiDelegate, MAMapViewDelegate, AMapSearchDelegate>
{
    UINavigationController *myRootController;
    
    UITabBarController *tabBarController;
    
    MAMapView           *mapView;
    AMapSearchAPI *search;
    
    NSMutableDictionary *locationAddrMutDic;
}

@property (nonatomic, assign)   id <ConfirmOrderViewPayResultDelegate>  delegate;

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) UINavigationController *myRootController;
@property (retain, nonatomic) UITabBarController *tabBarController;
@property (retain, nonatomic) MAMapView *mapView;
@property (retain, nonatomic) AMapSearchAPI *search;
@property (retain, nonatomic)NSMutableDictionary *locationAddrMutDic;

+(UIView*)createTopTitleView;
+(UIImageView*)createStatusBackground;

+(CGSize) getStringInLabelSize:(NSString*)string andFont:(UIFont*)font andLabelWidth:(float)width;

+ (void)clearTmpPics;

-(void)clearUserInfoCache;
@end

