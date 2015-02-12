//
//  ASIHTTPRequest+Download.m
//  aisiweb
//
//  Created by mac on 15/1/7.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import "ASIHTTPRequest+Download.h"
#import "CKDownloadPathManager.h"
#import <objc/runtime.h>


#ifndef ORIGIN_URL
#define  ORIGIN_URL(_request_) _request_.originalURL ?  _request_.originalURL : _request_.url
#endif

static NSString * HTTPRequestDelegate ;

@implementation ASIHTTPRequest (Download)

+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url
{
    NSString * toPath=nil;
    NSString * tmpPath=nil;
    [CKDownloadPathManager SetURL:url toPath:&toPath tempPath:&tmpPath];
    

    ASIHTTPRequest * request=[ASIHTTPRequest requestWithURL:url];
    request.downloadDestinationPath=toPath;
    request.temporaryFileDownloadPath=tmpPath;
    request.allowResumeForFileDownloads=YES;
    request.showAccurateProgress=YES;
    request.shouldContinueWhenAppEntersBackground=YES;
    request.numberOfTimesToRetryOnTimeout=INT_MAX;
    
    __weak typeof (ASIHTTPRequest *) weakRequest = request;
    
    [request setStartedBlock:^{
        [weakRequest.ck_delegate ck_requestStarted:weakRequest];
    }];
    
    [request setFailedBlock:^{
        [weakRequest.ck_delegate ck_requestFailed:weakRequest];
    }];
    
    [request setCompletionBlock:^{
        [weakRequest.ck_delegate ck_requestFinished:weakRequest];
    }];
    
    [request setHeadersReceivedBlock:^(NSDictionary *responseHeaders) {
        [weakRequest.ck_delegate ck_request:weakRequest didReceiveResponseHeaders:responseHeaders];
    }];
    
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        [weakRequest.ck_delegate ck_request:weakRequest didReceiveBytes:size];
    }];
    
    return request;
}

-(void) ck_setShouldContinueWhenAppEntersBackground:(BOOL)isNeed
{
    [self setShouldContinueWhenAppEntersBackground:isNeed];
}


-(void) ck_clearDelegatesAndCancel
{
    [self clearDelegatesAndCancel];
}

-(void) ck_addDependency:(id) denpendRequest
{
    [self addDependency:denpendRequest];
}

#pragma mark - dynamic method

-(id<CKHTTPRequestDelegate>) ck_delegate
{
    return objc_getAssociatedObject(self, &HTTPRequestDelegate);
}

-(void) setCk_delegate:(id<CKHTTPRequestDelegate>)ck_delegate
{
    objc_setAssociatedObject(self, &HTTPRequestDelegate, ck_delegate, OBJC_ASSOCIATION_RETAIN);
}

-(NSURL *) ck_url
{
    return ORIGIN_URL(self);
}

-(long long) ck_contentLength
{
    return self.contentLength;
}

-(long long) ck_downloadBytes
{
    return self.partialDownloadSize + self.totalBytesRead;
}

-(long long) ck_totalContentLength
{
    return self.partialDownloadSize + self.contentLength;
}

-(CKHTTPRequestStatus) ck_status
{
    CKHTTPRequestStatus status = kRSReady;
    
    if (self.isCancelled) {
        status= kRSCanceled;
    }
    else if(self.isFinished)
    {
        status= kRSFinished;
    }
    else if(self.isExecuting)
    {
        status= kRSExcuting;
    }
    else if(self.isReady)
    {
        status= kRSReady;
    }
    
    return status;
}



@end
