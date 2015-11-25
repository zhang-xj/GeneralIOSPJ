//
//  MyRefreshTableView.h
//  QHC
//
//  Created by qhc2015 on 15/6/18.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  MyRefreshTableViewDelegate<NSObject>
@required
- (UITableViewCell *)tableView:(UITableView *)tableView cellsData:(NSObject*)cellData cellForRowAtIndex:(NSInteger)index;
- (void) refreshData:(UITableView*)tableView oldDataCount:(NSInteger)oldDataCount onePageDataCount:(NSInteger)onePageDataCount;
- (void) tableView:(UITableView *)tableView didSelectRowData:(NSObject *)selectRowData andIndexPath:(NSIndexPath *)indexPath;
@optional
-(float) getTableCellHeight:(NSObject*)cellData;
@end

@interface MyRefreshTableView : UIView <UITableViewDataSource, UITableViewDelegate> {
    UITableView         *refreshTableView;
    
    NSMutableArray             *tableData;
    
    float                     rowHeight;
    
    NSInteger                  pageDataCount;
    
    BOOL  noMoreData;
}
@property (nonatomic, assign)   id <MyRefreshTableViewDelegate>  delegate;
@property (nonatomic, retain)UITableView *refreshTableView;
@property (nonatomic, retain)NSMutableArray *tableData;

@property (nonatomic, assign)BOOL noMoreData;

-(id)initWithFrame:(CGRect)frame rowHeight:(float)height;

-(void)appendTableData:(NSArray*)appendData;
-(void)clearTableData;
-(id)getCellData:(NSInteger)index;
-(void)reload;
-(void)setPageDataCount:(NSInteger)count;
@end
