//
//  ShareXmlParser.m
//  aisiweb
//
//  Created by Alan on 14-3-19.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "ShareXmlParser.h"
@interface ShareXmlParser()
{
    NSMutableData *_recivedData;
}
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ShareXmlParser

- (void)startRequestWithUrl:(NSString *)urlStr
{
//    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
//    
//    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
//    request.timeOutSeconds = 60.0;
//    request.delegate = self;
//    [request startAsynchronous];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:50];
   
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark- NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _recivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_recivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    MainXmlOperation *parser = [[MainXmlOperation alloc] initWithData:_recivedData];
    MainXmlOperation *weakParser = parser;
    
    _queue = [[NSOperationQueue alloc] init];
    [_queue addOperation:parser];
    
    parser.completionBlock = ^(void) {
        if (weakParser.appRecordList) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.SuccessHandler) {
                    self.SuccessHandler(weakParser.appRecordList,weakParser.appRecordList);
                }
            });
        }
        _queue = nil;
    };

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (error) {
        if(self.failHandler)
            self.failHandler(error);
    }
}


//ASI请求下拉很快结束。。看不到过程 。。

#if 0
#pragma mark ASIHttpRequstDelegate
-(void)requestFinished:(ASIHTTPRequest *)request{
    MainXmlOperation *parser = [[MainXmlOperation alloc] initWithData:[request responseData]];
    MainXmlOperation *weakParser = parser;
    
    _queue = [[NSOperationQueue alloc] init];
    [_queue addOperation:parser];
    
    parser.completionBlock = ^(void) {
        if (weakParser.appRecordList) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.SuccessHandler) {
                        self.SuccessHandler(weakParser.ADRecordList,weakParser.appRecordList);
                    }
                });
        }
        _queue = nil;
    };
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    if ([request error]) {
        if(self.failHandler)
            self.failHandler([request error]);
    }
}
#endif
@end

