//
//  CZNewFeatureCell.h
//  
//
//  Created by apple on 15-3-7.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZNewFeatureCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger backType;


// 判断是否是最后一页
- (void)setIndexPath:(NSIndexPath *)indexPath count:(int)count;
@end
