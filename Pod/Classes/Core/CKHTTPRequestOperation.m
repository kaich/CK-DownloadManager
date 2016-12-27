//
//  CKHTTPRequestOperation.m
//  Pods
//
//  Created by mac on 16/12/16.
//
//

#import "CKHTTPRequestOperation.h"
#import "CKDownloadManager.h"
#import "CKDownloadManager+MoveDownAndRetry.h"

@interface CKHTTPRequestOperation ()
{
    BOOL        executing;
    BOOL        finished;
}

/**
 *  request url
 */
@property(nonatomic,strong) NSURL * ck_url;

/**
 *  request header  contentLength .  rest content bytes
 */
@property(nonatomic,assign) long long ck_contentLength;

/**
    download task
 */
@property(nonatomic,strong) id<CKURLDownloadTaskProtocol> downloadTask;

@property(nonatomic,assign) NSInteger headLengthCurrentRetryTimes;

@end



@implementation CKHTTPRequestOperation

- (id)initWithURL:(NSURL *) url {
    self = [super init];
    if (self) {
        self.ck_url = url;
        executing = NO;
        finished = NO;
    }
    return self;
}


- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    
    return finished;
}


- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        
        // If the operation is not canceled, begin executing the task.
        if ([self.ck_delegate respondsToSelector:@selector(ck_requestStarted:)])
        {
            [self.ck_delegate ck_requestStarted: self];
        }
        return;
    }

    [self beginTask];
    
    // If the operation is not canceled, begin executing the task.
    if ([self.ck_delegate respondsToSelector:@selector(ck_requestStarted:)])
    {
        [self.ck_delegate ck_requestStarted: self];
    }
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


- (void) beginTask
{
    if(self.downloadManager.retryController)
    {
        [self headLengthRetry:^{
            [self startDownloadTask];
        }];
    }
    else
    {
        [self startDownloadTask];
    }
}

- (void) startDownloadTask
{
    id<CKURLDownloadTaskProtocol> task = [self createDownloadTask];
    
    [self.downloadTask setFailureBlock:^(){
        [self.ck_delegate ck_requestFailed:self];
    }];
    
    [self.downloadTask setCompletionBlock:^{
        [self completeOperation];
        [self.ck_delegate ck_requestFinished:self];
    }];
    
    [self.downloadTask setHeadersReceivedBlock:^() {
        [self.ck_delegate ck_requestDidReceiveResponseHeaders:self];
    }];
    
    [self.downloadTask setBytesReceivedBlock:^() {
        [self.ck_delegate ck_requestDidReceiveBytes:self];
    }];
    
    [self.downloadTask ck_startDownloadRequestWithURL:self.ck_url];
}

- (void) headLengthRetry:(void(^)()) passedBlock
{
    void(^tryRetryBlock)() = ^(){
        if(self.headLengthCurrentRetryTimes > self.downloadManager.retryController.headLengthRetryMaxCount)
        {
            [self completeOperation];
            [self.downloadManager moveDownAndRetryByURL:self.ck_url];
        }
        else
        {
            [self headLengthRetry:passedBlock];
        }
    };
    
    self.headLengthCurrentRetryTimes += 1;
    id<CKURLDownloadTaskProtocol> task = [self createDownloadTask];
    [self.downloadTask setCompletionBlock:^(){
        id<CKDownloadModelProtocol,CKValidatorModelProtocol> model = [self.downloadManager getModelByURL: self.ck_url];
        if([self.downloadTask ck_totalContentLength] != model.standardFileSize)
        {
            tryRetryBlock();
        }
        else
        {
            if(passedBlock)
                passedBlock();
        }
    }];
    
    [self.downloadTask setFailureBlock:^(){
        tryRetryBlock();
    }];
    
    [self.downloadTask ck_startHeadRequestWithURL:self.ck_url];
}

- (id<CKURLDownloadTaskProtocol>) createDownloadTask
{
    self.downloadTask = [self.downloadTaskClass create];
    return self.downloadTask;
}


-(void) cancel
{
    [self willChangeValueForKey:@"isCancelled"];
    
    [self.downloadTask ck_clearDelegatesAndCancel];
    //This method does not force your operation code to stop. Instead, it updates the object’s internal flags to reflect the change in state. If the operation has already finished executing, this method has no effect. Canceling an operation that is currently in an operation queue, but not yet executing, makes it possible to remove the operation from the queue sooner than usual.
    [super cancel];
    
    [self didChangeValueForKey:@"isCancelled"];
}

#pragma mark - CKHTTPRequestProtocol

+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url
{
    return [[CKHTTPRequestOperation alloc] initWithURL:url];
}

-(void) ck_setShouldContinueWhenAppEntersBackground:(BOOL) isNeed
{

}

-(void) ck_clearDelegatesAndCancel
{
    if(self.isExecuting)
    {
        
        [self.downloadTask ck_clearDelegatesAndCancel];
        [self completeOperation];
    }
    else
    {
        //This method does not force your operation code to stop. Instead, it updates the object’s internal flags to reflect the change in state. If the operation has already finished executing, this method has no effect. Canceling an operation that is currently in an operation queue, but not yet executing, makes it possible to remove the operation from the queue sooner than usual.
        [self cancel];
    }
}

-(void) ck_addDependency:(id) request
{
    [self addDependency:request];
}

- (long long) ck_downloadBytes
{
    return  [self.downloadTask ck_downloadBytes];
}

-(long long) ck_totalContentLength
{
    return [self.downloadTask ck_totalContentLength];
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