//
//  ModalAnimationHelper.m
//  iPhoneWorld
//
//  Created by zhixu jia on 12-3-21.
//  Copyright (c) 2012年 xuling. All rights reserved.
//

#import "ModalAnimationHelper.h"

@implementation UIviewDelegate

- (id) initWithRunLoop:(CFRunLoopRef)runLoop
{
    if (self = [super init])
    {
        currentLoop = runLoop;
    }
    return self;
}

- (void) animationFinished:(id) sender
{
    CFRunLoopStop(currentLoop);
}

@end

@implementation UIView (ModalModalAnimationHelper)

+ (void) commitModalAnimations
{
    CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
    
    UIviewDelegate *uiDelegate = [[UIviewDelegate alloc] initWithRunLoop:currentLoop];
    
    [UIView setAnimationDelegate:uiDelegate];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:)];
    [UIView commitAnimations];
    
    CFRunLoopRun();
    
    [uiDelegate release];
}

@end

