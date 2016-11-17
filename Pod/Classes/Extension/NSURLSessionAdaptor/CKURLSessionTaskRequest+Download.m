//
//  NSURLSessionTaskRequest+Operation.m
//  Pods
//
//  Created by mac on 16/11/7.
//
//

#import "CKURLSessionTaskRequest+Download.h"
#import "CKDownloadManager.h"
#import "CKDownloadPathManager.h"



@interface CKDownloadManager ()
/**
 *  update model change to database
 *
 *  @param model downlaod task model
 */
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocol>) model;

@end

@interface CKURLSessionTaskRequest ()

@property(nonatomic,strong) NSURL * url;

@end


@implementation CKURLSessionTaskRequest (Download)

-(void) ck_setShouldContinueWhenAppEntersBackground:(BOOL)isNeed
{
    
}

-(void) ck_clearDelegatesAndCancel
{
    __weak typeof(self) weakSelf = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        id<CKDownloadModelProtocol> model = [[CKDownloadManager sharedInstance] getModelByURL:weakSelf.task.originalRequest.URL];
        [[self class] __copyTempPathWithResumData:resumeData url:URL(model.URLString)];
        model.extraDownloadData = [[self class] __changeResumDataWithData:resumeData url:URL(model.URLString)];
        [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
        [self completeOperation];
    }];
}

-(NSURL *) ck_url {
    return self.url;
}

-(void) ck_suspend
{
    [self.task suspend];
}

-(void) ck_resume
{
    [self.task resume];
}

-(void) ck_addDependency:(id) denpendRequest
{
    [self addDependency:denpendRequest];
}

-(void) ck_performDelegateDidReceiveResponseHeaders
{
    if(!self.isExecutedDidReceiveHeader)
    {
        [self.ck_delegate ck_request:self didReceiveResponseHeaders:nil];
        self.isExecutedDidReceiveHeader = YES;
    }
}

+ (BOOL) ck_isVisibleTempPath;
{
    return  NO;
}


#pragma mark - dynamic method

-(long long) ck_contentLength
{
    return self.task.countOfBytesExpectedToReceive;
}

-(long long) ck_downloadBytes
{
    return self.task.countOfBytesReceived;
}

-(long long) ck_totalContentLength
{
    return self.ck_downloadBytes + self.ck_contentLength;
}

-(CKHTTPRequestStatus) ck_status
{
    CKHTTPRequestStatus status = kRSReady;
    
    NSURLSessionTaskState state = self.task.state;
    if (state == NSURLSessionTaskStateCanceling) {
        status= kRSCanceled;
    }
    else if(state == NSURLSessionTaskStateCompleted)
    {
        status= kRSFinished;
    }
    else if(state == NSURLSessionTaskStateRunning)
    {
        status= kRSExcuting;
    }
    else if(state == NSURLSessionTaskStateSuspended)
    {
        status= kRSReady;
    }
    
    return status;
}

@end
