//
//  ModalAnimationHelper.h
//  iPhoneWorld
//
//  Created by zhixu jia on 12-3-21.
//  Copyright (c) 2012年 xuling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIviewDelegate : NSObject
{
    CFRunLoopRef currentLoop;
}
@end

@interface UIView (ModalModalAnimationHelper)
+ (void) commitModalAnimations;
@end
