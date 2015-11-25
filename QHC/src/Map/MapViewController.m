//
//  MapViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/19.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapInitInfoDic;

@synthesize visibleMapView;

-(id)initWithProperty:(NSDictionary*)property {
    self = [super init];
    if (self) {
        self.mapInitInfoDic = property;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.visibleMapView = [[MAMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];;
    self.visibleMapView.showsUserLocation = YES;
    self.visibleMapView.delegate = self;
    //设置地图显示中心
    CLLocationCoordinate2D center;
    center.latitude = [((NSString*)[self.mapInitInfoDic objectForKey:@"latitude"]) doubleValue];
    center.longitude = [((NSString*)[self.mapInitInfoDic objectForKey:@"longitude"]) doubleValue];
    
    [self setZoomLevel:self.visibleMapView centerPoint:center];
    
    //地图标注
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = center;
    pointAnnotation.title = [self.mapInitInfoDic objectForKey:@"name"];
    pointAnnotation.subtitle = [self.mapInitInfoDic objectForKey:@"addr"];
    
    [self.visibleMapView addAnnotation:pointAnnotation];
    
//    mapView.centerCoordinate = mapView.userLocation.location.coordinate;

    [self.view addSubview:self.visibleMapView];
    
    [self addBackButton];
}

//取比例尺
-(void)setZoomLevel:(MAMapView*)mapView  centerPoint:(CLLocationCoordinate2D)center{
    mapView.centerCoordinate = center;
    float zoomLevel = 16.0;
    while (true) {
        //设置地图初始化比例尺
        NSLog(@"map zoomLevel = %.2f", zoomLevel);
        [mapView setZoomLevel:zoomLevel animated:YES];
        mapView.centerCoordinate = center;
        //1.将annotation的经纬度点转成投影点
        MAMapPoint point = MAMapPointForCoordinate(((AppDelegate*)([UIApplication sharedApplication].delegate)).mapView.userLocation.location.coordinate);
        //2.判断该点是否在地图可视范围
        BOOL isContains = MAMapRectContainsPoint(mapView.visibleMapRect, point);
        if (isContains || zoomLevel - 0.1 < 10.0) {
            break;
        } else {
            zoomLevel -= 0.1;
        }
    }
}

-(void)backAction:(id)sender {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

//添加顶部标题视图
-(void)addBackButton {

    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 20.0, CONTENT_OFFSET, CONTENT_OFFSET)];
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    leftButton.backgroundColor = RGBA(173, 104, 159, 180);
    [leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}

/*!
 @brief 位置或者设备方向更新后，会调用此函数
 @param mapView 地图View
 @param userLocation 用户定位信息(包括位置与设备方向等数据)
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation;{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}

@end
