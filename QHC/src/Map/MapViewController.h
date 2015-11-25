//
//  MapViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/19.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

@interface MapViewController : UIViewController<MAMapViewDelegate> {
    NSDictionary *mapInitInfoDic;
    
    MAMapView *visibleMapView;
}
@property (nonatomic, retain)NSDictionary *mapInitInfoDic;
@property (nonatomic, retain)MAMapView *visibleMapView;

-(id)initWithProperty:(NSDictionary*)property;
@end
