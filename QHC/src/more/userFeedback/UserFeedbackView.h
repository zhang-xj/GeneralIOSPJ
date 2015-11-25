//
//  UserFeedbackView.h
//  QHC
//
//  Created by qhc2015 on 15/7/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"

@interface UserFeedbackView : UIView<UITextViewDelegate>{
    UITextView *feedback;
    
    HttpRequestManage *httpRequest;
    
    NSString *feedbackType;
}

@property (nonatomic, retain)     UITextView *feedback;

@property (nonatomic, copy)NSString *feedbackType;

@property (nonatomic, retain)HttpRequestManage *httpRequest;
@end
