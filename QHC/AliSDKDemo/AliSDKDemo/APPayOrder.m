//
//  APViewController.m
//  AliSDKDemo
//
//  Created by 方彬 on 11/29/13.
//  Copyright (c) 2013 Alipay.com. All rights reserved.
//

#import "APPayOrder.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#import "APAuthV2Info.h"

@implementation Product

@synthesize pdName;
@synthesize body;
@synthesize productID;

@end

@implementation APPayOrder

#pragma mark -
#pragma mark   ==============产生随机订单号==============

- (NSString *)generateTradeNO
{
	static int kNumber = 15;
	
	NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSMutableString *resultStr = [[NSMutableString alloc] init];
	srand(time(0));
	for (int i = 0; i < kNumber; i++)
	{
		unsigned index = rand() % [sourceStr length];
		NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
		[resultStr appendString:oneStr];
	}
	return resultStr;
}


#pragma mark -
#pragma mark   ==============点击订单模拟支付行为==============
//
//选中商品调用支付宝极简支付
//
-(void)payWithProductInfo:(NSDictionary*)productInfoDic
{

	/*
	 *获取prodcut实例并初始化订单信息
	 */
    Product *product = [[Product alloc] init];
    if ([productInfoDic objectForKey:@"projectname"]) {
        product.pdName = [productInfoDic objectForKey:@"projectname"];
    } else {
        product.pdName = @"批量支付";
    }
    if ([productInfoDic objectForKey:@"projectid"]) {
        product.productID = [productInfoDic objectForKey:@"projectid"];
    } else {
        product.productID = [productInfoDic objectForKey:@"orderid"];
    }
    if ([productInfoDic objectForKey:@"body"]) {
        product.body = [productInfoDic objectForKey:@"body"];
    } else {
        product.body = product.pdName;
    }
    
//    product.price = [((NSString*)[productInfoDic objectForKey:@"realpay"]) floatValue];
    product.price = 0.01;

	/*
	 *商户的唯一的parnter和seller。
	 *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
	 */
    
/*============================================================================*/
/*=======================需要填写商户app申请的===================================*/
/*============================================================================*/
	NSString *partner = @"2088911513862275";
    NSString *seller = @"O2O@qinghuacichina.com";
//    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMt/1aUv7wJZ+cjjmoKiCRM6TGpIwjhwnw3854ZAMs6OFPBnMtHChk2xFdbf8MKwBRCjY3y2WZ1DezkhyYHr9+9yx/3nOTtoSv9dUV5EZ9Fs1ubIXNGzSli13T+oSvMoxb66H1+Ylipy8k73nNlPfvCX/z0KX0DCM48RIB2kg9PjAgMBAAECgYBLgcJHCZMYf0QkWvdQs0jEvqPt59NQ19DcgtNxR87SP3vbe58qn4/vsd5VnUAbLO6kLsvSUWLM7GYDW9sF/wU+RRULNAnPejckku1X0kMdsJWn+skDkvDclWDwITf2l/jezKinEZI+gAug2NU+LZh1GCOI/bnPsGjLqULYE5jk2QJBAOuEoOlFuPEZwIm8KGkU+fE/+Lr/Cw7bBZZ9BZr9oZ9bJvDW1K02s7JZIeOEFNXkQUSALVmKgh0Jti6gZDHf8xcCQQDdMl5heqhgETOac0sFehFwwMVumXQFpx2TmxTQa3tqk3wNC3xAibtDVDNGP9XY5283nNJNLcBWeZfYNUez7BUVAkBTkhljDQmGDARFG44fU4EpOPDyscNjvxYpgy11BODP4hFcTm7jE9EJzRT4XYrjJv595xmwdzSaRzLtMp67D+N7AkA3jgr+WJwpZKidRg+1lG8E7qWnnYryUIKxK+YSYqxgnCIv9I6EdxM9Wcx2/FltXNMmGJEJKVCBZ5CnkNotakHxAkEAwLLORCrKxsGFVIs/nhBAJ2KR3YOt1fITLeZBHUcQR+n9FZCEl+qkG8KD8vnAkSMn74CrRGbMKdxnd9XGaceqeQ==";
    NSString *privateKey =[productInfoDic objectForKey:@"alipaykey"];
/*============================================================================*/
/*============================================================================*/
/*============================================================================*/
	
	//partner和seller获取失败,提示
	if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"缺少partner或者seller或者私钥。"
													   delegate:self
											  cancelButtonTitle:@"确定"
											  otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	/*
	 *生成订单信息及签名
	 */
	//将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
	order.partner = partner;
	order.seller = seller;
//	order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.tradeNO = [productInfoDic objectForKey:@"orderid"];//订单ID（由商家自行制定）
	order.productName = product.pdName; //商品标题
	order.productDescription = product.body; //商品描述
	order.amount = [NSString stringWithFormat:@"%.2f",product.price]; //商品价格
    order.notifyURL = [productInfoDic objectForKey:@"alipaycallback"];// @"http://182.254.140.231/pay/AlipayCallback.aspx"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
	
	//应用注册scheme,在AlixPayDemo-Info.plist定义URL types
	NSString *appScheme = @"alisdkdemo";
	
	//将商品信息拼接成字符串
	NSString *orderSpec = [order description];
	NSLog(@"orderSpec = %@",orderSpec);
	
	//获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
	id<DataSigner> signer = CreateRSADataSigner(privateKey);
	NSString *signedString = [signer signString:orderSpec];
	
	//将签名成功字符串格式化为订单字符串,请严格按照该格式
	NSString *orderString = nil;
	if (signedString != nil) {
		orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            if (self.delegate) {
                [self.delegate payResponse:resultDic];
            }
        }];
    }
}
@end
