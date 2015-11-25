//
//  BespeakTimeSelectView.h
//  QHC
//
//  Created by qhc2015 on 15/7/13.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BespeakTimeSelectViewDelegate <NSObject>
//通知使用这个控件的类，用户选取的日期
- (void)selected:(NSUInteger)dayIndex timeId:(NSUInteger)timeIndex;
@end

@interface BespeakTimeSelectView : UIView<UIGestureRecognizerDelegate> {
    NSArray *bespeakTimeArray;
    NSArray *bespeakDayArray;
    
    NSUInteger dayIndex;
    NSUInteger timeIndex;
}
@property (nonatomic, assign) id<BespeakTimeSelectViewDelegate> delegate;

@property (nonatomic, retain)NSArray *bespeakTimeArray;
@property (nonatomic, retain)NSArray *bespeakDayArray;

-(id)initWithFrame:(CGRect)frame andData:(NSArray*)selectArray;
@end
