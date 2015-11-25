//
//  WXPay.m
//  QHC
//
//  Created by qhc2015 on 15/7/27.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "WXPay.h"
#import "MyAlerView.h"
#import<CommonCrypto/CommonDigest.h>

//获取服务器端支付数据地址（商户自定义）
#define SP_URL          @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php"

@implementation WXPay

//============================================================
// V3&V4支付流程实现
// 注意:参数配置请查看服务器端Demo
// 更新时间：2015年3月3日
// 负责人：李启波（marcyli）
//============================================================
- (void)sendPay:(NSDictionary*)dict
{
    if(dict != nil){
        NSMutableString *retcode = [dict objectForKey:@"status"];
        if (retcode.intValue == 1){
            NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
            
            //调起微信支付
            PayReq* req             = [[PayReq alloc] init];
            req.openID              = [dict objectForKey:@"appid"];//appID
            req.partnerId           = [dict objectForKey:@"partnerid"];//微信支付分配的商户号
            req.prepayId            = [dict objectForKey:@"prepayid"];//微信返回的支付交易会话ID
            req.nonceStr            = [dict objectForKey:@"noncestr"];//随机字符串，不长于32位。推荐
            req.timeStamp           = stamp.intValue;//时间戳
            req.package             = [dict objectForKey:@"package"];//暂填写固定值Sign=WXPay
            
            NSString *paramStr = [NSString stringWithFormat:@"appid=%@&noncestr=%@&package=%@&partnerid=%@&prepayid=%@&timestamp=%u&key=%@", req.openID, req.nonceStr, req.package, req.partnerId, req.prepayId, (unsigned int)req.timeStamp, [dict objectForKey:@"key"]];
            NSLog(@"need sign paramStr = %@", paramStr);
            NSString *sign = [self md5HexDigest:paramStr];
            NSLog(@"sign = %@", sign);
            
            req.sign                = sign;  //签名
            [WXApi sendReq:req];
            //日志输出
            NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
        }else{
            
            [[MyAlerView sharedAler] ViewShow:[dict objectForKey:@"retmsg"]];
        }
    }else{
        [[MyAlerView sharedAler] ViewShow:@"服务器返回错误，未获取到json对象"];
    }
}


- (NSString *)md5HexDigest:(NSString *)url
{
    const char *original_str = [url UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
//    return [hash lowercaseString];
    return [hash uppercaseString];
}
@end
