//
//  LoginView.h
//  QHC
//
//  Created by qhc2015 on 15/6/10.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"

@protocol  LoginDelegate<NSObject>
@optional
-(void)loginSuccess:(UIView*)loginView;
@end

@interface LoginView : UIView<UITextFieldDelegate>{
    HttpRequestManage       *httpRequest;
    
    UITextField     *accountField;
    UITextField     *passwordField;
    UITextField     *checkCodeField;
    
    UIButton *getCheckCodeBtn;
    NSTimer                 *timer;
}

@property (nonatomic, assign)   id <LoginDelegate>  delegate;

@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, retain)UITextField *accountField;
@property (nonatomic, retain)UITextField *passwordField;
@property (nonatomic, retain)UITextField *checkCodeField;

@property (nonatomic, retain)UIButton *getCheckCodeBtn;
@property (nonatomic, retain)NSTimer                 *timer;

+ (LoginView*)sharedLoginView:(CGRect)frame;

-(void)createLoginView;
@end
