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
#import "AFNetworking/AFNetworking.h"


#ifndef ORIGIN_URL
#define  ORIGIN_URL(_request_) _request_.originalURL ?  _request_.originalURL : _request_.url
#endif

static NSString * HTTPRequestDelegate ;
static NSString * TotalBytesReadForFile;

@interface AFHTTPRequestOperation ()
@property(nonatomic,assign) long long ck_downloadBytes;
@end

@implementation AFHTTPRequestOperation (Download)

+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url
{
    NSString * toPath=nil;
    NSString * tmpPath=nil;
    [[CKDownloadPathManager sharedInstance] SetURL:url toPath:&toPath tempPath:&tmpPath];
    

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = INT_MAX;
    AFDownloadRequestOperation * requestOperation=[[AFDownloadRequestOperation alloc]initWithRequest:request targetPath:toPath shouldResume:YES];
    
    __weak typeof (AFDownloadRequestOperation *) weakRequestOperation = requestOperation;
    
    __block BOOL startFinished = NO;
    __block BOOL headerReceived = NO;
    __block NSTimeInterval lastTime = 0;
    [requestOperation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        if(operation.response)
        {
            
            if(!startFinished)
            {
                [weakRequestOperation.ck_delegate ck_requestStarted:weakRequestOperation];
                startFinished = YES;
            }
            
            if(!headerReceived)
            {
                [weakRequestOperation.ck_delegate ck_request:weakRequestOperation didReceiveResponseHeaders:nil];
                headerReceived = YES;
            }
            
        }
       
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        if(lastTime == 0 || currentTime - lastTime >=1)
        {
            weakRequestOperation.ck_downloadBytes = totalBytesReadForFile;
            lastTime = currentTime;
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


+(instancetype) ck_createHeadRequestWithURL:(NSURL *) url
{
    AFHTTPRequestOperation * request = [self HTTPRequestOperationWithHTTPMethod:@"HEAD" URLString:url.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [operation.ck_delegate ck_requestStarted:operation];
        [operation.ck_delegate ck_request:operation didReceiveResponseHeaders:nil];
        [operation.ck_delegate ck_requestFinished:operation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [operation.ck_delegate ck_requestFailed:operation];
    }];
    return request;
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

+ (BOOL) ck_isVisibleTempPath;
{
    return YES;
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
    return [objc_getAssociatedObject(self, &TotalBytesReadForFile) longLongValue];
}

-(void) setCk_downloadBytes:(long long)ck_downloadBytes
{
    objc_setAssociatedObject(self, &TotalBytesReadForFile, @(ck_downloadBytes), OBJC_ASSOCIATION_RETAIN);
}

-(long long) ck_totalContentLength
{
    return self.ck_downloadBytes + self.ck_contentLength;
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

#pragma mark - private method

+ (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
            failure(nil, serializationError);
        }
        
        return nil;
    }
    
    return [self HTTPRequestOperationWithRequest:request success:success failure:failure];
}

+ (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    
    return operation;
}

@end


@implementation AFDownloadRequestOperation (Download)

#pragma mark - override

-(long long) ck_totalContentLength
{
    return self.totalContentLength;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSString *)tempPath {
    NSString * toPath=nil;
    NSString * tmpPath=nil;
    [[CKDownloadPathManager sharedInstance] SetURL:self.ck_url toPath:&toPath tempPath:&tmpPath];
    return tmpPath;
}
#pragma clang diagnostic pop

@end
