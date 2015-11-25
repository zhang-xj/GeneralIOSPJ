//
//  MyAlerView.m
//  LearnEnglish
//
//  Created by zhixu jia on 12-3-31.
//  Copyright (c) 2012年 xuling. All rights reserved.
//

#import "MyAlerView.h"
#import <QuartzCore/QuartzCore.h>
#import "ModalAnimationHelper.h"
#import "AppDelegate.h"

@interface MyAlerView(PrivateMethods)
- (void) setHight:(NSString *)info;
- (void) animate;
- (void) ViewHide;
@end

#define MyAlerViewTag 1234

@implementation MyAlerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin];
        self.alpha = 0.0f;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImage:[[UIImage imageNamed:@"aler"] stretchableImageWithLeftCapWidth:50.0 topCapHeight:50.0]];
        imageView.tag = 102;
        imageView.alpha = 0.95f;
        [self addSubview:imageView];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin];
        
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
        NSLineBreakMode LBM = NSLineBreakByWordWrapping;
    #else
        UILineBreakMode LBM = UILineBreakModeWordWrap;
    #endif
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        [label setLineBreakMode:LBM];
        [label setMinimumFontSize:14];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setNumberOfLines:0];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 101;
        
        [self addSubview:label];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin];
    }
    return self;
}

+ (id) sharedAler
{/*
    UIView *view = nil;
    NSArray *aarwin = [[UIApplication sharedApplication] windows];
    for (int k=0; k<[aarwin count]; k++)
    {
        UIWindow *window = [aarwin objectAtIndex:k];//[[UIApplication sharedApplication] keyWindow];
        view = [window viewWithTag:MyAlerViewTag];
        if (view)
            break;
    }
    return view;
    */
    
    ///-----------------方法2-----
    //[[UIApplication sharedApplication] keyWindow属性获取当前程序关键窗口
    //[[UIApplication sharedApplication] windows属性获取当前程序涉及到窗口类数组
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MyAlerView *view = (MyAlerView *)[window.rootViewController.view  viewWithTag:MyAlerViewTag];
    if (!view)
    {
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        if(UI_USER_INTERFACE_IDIOM())
        {
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
                
                if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
                {
                    width = frame.size.height;
                    height = frame.size.width;
                }
            }
        }
        view =  [[MyAlerView alloc]initWithFrame:CGRectMake(5, (height - 80)/2, width-10, 80)];
        view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
        view.tag = MyAlerViewTag;
        
        [window.rootViewController.view addSubview:view];
        
        return view;
    }
    else
    {
        return view;
    }
    //////////////////////
}

- (NSString *) netError:(NSString *)ResponseInfo
{
    NSString *errMsg = @"";
    //检查消息是否包含错误前缀
    //Authentication needed
    if([ResponseInfo isEqualToString:@"Authentication needed"]) {
        errMsg = NSLocalizedStringFromTable(@"alermsg_eg30", @"InfoPlist", nil);
    }
    //The request timed out
    if([ResponseInfo isEqualToString:@"The request timed out"]) {
        errMsg = NSLocalizedStringFromTable(@"alermsg_eg31", @"InfoPlist", nil)/*@"无法连接服务器，请稍后再试"*/;
    }
    //The request was cancelled
    if([ResponseInfo isEqualToString:@"The request was cancelled"]) {
        errMsg = @"请求被撤销";
    }
    //Unable to create request (bad url?)
    if([ResponseInfo isEqualToString:@"Unable to create request (bad url?)"]) {
        errMsg = @"无法创建请求，错误的URL地址";
    }
    //The request failed because it redirected too many times
    if([ResponseInfo isEqualToString:@"The request failed because it redirected too many times"]) {
        errMsg = @"请求失败，可能是因为被重定向次数过多";
    }
    //A connection failure occurred
    if([ResponseInfo isEqualToString:@"A connection failure occurred"]) {
        errMsg = NSLocalizedStringFromTable(@"alermsg_eg32", @"InfoPlist", nil)/*@"请检测本地网络连接是否畅通"*/;
    }
    
    if (![errMsg isEqualToString:@""])
    {
        return errMsg;
    }
    else
    {
        return ResponseInfo;
    }
}

- (void) setHight:(NSString *)info
{
    int width = 250;
    int height = 100;
    info = [self netError:info];
    
    CGSize retSize = [AppDelegate getStringInLabelSize:info andFont:[UIFont systemFontOfSize:14] andLabelWidth:width-20];
    retSize.height += 3;
    
    [((UILabel *)[self viewWithTag:101]) setText:info];
    [((UILabel *)[self viewWithTag:101]) setFrame: CGRectMake(10, 0, width-20, MAX(retSize.height, height))];
    
    [((UIImageView *)[self viewWithTag:102]) setFrame: CGRectMake(0, 0, width, MAX(retSize.height, height))];
    
    [((UILabel *)[self viewWithTag:101]) setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [((UIImageView *)[self viewWithTag:102]) setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
}

- (void) ViewHide
{
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelay:_delay];
    [UIView setAnimationDuration:0.7f];
    
    self.alpha = 0.0f;
    
    [UIView commitAnimations];
}

- (void) ViewShow:(NSString *)info
{
    if (info && ![info isEqualToString:@""])
    {
        if ([info hasPrefix:@"@"])
        {
            UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"提示" message:[info substringFromIndex:1] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [aler show];
            return ;
        }
        
        if (self.alpha == 0.0f)
        {
            [self setHight: info];
            
            _delay = (float)([info length] * 130 + 200)/1000;
            //NSLog(@"%f", _delay);
            
            [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.7f];
            
            self.alpha = 1.0f;
            
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(ViewHide)];
            [UIView commitAnimations];
            
            //[self performSelector:@selector(ViewHide) withObject:nil afterDelay:2.2];
        }
        else
        {
            //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ViewHide) object:nil];
            [[self layer] removeAllAnimations];
            
            self.alpha = 0.0f;
            
            [self ViewShow:info];
        }
    }
}

- (void) animate
{
    self.alpha = 1.0f;
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4f];
    
    self.transform = CGAffineTransformMakeScale(1.15f, 1.15f);
    [UIView commitModalAnimations];
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3f];
    
    self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    [UIView commitModalAnimations];
    
    //pause for a second and appreciate the presentation
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0f];
    
    self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    [UIView commitModalAnimations];
    
    self.alpha = 0.0f;
}

@end