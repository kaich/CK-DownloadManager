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
    if([self.task isKindOfClass: [NSURLSessionDownloadTask class]])
    {
        [(NSURLSessionDownloadTask *)self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            id<CKDownloadModelProtocol> model = [[CKDownloadManager sharedInstance] getModelByURL:weakSelf.task.originalRequest.URL];
            [[self class] __copyTempPathWithResumData:resumeData url:URL(model.URLString)];
            model.extraDownloadData = [[self class] __changeResumDataWithData:resumeData url:URL(model.URLString)];
            [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
            [self cancel];
        }];
    }
    else
    {
        [self.task cancel];
        [self cancel];
    }
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
    if(self.isHead)
    {
        return self.task.countOfBytesReceived;
    }
    else
    {
        return self.totalBytesWritten;
    }
}

-(long long) ck_totalContentLength
{
    if(self.isHead)
    {
        return self.ck_downloadBytes + self.ck_contentLength;
    }
    else
    {
        return self.totalBytesExpectedToWrite;
    }
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
