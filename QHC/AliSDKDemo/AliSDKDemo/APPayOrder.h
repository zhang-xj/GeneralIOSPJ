//
//  APViewController.h
//  AliSDKDemo
//
//  Created by 方彬 on 11/29/13.
//  Copyright (c) 2013 Alipay.com. All rights reserved.
//

#import <UIKit/UIKit.h>

//
//测试商品信息封装在Product中,外部商户可以根据自己商品实际情况定义
//
@protocol  APPPayOrderDelegate<NSObject>
@optional
-(void)payResponse:(NSDictionary*)payResult;
@end


@interface Product : NSObject{
@private
	float     _price;
	NSString *pdName;
	NSString *body;
	NSString *productID;
}

@property (nonatomic, assign) float price;
@property (nonatomic, copy) NSString *pdName;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *productID;

@end

@interface APPayOrder : NSObject

@property (nonatomic, assign)   id <APPPayOrderDelegate>  delegate;

-(void)payWithProductInfo:(NSDictionary*)productInfoDic;

@end
