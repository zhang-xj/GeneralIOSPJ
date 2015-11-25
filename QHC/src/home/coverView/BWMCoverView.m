//
//  BWMCoverView.m
//  BWMCoverViewDemo
//
//  Created by qhc2015 on 15/4/28.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//


#import "BWMCoverView.h"
#import "UIImageView+WebCache.h"

@interface BWMCoverView()
{
    NSTimer *_timer;
    NSTimeInterval _second;
}

@end

@implementation BWMCoverView

- (id)initWithModels:(NSArray *)iamgeURIArray andFrame:(CGRect)frame
{
    if (self  = [super initWithFrame:frame]) {
        self.imageURIArray = iamgeURIArray;
        self.animationOption = 0 << 20;
        [self createUI];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageViewsContentMode = UIViewContentModeScaleToFill;
        [self createUI];
    }
    return self;
}

+ (id)coverViewWithModels:(NSArray *)iamgeURIArray andFrame:(CGRect)frame andPlaceholderImageNamed:(NSString *)placeholderImageNamed andClickdCallBlock:(void (^)(NSInteger index))callBlock
{
    BWMCoverView *coverView = [[BWMCoverView alloc] initWithModels:iamgeURIArray andFrame:frame];
    coverView.placeholderImageNamed = placeholderImageNamed;
    coverView.callBlock = callBlock;
    [coverView updateView];
    return coverView;
}

// 创建UI
- (void)createUI
{
    //图片尺寸 必须使用相对位置
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    //改变图片轮播器颜色
//    _scrollView.backgroundColor = [UIColor redColor];
    [self addSubview:_scrollView];
    
    //分页点的位置
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20
, self.frame.size.width, 20)];
    _pageControl.userInteractionEnabled = YES;
    _pageControl.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    [self addSubview:_pageControl];
    
}

// 更新视图
- (void)updateView
{
    _scrollView.contentSize = CGSizeMake((_imageURIArray.count+2)*_scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    
    
    // 清除所有滚动视图
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i<_imageURIArray.count+2; i++) {

        CGRect imgViewFrame = CGRectMake(i*_scrollView.frame.size.width, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imgViewFrame];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.tag = i-1;
        
        // 默认执行SDWebImage的缓存方法
        NSString *imgName = [_imageURIArray objectAtIndex:(i%_imageURIArray.count)];
        if ([imgName rangeOfString:@"http://"].location != NSNotFound) {
            NSURL *imgUrl = [NSURL URLWithString:imgName];
            [imageView sd_setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"default_detail_img.png"]];
        } else {
            [imageView setImage:[UIImage imageNamed:imgName]];
        }
        
        [_scrollView addSubview:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
            [imageView addGestureRecognizer:tap];
    }
    
    // 设置titleLabel和pageControl的相关内容数据
    if (_imageURIArray.count>0) {
        _pageControl.numberOfPages = _imageURIArray.count;
        [_pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    }
    
    // 先执行一次这个方法
    if (_scrollViewCallBlock != nil)
    {
        _scrollViewCallBlock(0);
    }
    
}

// 图片轻敲手势事件
- (void)imageViewClicked:(UITapGestureRecognizer *)recognizer
{
    NSInteger index = recognizer.view.tag;
    if (_callBlock != nil) {
        _callBlock(index);
    }
}

// pageControl修改事件
- (void)pageControlClicked:(UIPageControl *)pageControl
{
    [self scrollViewScrollToPageIndex:pageControl.currentPage+1];
}

// 设置自动播放
- (void)setAutoPlayWithDelay:(NSTimeInterval)second
{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _second = second;
    _timer = [NSTimer scheduledTimerWithTimeInterval:second target:self selector:@selector(scrollViewAutoScrolling) userInfo:nil repeats:YES];
}

// 暂停或开启自动播放
- (void)stopAutoPlayWithBOOL:(BOOL)isStopAutoPlay
{
    if (_timer) {
        if (isStopAutoPlay) {
            [_timer invalidate];
        } else {
            _timer = [NSTimer scheduledTimerWithTimeInterval:_second target:self selector:@selector(scrollViewAutoScrolling) userInfo:nil repeats:YES];
        }
    }
}

// 自动滚动
- (void)scrollViewAutoScrolling
{
    CGPoint point;
    point = _scrollView.contentOffset;
    point.x += _scrollView.frame.size.width;
    
    [self animationScrollWithPoint:point];
}

// 滚动到指定的页面
- (void)scrollViewScrollToPageIndex:(NSInteger)page
{
    CGPoint point;
    point = CGPointMake(_scrollView.frame.size.width*page, 0);
    
    [self animationScrollWithPoint:point];
}

// 滚动到指点的point
- (void)animationScrollWithPoint:(CGPoint)point
{
    // 判断是否是需要动画
    if (_animationOption != 0 << 20) {
        _scrollView.contentOffset = point;
        [self scrollViewDidEndDecelerating:_scrollView];
        [UIView transitionWithView:_scrollView duration:0.7 options:_animationOption animations:nil completion:nil];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            _scrollView.contentOffset = point;
        }completion:^(BOOL finished) {
            if (finished) {
                [self scrollViewDidEndDecelerating:_scrollView];
            }
        }];
    }
}


- (void)setScrollViewCallBlock:(void (^)(NSInteger index))scrollViewCallBlock
{
    _scrollViewCallBlock = [scrollViewCallBlock copy];
    _scrollViewCallBlock(0);
}

#pragma mark-
#pragma mark- UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 停止自动播放
    if ([_timer isValid]) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 设置伪循环滚动
    if (scrollView.contentOffset.x == 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentSize.width-2*scrollView.frame.size.width, 0);
        
    } else if(scrollView.contentOffset.x >= scrollView.contentSize.width-scrollView.frame.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0);
    }
    
    int currentPage = scrollView.contentOffset.x/self.frame.size.width-1;
    _pageControl.currentPage = currentPage;
    
    // 恢复自动播放
    if ([_timer isValid]) {
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_second]];
    }
    
    if(_scrollViewCallBlock != nil)
    {
        _scrollViewCallBlock(currentPage);
    }
}

@end