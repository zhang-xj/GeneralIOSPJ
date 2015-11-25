//
//  PersonalInfoView.h
//  QHC
//
//  Created by qhc2015 on 15/7/3.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequestManage.h"

@interface PersonalInfoView : UIView <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
    UIImageView *headImg;
    UITextField *nickNameField;
    
    HttpRequestManage *httpRequest;
    
    BOOL updateImage;
    
    UIImagePickerController *imagePickerController;
    
}
@property (nonatomic, retain)    UIImageView *headImg;
@property (nonatomic, retain)UITextField *nickNameField;

@property (nonatomic, retain)HttpRequestManage *httpRequest;

@property (nonatomic, retain)        UIImagePickerController *imagePickerController;

-(void)commit;

@end
