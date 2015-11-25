//
//  QHBeatDetailProjectViewController.h
//  QHC
//
//  Created by qhc2015 on 15/7/27.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHBeatDetailProjectViewController : UIViewController{
    NSDictionary *bundleDataDic;
}
@property (nonatomic, retain)NSDictionary *bundleDataDic;

- (id)initWithData:(NSDictionary*)dataDic;
@end
