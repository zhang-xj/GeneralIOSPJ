//
//  QHCQinghuaBeatDetailViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHCProjectDetailViewController : UIViewController{
    NSDictionary *bundleDataDic;
}
@property (nonatomic, retain)NSDictionary *bundleDataDic;

- (id)initWithData:(NSDictionary*)dataDic;
@end
