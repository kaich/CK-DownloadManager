//
//  ASIHTTPRequest+Download.m
//  chengkai
//
//  Created by mac on 15/1/7.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "AFDownloadRequestOperation+Download.h"
#import "CKDownloadPathManager.h"
#import <objc/runtime.h>


#ifndef ORIGIN_URL
#define  ORIGIN_URL(_request_) _request_.originalURL ?  _request_.originalURL : _request_.url
#endif

static NSString * HTTPRequestDelegate ;

@implementation AFDownloadRequestOperation (Download)

+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url
{
    NSString * toPath=nil;
    NSString * tmpPath=nil;
    [CKDownloadPathManager SetURL:url toPath:&toPath tempPath:&tmpPath];
    

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = INT_MAX;
    AFDownloadRequestOperation * requestOperation=[[AFDownloadRequestOperation alloc]initWithRequest:request targetPath:toPath shouldResume:YES];
    
    __weak typeof (AFDownloadRequestOperation *) weakRequestOperation = requestOperation;
    
    [requestOperation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        if(operation.response)
        {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [weakRequestOperation.ck_delegate ck_request:weakRequestOperation didReceiveResponseHeaders:nil];
            });
            
            static dispatch_once_t SecondeToken;
            dispatch_once(&SecondeToken, ^{
                [weakRequestOperation.ck_delegate ck_requestStarted:weakRequestOperation];
            });
        }
        
        [weakRequestOperation.ck_delegate ck_request:weakRequestOperation didReceiveBytes:bytesRead];
    }];
    
   [requestOperation setCompletionBlockWithSuccess:^ void(AFHTTPRequestOperation * operation, id responseObject) {
      [weakRequestOperation.ck_delegate ck_requestFinished:weakRequestOperation];
   } failure:^ void(AFHTTPRequestOperation * operation, NSError * error) {
      [weakRequestOperation.ck_delegate ck_requestFailed:weakRequestOperation];
   }];
    
    
    return requestOperation;
}

-(void) ck_setShouldContinueWhenAppEntersBackground:(BOOL)isNeed
{
    
}


-(void) ck_clearDelegatesAndCancel
{
    [self cancel];
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
    return self.request.URL;
}

-(long long) ck_contentLength
{
    return self.response.expectedContentLength;
}

-(long long) ck_downloadBytes
{
    return self.offsetContentLength;
}

-(long long) ck_totalContentLength
{
    return self.totalContentLength;
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
