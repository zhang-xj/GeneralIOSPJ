
//
//  HttpRequestManage.m
//  SuperMemory
//
//  Created by zhangxiongjie on 14-12-22.
//  Copyright (c) 2014年 zhangxiongjie. All rights reserved.
//

#import "HttpRequestManage.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "MyAlerView.h"

@implementation HttpRequestManage

@synthesize delegate;

@synthesize httpRequest;
@synthesize requestFinishCallBack;
@synthesize requestFailCallBack;

-(id)initWithUrlStr:(NSString*)urlStr
{
    self = [super init];
    if (self) {
        urlStr = [NSString stringWithFormat:@"%@%@", BASE_URL, urlStr];
        if ([urlStr rangeOfString:@"192"].location != NSNotFound) {
            [[MyAlerView sharedAler] ViewShow:@"这是内网包"];
        }
        NSURL *url = [NSURL URLWithString:urlStr];
        self.httpRequest = [ASIFormDataRequest requestWithURL:url];
    }
    return self;
}

-(void) sendHttpRequestByGet:(NSString*)urlStr
{
    
}

-(void) sendHttpRequestByPost:(NSString*)urlStr params:(NSDictionary*)param
{
    NSLog(@"url = %@", self.httpRequest.url);
    [self.httpRequest setPostValue:@"3F5AA57F-B718-4056-8963-5F44D178F4A4" forKey:@"p"];
    [self.httpRequest setPostValue:[[UIDevice currentDevice].identifierForVendor UUIDString] forKey:@"identifie"];
    //    identifierForVendor对供应商来说是唯一的一个值，也就是说，由同一个公司发行的的app在相同的设备上运行的时候都会有这个相同的标识符。然而，如果用户删除了这个供应商的app然后再重新安装的话，这个标识符就会不一致。
    //    advertisingIdentifier会返回给在这个设备上所有软件供应商相同的 一个值，所以只能在广告的时候使用。这个值会因为很多情况而有所变化，比如说用户初始化设备的时候便会改变。
    if (param) {
        NSArray *keys = [param allKeys];
        id key, value;
        for (int i = 0; i < [keys count]; i++) {
            key = [keys objectAtIndex:i];
            value = [param objectForKey:key];
            NSLog(@"param: %@ = %@", key, value);
            [self.httpRequest setPostValue:value forKey:key];
        }
    }
    
    //设置代理
    self.httpRequest.delegate = self;
    //设置网络请求的延时为10秒
    self.httpRequest.timeOutSeconds = 10;
    //发送异步请求
    [self.httpRequest startAsynchronous];
}

#pragma mark-ASIHTTPRequestDelegate 异步请求的代理方法
//请求结束的时候调用（在该方法中拿到最终的数据）
-(void)requestFinished:(ASIHTTPRequest *)request
{
    //request.responseData:服务器返回的所有数据，这个data已经拼接了接收到的所有数据
    NSLog(@"responseString ＝ %@", [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding]);
    
    NSDictionary *jsonDic = [[request responseData] objectFromJSONData];
    if (jsonDic) {
        if (self.delegate && self.requestFinishCallBack && [self.delegate respondsToSelector:self.requestFinishCallBack]) {
            [self.delegate performSelector:self.requestFinishCallBack withObject:request.responseData];
        }
    } else {
        NSLog(@"HTTP request responseData not a json data");
        if (self.delegate && self.requestFailCallBack && [self.delegate respondsToSelector:self.requestFailCallBack]) {
            [self.delegate performSelector:self.requestFailCallBack withObject:request.error];
        }
    }
}
//发送网络请求失败的时候调用
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"HTTP request fail responseCode = %i, error msg = %@", request.responseStatusCode, request.error);
    if (self.delegate && self.requestFailCallBack && [self.delegate respondsToSelector:self.requestFailCallBack]) {
        [self.delegate performSelector:self.requestFailCallBack withObject:request.error];
    }
}
@end
