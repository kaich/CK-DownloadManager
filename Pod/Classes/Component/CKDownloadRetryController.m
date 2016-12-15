//
//  CKDownloadRetryController.m
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "CKDownloadRetryController.h"
#import "CKDownloadManager+MoveDownAndRetry.h"

@interface CKDownloadManager ()

-(NSInteger) maxCurrentCount;

@end

@interface CKDownloadRetryController ()<CKHTTPRequestDelegate>
{
    id<CKHTTPRequestQueueProtocol> _retryQueue;
}


@property(nonatomic,strong) CKMutableOrdinalDictionary * headLengthRetryRequest2URL;
@property(nonatomic,strong) CKMutableOrdinalDictionary * currentHeadLengthRetryRequest2URL;
@property(nonatomic,strong) NSMutableDictionary * getHeadLengthPassedBlockDic;
@property(nonatomic,strong) NSMutableDictionary * getHeadLengthFailureBlockDic;

@end


@implementation CKDownloadRetryController

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        self.headLengthRetryRequest2URL = [[CKMutableOrdinalDictionary alloc] init];
        self.currentHeadLengthRetryRequest2URL = [[CKMutableOrdinalDictionary alloc] init];
        self.getHeadLengthPassedBlockDic = [NSMutableDictionary dictionary];
        self.getHeadLengthFailureBlockDic = [NSMutableDictionary dictionary];
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
        [self resetHeadLengthRetryCountWithURL:URL(model.URLString)];
    }
}

-(void) retryHeadLengthWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model passed:(CKRetryBaseBlock) passedBlock  failed:(CKRetryBaseBlock) failureBlock
{
    [self retryHeadLengthWithModel:model isAutoStart:YES passed:passedBlock failed:failureBlock];
}


-(void) resetHeadLengthRetryCountWithURL:(NSURL *) url
{
    id<CKHTTPRequestProtocol> oldRequest = [self.currentHeadLengthRetryRequest2URL objectForKey:url];
    [oldRequest ck_clearDelegatesAndCancel];
    [self.getHeadLengthPassedBlockDic removeObjectForKey:url];
    [self.getHeadLengthFailureBlockDic removeObjectForKey:url];
    [self.headLengthRetryRequest2URL removeObjectForKey:url];
    [self.currentHeadLengthRetryRequest2URL removeObjectForKey:url];
    [self startNewHeadLengthRetry:nil];
}

/**
 retry head length

 @param model       模型
 @param isAuto      YES内部控制自动开始 NO立即开始新建的任务
 @param passedBlock 成功回调
 @param failureBlock 失败回调
 */
-(void) retryHeadLengthWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model isAutoStart:(BOOL) isAuto passed:(CKRetryBaseBlock) passedBlock  failed:(CKRetryBaseBlock) failureBlock
{
    @synchronized (self) {
        [_getHeadLengthPassedBlockDic setObject:passedBlock forKey:URL(model.URLString)];
        [_getHeadLengthFailureBlockDic setObject:failureBlock forKey:URL(model.URLString)];
        if(!_retryQueue)
        {
            _retryQueue = [self.downloadManager createRequestQueue:YES];
            _retryQueue.ck_maxConcurrentOperationCount = 3;
        }
        id<CKHTTPRequestProtocol> request = [self.downloadManager createRequestWithURL:URL(model.URLString) isHead: YES];
        request.ck_delegate = self;
        id<CKHTTPRequestProtocol> oldRequest = [self.currentHeadLengthRetryRequest2URL objectForKey:URL(model.URLString)];
        [oldRequest ck_clearDelegatesAndCancel];
        [self.headLengthRetryRequest2URL setObject:request forKey:URL(model.URLString)];
        if(isAuto)
        {
            [self startNewHeadLengthRetry:nil];
        }
        else
        {
            [self startNewHeadLengthRetry:request];
        }
    }
}

-(void) startNewHeadLengthRetry:(id<CKHTTPRequestProtocol>) aRequest
{
    @synchronized (self) {
        void(^startRequest)(id<CKHTTPRequestProtocol>) = ^(id<CKHTTPRequestProtocol> request){
            if(request && ![_retryQueue.ck_operations containsObject:request] && request.ck_status != kRSFinished && request.ck_status != kRSExcuting && request.ck_status != kRSCanceled)
            {
                [_retryQueue ck_addRequest:request];
                [_retryQueue ck_go];
            }
        };
        
        if(aRequest)
        {
            [self.currentHeadLengthRetryRequest2URL setObject:aRequest forKey:aRequest.ck_url];
            startRequest(aRequest);
            return ;
        }
        
        if(self.currentHeadLengthRetryRequest2URL.count < self.downloadManager.maxCurrentCount)
        {
            id<CKHTTPRequestProtocol> request = self.headLengthRetryRequest2URL.firstObject;
            if(request)
            {
                [self.currentHeadLengthRetryRequest2URL setObject:request forKey:request.ck_url];
                [self.headLengthRetryRequest2URL removeObjectForKey:request.ck_url];
                startRequest(request);
            }
        }
    }
}

-(void) executeHeadLengthRetryCallbackWithRequest:(id<CKHTTPRequestProtocol>) request
{
    @synchronized (self) {
        
        id<CKValidatorModelProtocol,CKRetryModelProtocol,CKDownloadModelProtocol> model = [self.downloadManager getModelByURL:request.ck_url];
        id<CKHTTPRequestProtocol> currentRequest = [self.currentHeadLengthRetryRequest2URL objectForKey:URL(model.URLString)];
        
        if(!currentRequest)
            return  ;
        //if request isn't same, it means head length retry be reseted.
        void(^sameRequestBlock)() = ^(void(^block)()){
            
            if(currentRequest == request)
            {
                //if it's paused or deleted, reset head length retry
                if(model.downloadState = kDSWaitDownload)
                {
                    block();
                }
                else
                {
                    if(model)
                    {
                        [self resetHeadLengthRetryCountWithModel:model];
                    }
                    else
                    {
                        [self resetHeadLengthRetryCountWithURL:currentRequest.ck_url];
                    }
                }
            }
        };
        
        model.headLengthRetryCount += 1;
        if(request.ck_totalContentLength != model.standardFileSize)
        {
            if(model.headLengthRetryCount >= self.headLengthRetryMaxCount)
            {
                //remove it from retry list
                sameRequestBlock(^(){
                    CKRetryBaseBlock failureBlock = [_getHeadLengthFailureBlockDic objectForKey:URL(model.URLString)];
                    if(failureBlock) {
                        failureBlock(model);
                        [_getHeadLengthPassedBlockDic removeObjectForKey:URL(model.URLString)];
                    }
                    [self.downloadManager moveDownAndRetryByURL:URL(model.URLString)];
                });

            }
            else
            {
                sameRequestBlock(^(){
                    CKRetryBaseBlock passedBlock = [_getHeadLengthPassedBlockDic objectForKey:URL(model.URLString)];
                    CKRetryBaseBlock failureBlock = [_getHeadLengthFailureBlockDic objectForKey:URL(model.URLString)];
                    [self retryHeadLengthWithModel:model isAutoStart:NO passed:passedBlock failed:failureBlock];
                });
            }
        }
        else
        {
            sameRequestBlock(^(){
                CKRetryBaseBlock passedBlock = [_getHeadLengthPassedBlockDic objectForKey:URL(model.URLString)];
                if(passedBlock)
                {
                    passedBlock(model);
                    [_getHeadLengthPassedBlockDic removeObjectForKey:URL(model.URLString)];
                }
            });
            
        }
    }
}

#pragma mark - CKHTTPRequestDelegate

-(void) ck_requestStarted:(id<CKHTTPRequestProtocol>)request
{
    
}

-(void) ck_request:(id<CKHTTPRequestProtocol>)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    [self executeHeadLengthRetryCallbackWithRequest:request];
}

-(void) ck_requestFinished:(id<CKHTTPRequestProtocol>)request
{
    
}

-(void) ck_requestFailed:(id<CKHTTPRequestProtocol>)request
{
    //请求失败执行重试
    [self executeHeadLengthRetryCallbackWithRequest:request];
}

-(void) ck_request:(id<CKHTTPRequestProtocol>)request didReceiveBytes:(long long)bytes
{
    
}

@end
