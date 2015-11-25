//
//  QHCBespeakDetailViewController.h
//  QHC
//
//  Created by qhc2015 on 15/6/30.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHCBespeakDetailViewController : UIViewController{
    NSDictionary            *detailDataDic;
}

@property (nonatomic, retain) NSDictionary *detailDataDic;

- (id)initWithData:(NSDictionary*)dataDic;

@end
