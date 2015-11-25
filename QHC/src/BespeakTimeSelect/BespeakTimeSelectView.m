//
//  BespeakTimeSelectView.m
//  QHC
//
//  Created by qhc2015 on 15/7/13.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "BespeakTimeSelectView.h"

@implementation BespeakTimeSelectView

#ifndef TAG_DATEVIEW
#define TAG_DATEVIEW 800
#endif
#ifndef TAG_DATE_ITEM
#define TAG_DATE_ITEM 8000
#endif
#ifndef TAG_TIMEVIEW
#define TAG_TIMEVIEW 700
#endif
#ifndef TAG_TIME_ITEM
#define TAG_TIME_ITEM 7000
#endif

@synthesize bespeakTimeArray;
@synthesize bespeakDayArray;

-(id)initWithFrame:(CGRect)frame andData:(NSArray*)selectArray {
    self = [super initWithFrame:frame];
    if (self) {
        dayIndex = 0;
        timeIndex = 0;
        
        self.bespeakDayArray = selectArray;
        NSDictionary *timeDic = [self.bespeakDayArray objectAtIndex:dayIndex];
        self.bespeakTimeArray = [timeDic objectForKey:@"freelist"];
        
        self.backgroundColor = RGBA(190, 190, 190, 180);
        
        [self createSelectView];
        
        //添加单击时间，用于关闭预约时间选择框
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBespeakSelectView)];
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        self.userInteractionEnabled = YES;
    }
    return self;
}

//确定所选预约时间
-(void)btnOKAction:(id)sender {
    NSLog(@"dayIndex = %lu; timeIndex = %lu", dayIndex, timeIndex);
    if (self.delegate) {
        [self.delegate selected:dayIndex timeId:timeIndex];
        [self hideBespeakSelectView];
    }
}

//选择日期
-(void)selectData:(id)sender {
    UIView *dateView = [self viewWithTag:TAG_DATEVIEW];
    for (UIView *subView in [dateView subviews]) {
        if (((UIView*)sender).tag == subView.tag) {
            subView.backgroundColor = RGBA(177, 113, 169, 255);
            dayIndex = subView.tag - TAG_DATE_ITEM;
            UIView *timeView = [self viewWithTag:TAG_TIMEVIEW + dayIndex];
            timeView.hidden = NO;
            [self selectTime:nil];
        } else {
            subView.backgroundColor = [UIColor clearColor];
            UIView *timeView = [self viewWithTag:TAG_TIMEVIEW + (subView.tag - TAG_DATE_ITEM)];
            timeView.hidden = YES;
        }
    }
    
}

//选择时间
-(void)selectTime:(id)sender {
    UIView *timeView = [self viewWithTag:(TAG_TIMEVIEW + dayIndex)];

    for (UIView *subView in [timeView subviews]) {
        if (nil == sender) {
            timeIndex = 0;
            if (subView.tag == TAG_TIME_ITEM) {
                subView.backgroundColor = RGBA(177, 113, 169, 255);
            } else {
                subView.backgroundColor = [UIColor whiteColor];
            }
        } else {
        if (((UIView*)sender).tag == subView.tag) {
            subView.backgroundColor = RGBA(177, 113, 169, 255);
            timeIndex = subView.tag - TAG_TIME_ITEM;
        } else {
            subView.backgroundColor = [UIColor whiteColor];
        }
        }
    }
}

-(void)createSelectView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 299, self.frame.size.width, 299)];
    view.backgroundColor = RGBA(190, 190, 190, 255);
    [self addSubview:view];
    //顶部视图
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, view.frame.size.width, 35)];
    topView.backgroundColor = RGBA(177, 113, 169, 255);
    [view addSubview:topView];
    //标题
    UILabel *label = [[UILabel alloc] initWithFrame:topView.frame];
    label.text = @"请预约您的体验时间";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    [topView addSubview:label];
    
    if (self.bespeakDayArray && self.bespeakDayArray.count > 0) {
        //确定按钮
        UIButton *btnOK = [[UIButton alloc] initWithFrame:CGRectMake(topView.frame.size.width - 40, 0.0, 40, topView.frame.size.height)];
        [btnOK setTitle:@"确定" forState:UIControlStateNormal];
        btnOK.titleLabel.font = BUTTON_TEXT_FONT;
        [btnOK addTarget:self action:@selector(btnOKAction:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:btnOK];
        
        //日期选择视图
        UIView *dateSelView = [[UIView alloc] initWithFrame:CGRectMake(0.0, topView.frame.size.height, self.frame.size.width, 59)];
        dateSelView.backgroundColor = [UIColor tableViewBackgroundColor];
        [dateSelView setTag:TAG_DATEVIEW];
        [view addSubview:dateSelView];
        //日期列表
        NSInteger count = 5;
        float item_w = (dateSelView.frame.size.width - 4)/count;
        float item_h = 43;
        for(int i = 0; i < self.bespeakDayArray.count; i++){
            UIButton *dateBtn = [[UIButton alloc] initWithFrame:CGRectMake(2+i*item_w, (dateSelView.frame.size.height - item_h)/2, item_w, item_h)];
            dateBtn.layer.cornerRadius = 6;
            [dateBtn setTag:(TAG_DATE_ITEM + i)];
            [dateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            dateBtn.titleLabel.font = BUTTON_TEXT_FONT;
            [dateBtn addTarget:self action:@selector(selectData:) forControlEvents:UIControlEventTouchUpInside];
            NSDictionary *dateDic = [self.bespeakDayArray objectAtIndex:i];
            NSString *dateStr = (NSString*)[dateDic objectForKey:@"date"];
            NSArray *dateArray = [dateStr componentsSeparatedByString:@"-"];
            if (dateArray.count == 3) {
                NSString *btnTitle = [NSString stringWithFormat:@"%@/%@", [dateArray objectAtIndex:1], [dateArray objectAtIndex:2]];
                [dateBtn setTitle:btnTitle forState:UIControlStateNormal];
            }
            [dateSelView addSubview:dateBtn];
            
            if (i == 0) {
                dateBtn.backgroundColor = RGBA(177, 113, 169, 255);
            }
        }
        
        //时间列表
        for(int i = 0; i < self.bespeakDayArray.count; i++){
            UIView *timeSelView = [[UIView alloc] initWithFrame:CGRectMake(0.0, dateSelView.frame.size.height + dateSelView.frame.origin.y + 1, view.frame.size.width, 204)];
            [timeSelView setTag:TAG_TIMEVIEW + i];
            [view addSubview:timeSelView];
            if (i > 0) {
                timeSelView.hidden = YES;
            }
            NSDictionary *dateDic = [self.bespeakDayArray objectAtIndex:i];
            NSArray *timeArray = (NSArray*)[dateDic objectForKey:@"freelist"];
            NSInteger timeCount = timeArray.count;
            float item_w = (dateSelView.frame.size.width - 4)/count;
            float item_h = 40;
            for (int j = 0; j < timeCount; j++) {
                UIButton *timeBtn = [[UIButton alloc] initWithFrame:CGRectMake(j % count * (item_w + 1), j/count * (item_h + 1), item_w, item_h)];
                [timeBtn setTitle:[timeArray objectAtIndex:j] forState:UIControlStateNormal];
                [timeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                timeBtn.backgroundColor = [UIColor tableViewBackgroundColor];
                timeBtn.titleLabel.font = BUTTON_TEXT_FONT;
                [timeBtn setTag:TAG_TIME_ITEM + j];
                [timeBtn addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
                [timeSelView addSubview:timeBtn];
                if (i == 0 && j == 0) {
                    timeBtn.backgroundColor = RGBA(177, 113, 169, 255);
                }
            }
        }
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, topView.frame.size.height, self.frame.size.width - 40, 60)];
        [view addSubview:label];
        label.font = LABEL_DEFAULT_TEXT_FONT;
        label.textColor = LABEL_DEFAULT_TEXT_COLOR;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"改养生顾问时间都已被预约，请选择其他养生顾问，谢谢。";
    }
}



-(void)hideBespeakSelectView {
    [self removeFromSuperview];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableView"]) {
//        return NO;
//    }
    if (touch.view != self) {
        return NO;
    }
    return  YES;
}

@end
