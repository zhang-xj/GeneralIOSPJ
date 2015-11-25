//
//  CheckBox.h
//  QHC
//
//  Created by qhc2015 on 15/7/10.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckBox : UIButton {
    NSInteger checkedIndex;
    BOOL isChecked;
}
@property (nonatomic, assign) NSInteger checkedIndex;
@property (assign)BOOL isChecked;
@end
