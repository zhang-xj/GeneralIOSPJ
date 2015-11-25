//
//  SelectCityView.h
//  QHC
//
//  Created by qhc2015 on 15/7/22.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"

@protocol  SelectCityViewDelegate<NSObject>
@optional
-(void)selected:(NSString*)cityName;
@end

@interface SelectCityView : UIView <UITableViewDataSource, UITableViewDelegate> {
    HttpRequestManage *httpRequest;
    
    UITableView *cityTableView;
    
    NSArray *cityArray;
    
    NSMutableArray *selCitySignArray;
}

@property (nonatomic, assign)id<SelectCityViewDelegate> delegate;

@property (nonatomic, retain)HttpRequestManage *httpRequest;
@property (nonatomic, retain)UITableView *cityTableView;
@property (nonatomic, retain)NSArray *cityArray;
@property (nonatomic, retain)NSMutableArray *selCitySignArray;


@end
