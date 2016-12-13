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

/**
 记录请求头重试的请求
 */
@property(nonatomic,strong) NSMutableDictionary * headLengthRetryRequest2URL;

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


-(void) retryWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model passed:(CKRetryBaseBlock) passedBlock  failed:(CKRetryBaseBlock) failureBlock
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
    @synchronized (self) {
        model.headLengthRetryCount = 0;
    }
}

-(void) retryHeadLengthWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model passed:(CKRetryBaseBlock) passedBlock  failed:(CKRetryBaseBlock) failureBlock
{
    @synchronized (self) {
        model.headLengthRetryCount += 1;
        _getHeadLengthPassedBlock = passedBlock;
        _getHeadLengthFailureBlock = failureBlock;
        if(!_retryQueue)
        {
            _retryQueue = [self.downloadManager createRequestQueue];
        }
        id<CKHTTPRequestProtocol> request = [self.downloadManager createHeadRequestWithURL:URL(model.URLString)];
        request.ck_delegate = self;
        id<CKHTTPRequestProtocol> oldRequest = [self.headLengthRetryRequest2URL objectForKey:model.URLString];
        [oldRequest ck_clearDelegatesAndCancel];
        [self.headLengthRetryRequest2URL setObject:request forKey:model.URLString];
        [_retryQueue ck_addRequest:request];
        [_retryQueue ck_go];
    }
}

#pragma mark - CKHTTPRequestDelegate

-(void) ck_requestStarted:(id<CKHTTPRequestProtocol>)request
{
    
}

-(void) ck_request:(id<CKHTTPRequestProtocol>)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    @synchronized (self) {
        id<CKValidatorModelProtocol,CKRetryModelProtocol,CKDownloadModelProtocol> model = [self.downloadManager getModelByURL:request.ck_url];
       id<CKHTTPRequestProtocol> currentRequest = [self.headLengthRetryRequest2URL objectForKey:model.URLString]; 
        //if request isn't same, it means head length retry be reseted.
        void(^sameRequestBlock)() = ^(void(^block)()){
            
            if(currentRequest != request)
            {
                block();
            }
        };
        
        if(request.ck_totalContentLength != model.standardFileSize)
        {
            if(model.headLengthRetryCount >= self.headLengthRetryMaxCount)
            {
                sameRequestBlock(^(){
                    if(_getHeadLengthFailureBlock) {
                        _getHeadLengthFailureBlock(model);
                    }
                    [self.downloadManager moveDownAndRetryByURL:URL(model.URLString)];
                });
            }
            else
            {
                sameRequestBlock(^(){
                    [self retryHeadLengthWithModel:model passed:_getHeadLengthPassedBlock failed:_getHeadLengthFailureBlock];
                });
            }
        }
        else
        {
            sameRequestBlock(^(){
                if(_getHeadLengthPassedBlock)
                {
                    _getHeadLengthPassedBlock(model);
                }
            });
        }
    }
}

-(void) ck_requestFinished:(id<CKHTTPRequestProtocol>)request
{
    
}

-(void) ck_requestFailed:(id<CKHTTPRequestProtocol>)request
{
    //请求失败执行重试
    id<CKValidatorModelProtocol,CKRetryModelProtocol,CKDownloadModelProtocol> model = [self.downloadManager getModelByURL:request.ck_url];
    id<CKHTTPRequestProtocol> currentRequest = [self.headLengthRetryRequest2URL objectForKey:model.URLString];
    void(^sameRequestBlock)() = ^(void(^block)()){
        
        if(currentRequest != request)
        {
            block();
        }
    };

    if(model.headLengthRetryCount >= self.headLengthRetryMaxCount)
    {
        sameRequestBlock(^(){
            if(_getHeadLengthFailureBlock) {
                _getHeadLengthFailureBlock(model);
            }
            [self.downloadManager moveDownAndRetryByURL:URL(model.URLString)];
        });
    }
    else
    {
        sameRequestBlock(^(){
            [self retryHeadLengthWithModel:model passed:_getHeadLengthPassedBlock failed:_getHeadLengthFailureBlock];
        });
    }
}

-(void) ck_request:(id<CKHTTPRequestProtocol>)request didReceiveBytes:(long long)bytes
{
    
}

@end
