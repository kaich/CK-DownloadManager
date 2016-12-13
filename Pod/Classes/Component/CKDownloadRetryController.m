//
//  CKDownloadRetryController.m
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "CKDownloadRetryController.h"
#import "CKDownloadManager+MoveDownAndRetry.h"


@interface CKDownloadRetryController ()<CKHTTPRequestDelegate>
{
    id<CKHTTPRequestQueueProtocol> _retryQueue;
    CKRetryBaseBlock _getHeadLengthPassedBlock;
    CKRetryBaseBlock _getHeadLengthFailureBlock;
}

@end


@implementation CKDownloadRetryController

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        self.retryMaxCount = 10;
        self.headLengthRetryMaxCount = 3;
        _resumCount=0;
    }
    return  self;
}

-(void) makeTaskAutoResum:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model
{
    if(model.downloadState == kDSWaitDownload || model.downloadState == kDSDownloading)
    {
        if(model.isNeedResumWhenNetWorkReachable==NO)
        {
            model.isNeedResumWhenNetWorkReachable=YES;
            _resumCount ++;
        }
    }
}

-(void) cancelTaskAutoResum:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model
{
    if(model.isNeedResumWhenNetWorkReachable==YES)
    {
         model.isNeedResumWhenNetWorkReachable=NO;
        _resumCount --;
    }
}

-(BOOL) isAutoResumWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model
{
    return model.isNeedResumWhenNetWorkReachable;
}

-(NSInteger) resumCount
{
    return _resumCount;
}

#pragma mark  - retry

-(void) resetRetryCountWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model
{
    model.retryCount = 0;
}


-(void) retryWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model request:(id<CKHTTPRequestProtocol>) request passed:(CKRetryBaseBlock) passedBlock  failed:(CKRetryBaseBlock) failureBlock
{
    model.retryCount +=1;
    if(model.retryCount > self.retryMaxCount)
    {
        if (failureBlock) {
            failureBlock(model);
        }
        
        [self.downloadManager moveDownAndRetryByURL:URL(model.URLString)];
    }
    else
    {
        if(passedBlock)
            passedBlock(model);
    }
}

#pragma mark - head length retry

-(void) resetHeadLengthRetryCountWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model
{
    model.headLengthRetryCount = 0;
}

-(void) retryHeadLengthWithURL:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model passed:(CKRetryBaseBlock) passedBlock  failed:(CKRetryBaseBlock) failureBlock
{
    _getHeadLengthPassedBlock = passedBlock;
    _getHeadLengthFailureBlock = failureBlock;
    if(!_retryQueue)
    {
        _retryQueue = [self.downloadManager createRequestQueue];
    }
    id<CKHTTPRequestProtocol> request = [self.downloadManager createHeadRequestWithURL:URL(model.URLString)];
    request.ck_delegate = self;
    [_retryQueue ck_addRequest:request];
    [_retryQueue ck_go];
}

#pragma mark - CKHTTPRequestDelegate

-(void) ck_requestStarted:(id<CKHTTPRequestProtocol>)request
{
    
}

-(void) ck_request:(id<CKHTTPRequestProtocol>)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    id<CKValidatorModelProtocol,CKRetryModelProtocol,CKDownloadModelProtocol> model = [self.downloadManager getModelByURL:request.ck_url];
    if(request.ck_totalContentLength != model.standardFileSize)
    {
        if(model.headLengthRetryCount >= self.headLengthRetryMaxCount)
        {
            if(_getHeadLengthFailureBlock) {
                _getHeadLengthFailureBlock(model);
            }
            [self.downloadManager moveDownAndRetryByURL:URL(model.URLString)];
        }
        else
        {
            model.headLengthRetryCount += 1;
            [self retryHeadLengthWithURL:model passed:_getHeadLengthPassedBlock failed:_getHeadLengthFailureBlock];
        }
    }
    else
    {
        if(_getHeadLengthPassedBlock)
        {
            _getHeadLengthPassedBlock(model);
        }
    }
}

-(void) ck_requestFinished:(id<CKHTTPRequestProtocol>)request
{
    
}

-(void) ck_requestFailed:(id<CKHTTPRequestProtocol>)request
{
    
}

-(void) ck_request:(id<CKHTTPRequestProtocol>)request didReceiveBytes:(long long)bytes
{
    
}

@end
