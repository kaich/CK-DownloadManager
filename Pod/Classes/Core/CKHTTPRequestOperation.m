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
 *  download total bytes
 */
@property(nonatomic,assign) long long ck_downloadBytes;

/**
 *  request header  contentLength .  rest content bytes
 */
@property(nonatomic,assign) long long ck_contentLength;

/**
 *  total file length.
 */
@property(nonatomic,assign) long long ck_totalContentLength;

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


- (BOOL)isConcurrent {
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
    [self headLengthRetry:^{
        id<CKURLDownloadTaskProtocol> task = [self createDownloadTask];
        [self.downloadTask setStartedBlock:^{
            [self.ck_delegate ck_requestStarted:self];
        }];
        
        [self.downloadTask setFailureBlock:^(NSError *error){
            [self.ck_delegate ck_requestFailed:self];
        }];
        
        [self.downloadTask setCompletionBlock:^{
            [self completeOperation];
            [self.ck_delegate ck_requestFinished:self];
        }];
        
        [self.downloadTask setHeadersReceivedBlock:^(NSDictionary *responseHeaders) {
            [self.ck_delegate ck_request:self didReceiveResponseHeaders:responseHeaders];
        }];
        
        [self.downloadTask setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
            [self.ck_delegate ck_request:self didReceiveBytes:size];
        }];
        
        [self.downloadTask ck_startDownloadRequestWithURL:self.ck_url];
    }];
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
        if([self.downloadTask ck_contentLength] != model.standardFileSize)
        {
            tryRetryBlock();
        }
        else
        {
            if(passedBlock)
                passedBlock();
        }
    }];
    
    [self.downloadTask setFailureBlock:^(NSError * error){
        tryRetryBlock();
    }];
    
    [self.downloadTask ck_startHeadRequestWithURL:self.ck_url];
}

- (id<CKURLDownloadTaskProtocol>) createDownloadTask
{
    self.downloadTask = [self.downloadTaskClass create];
    return self.downloadTask;
}

#pragma mark - CKHTTPRequestProtocol

+ (BOOL) ck_isVisibleTempPath
{
    return YES;
}

+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url
{
    return [[CKHTTPRequestOperation alloc] initWithURL:url];
}

-(void) ck_setShouldContinueWhenAppEntersBackground:(BOOL) isNeed
{
    
}

-(void) ck_clearDelegatesAndCancel
{
    [self.downloadTask ck_clearDelegatesAndCancel];
    if(self.isExecuting)
    {
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

-(long long) ck_contentLength
{
    return [self.downloadTask ck_contentLength];
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
