//
//  MyCollectView.m
//  QHC
//
//  Created by qhc2015 on 15/7/3.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MyCollectView.h"
#import "AppDelegate.h"

@implementation MyCollectView

@synthesize pageScrollView;
@synthesize segmentController;
@synthesize projectListScrollView;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSegment];
        [self createContentView];
    }
    return self;
}

-(void)createSegment{
    NSArray *segmentArray = [[NSArray alloc] initWithObjects:@"服务",  @"养生顾问", @"门店", nil];
    
    self.segmentController = [[UISegmentedControl alloc] initWithItems:segmentArray];
    segmentController.frame = CGRectMake((self.frame.size.width - 180)/2, (CONTENT_OFFSET - 22)/2, 180, 22.0);
    [segmentController addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentController.selectedSegmentIndex = 0;
    segmentController.tintColor = RGBA(157, 80, 147, 255);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, CONTENT_OFFSET)];
    view.backgroundColor = [UIColor tableViewBackgroundColor];
    [view addSubview:segmentController];
    [self addSubview:view];
}

-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger index = Seg.selectedSegmentIndex;
    switch (index) {
        case 0:
            [self.pageScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
            break;
        case 1:
            [self.pageScrollView setContentOffset:CGPointMake(pageScrollView.frame.size.width, 0.0) animated:YES];
            break;
        case 2:
            [self.pageScrollView setContentOffset:CGPointMake(pageScrollView.frame.size.width*2, 0.0) animated:YES];
            break;
    }
}

-(void)createContentView {
    self.pageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, CONTENT_OFFSET, self.frame.size.width, self.frame.size.height - 2*CONTENT_OFFSET)];
    pageScrollView.pagingEnabled = YES;
    pageScrollView.delegate = self;
    [self addSubview: pageScrollView];
    //服务项目
    self.projectListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, pageScrollView.frame.size.height)];
    [pageScrollView addSubview:projectListScrollView];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1", @"Favorites/List.aspx", nil] forKeys:[NSArray arrayWithObjects:@"type", @"isCollect", nil]];
    QHCProjectListView *pjListView = [[QHCProjectListView alloc] initWithFrame:CGRectMake(0.0, 0.0, projectListScrollView.frame.size.width, projectListScrollView.frame.size.height) withData:params];
    pjListView.delegate = self;
    [projectListScrollView addSubview:pjListView];
    //养生顾问
    params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"2", @"Favorites/List.aspx", nil] forKeys:[NSArray arrayWithObjects:@"type", @"isCollect", nil]];
    MasterListView *mtListView = [[MasterListView alloc]initWithFrame:CGRectMake(pageScrollView.frame.size.width, 0.0, pageScrollView.frame.size.width, pageScrollView.frame.size.height) andProperty:params storeID:@"*" isSelectedView:NO];
    [pageScrollView addSubview:mtListView];
    //门店
        params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"3", @"Favorites/List.aspx", nil] forKeys:[NSArray arrayWithObjects:@"type", @"isCollect", nil]];
    QHCStoreListView *storeListView = [[QHCStoreListView alloc]initWithFrame:CGRectMake(pageScrollView.frame.size.width*2, 0.0, pageScrollView.frame.size.width, pageScrollView.frame.size.height) andProperty:params isSelectedView:NO];
    [pageScrollView addSubview:storeListView];
    
    [pageScrollView setContentSize:CGSizeMake(pageScrollView.frame.size.width *3, pageScrollView.frame.size.height)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma UIScrollViewDelegate
// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //    NSLog([NSString stringWithFormat:@"scrollViewDidEndDecelerating scrollView.x = %f", scrollView.contentOffset.x]);
    NSInteger selectedIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
    self.segmentController.selectedSegmentIndex = selectedIndex;
}

#pragma QHCProjectListViewDelegate
-(void)viewRealFrame:(CGRect)frame{
    [self.projectListScrollView setContentSize:CGSizeMake(projectListScrollView.frame.size.width, frame.size.height)];
}
@end
