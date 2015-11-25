//
//  BodyCareView.h
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"
#import "LoginView.h"

@protocol QHCProjectListViewDelegate <NSObject>
@optional
-(void)viewRealFrame:(CGRect)frame;
-(void)showLoginView;
@end

@interface QHCProjectListView : UIView{
    NSDictionary *bundleDataDic;
    
    HttpRequestManage   *httpRequest;
    
    NSArray             *projectArray;
    
    NSMutableDictionary *selectedProjectListDic;
}

@property (nonatomic, assign)   id <QHCProjectListViewDelegate>  delegate;
@property (nonatomic, retain)NSDictionary *bundleDataDic;
@property (nonatomic, retain)HttpRequestManage *httpRequest;
@property (nonatomic, retain)NSArray *projectArray;
@property (nonatomic, retain)NSMutableDictionary *selectedProjectListDic;

-(void)touchAction:(id)sender;
-(id)initWithFrame:(CGRect)frame withData:(NSDictionary*)dataDic;
@end
