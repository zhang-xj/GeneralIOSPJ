//
//  MyCollectView.h
//  QHC
//
//  Created by qhc2015 on 15/7/3.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHCProjectListView.h"
#import "MasterListView.h"
#import "QHCStoreListView.h"

@interface MyCollectView : UIView<UIScrollViewDelegate, QHCProjectListViewDelegate> {
    UIScrollView *pageScrollView;
    UIScrollView *projectListScrollView;
    
    UISegmentedControl *segmentController;
}

@property (nonatomic, retain) UIScrollView *pageScrollView;
@property (nonatomic, retain) UIScrollView *projectListScrollView;
@property (nonatomic, retain)UISegmentedControl *segmentController;


@end
