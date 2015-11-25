//
//  HttpRequestManage.h
//  SuperMemory
//
//  Created by zhangxiongjie on 14-12-22.
//  Copyright (c) 2014年 zhangxiongjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@interface HttpRequestManage : NSObject <ASIHTTPRequestDelegate>
{
    __unsafe_unretained id          delegate;
    
    ASIFormDataRequest              *httpRequest;
    SEL                             requestFinishCallBack;
    SEL                             requestFailCallBack;
}

@property (nonatomic, assign)id delegate;

@property (nonatomic, retain)ASIFormDataRequest *httpRequest;
@property (assign) SEL requestFinishCallBack;
@property (assign) SEL requestFailCallBack;

-(id)initWithUrlStr:(NSString*)urlStr;

-(void) sendHttpRequestByGet:(NSString*)urlStr;
-(void) sendHttpRequestByPost:(NSString*)urlStr params:(NSDictionary*)param;

@end
