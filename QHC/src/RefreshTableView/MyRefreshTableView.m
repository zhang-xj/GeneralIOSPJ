//
//  MyRefreshTableView.m
//  QHC
//
//  Created by qhc2015 on 15/6/18.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MyRefreshTableView.h"

@implementation MyRefreshTableView

@synthesize refreshTableView;
@synthesize tableData;
@synthesize noMoreData;

-(id)initWithFrame:(CGRect)frame rowHeight:(float)height{
    self = [super initWithFrame:frame];
    if (self) {
        rowHeight = height;
        self.refreshTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        refreshTableView.backgroundColor = [UIColor clearColor];
        refreshTableView.delegate = self;
        refreshTableView.dataSource = self;
        [self addSubview:refreshTableView];
        noMoreData = NO;
    }
    return self;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    refreshTableView.backgroundColor = backgroundColor;
}

-(void)appendTableData:(NSArray*)appendData{
    
    if (!self.tableData) {
        self.tableData = [[NSMutableArray alloc] initWithArray:appendData];
    } else {
        [self.tableData addObjectsFromArray:appendData];
    }
}

-(void)clearTableData {
    [self.tableData removeAllObjects];
    self.tableData = nil;
}

-(id)getCellData:(NSInteger)index{
    id cellData = [self.tableData objectAtIndex:index];
    return cellData;
}

-(void)reload {
    [refreshTableView reloadData];
}

-(void)setPageDataCount:(NSInteger)count{
    pageDataCount = count;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{//修改group之间的间距
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{//修改group之间的间距
    return 0.1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    if (rowHeight > 0) {
        return rowHeight;
    } else if (rowHeight == -2 && self.delegate && [self.delegate respondsToSelector:@selector(getTableCellHeight:)]) {
        return [self.delegate getTableCellHeight:[tableData objectAtIndex:[indexPath indexAtPosition:1]]];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//点击后恢复原有背景状态
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didSelectRowData:andIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowData:[tableData objectAtIndex:[indexPath indexAtPosition:1]] andIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"willDisplayCell");
    //table要有数据，才会刷新
    if (!noMoreData && tableData && [tableData count]>0) {
        //如果还有下一页数据则执行刷新操作
        if ([tableData count] % pageDataCount == 0) {
            //当最后一行显示出来的时候
            if(indexPath.row == [tableData count]-1){
                if (self.refreshTableView.tableFooterView == nil && self.delegate && [self.delegate respondsToSelector:@selector(refreshData:oldDataCount:onePageDataCount:)]) {
                    //定义footerView
                    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, rowHeight)];
                    //定义loading视图
                    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width - rowHeight*2/3)/2, rowHeight/6, rowHeight*2/3, rowHeight*2/3)];
                    [indicatorView startAnimating];
                    [footerView addSubview:indicatorView];
                    self.refreshTableView.tableFooterView = footerView;
                    
                    [self.delegate refreshData:tableView oldDataCount:[tableData count] onePageDataCount:pageDataCount];
                }
            } else {
                self.refreshTableView.tableFooterView = nil;
            }
        } else {
            self.refreshTableView.tableFooterView = nil;
        }
    } else {
        self.refreshTableView.tableFooterView = nil;
    }
}


#pragma table dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:cellsData:cellForRowAtIndex:)] && tableData && tableData.count > 0) {
        return [self.delegate tableView:tableView cellsData:[tableData objectAtIndex:[indexPath indexAtPosition:1]] cellForRowAtIndex:[indexPath indexAtPosition:1]];
    }
    return nil;
}

@end
