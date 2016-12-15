//
//  CKURLSessionDownloadQueue.m
//  Pods
//
//  Created by mac on 16/2/17.
//
//

#import "CKURLSessionDownloadQueue.h"
#import "CKDownloadPathManager.h"
#import "CKDownloadManager.h"
#import "CKURLSessionTaskRequest+Download.h"


@interface CKDownloadManager ()
/**
 *  update model change to database
 *
 *  @param model downlaod task model
 */
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocol>) model;

@end


@interface CKURLSessionDownloadQueue ()<NSURLSessionDownloadDelegate>
@property(nonatomic,strong) NSMutableDictionary * url2RequestDic;
@property(nonatomic,assign) BOOL isHead;
@end


@implementation CKURLSessionDownloadQueue

+ (instancetype)sharedInstance {
    static CKURLSessionDownloadQueue *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CKURLSessionDownloadQueue alloc] initWithHead:NO];
        _sharedInstance.maxConcurrentOperationCount = 3;
    });
    
    return _sharedInstance;
}

+ (instancetype)sharedHeadInstance {
    static CKURLSessionDownloadQueue *_sharedHeadInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHeadInstance = [[CKURLSessionDownloadQueue alloc] initWithHead:YES];
        _sharedHeadInstance.maxConcurrentOperationCount = 3;
    });
    
    return _sharedHeadInstance;
}

- (instancetype) initWithHead:(BOOL) isHead {
    self = [super init];
    
    if(self)
    {
        self.isHead = isHead;
        self.url2RequestDic = [NSMutableDictionary dictionary];
        NSURLSessionConfiguration *configuration = nil;
        if (!configuration) {
            NSString *configurationIdentifier = @"CKURLSessionDownloadTask";
            if(isHead)
            {
                 configurationIdentifier = @"CKURLSessionHeadTask";
            }
        #if TARGET_OS_IPHONE
            if([[[UIDevice currentDevice] systemVersion] floatValue] > 8)
            {
                configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:configurationIdentifier];
            }
            else
            {
                configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:configurationIdentifier];
            }
        #else
            #if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 1100)
                configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:configurationIdentifier];
            #else
                configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:configurationIdentifier];
            #endif
        #endif
        }
       
        self.session =  [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return  self;
}

#pragma mark -  CKHTTPRequestQueueProtocol

+(instancetype) ck_createQueue:(BOOL)isHead
{
    if(isHead)
    {
        return [CKURLSessionDownloadQueue sharedHeadInstance];
    }
    else
    {
        return [CKURLSessionDownloadQueue sharedInstance];
    }
}


-(void) ck_addRequest:(id<CKHTTPRequestProtocol>)request
{
    [self.url2RequestDic setObject:request forKey:request.ck_url];
    [self addOperation:request];
}

-(void) ck_setSuspended:(BOOL)isSuspend
{
    [self setSuspended:isSuspend];
}

-(void) ck_go
{
    [self setSuspended:NO];
}

-(void) setCk_maxConcurrentOperationCount:(NSInteger)ck_maxConcurrentOperationCount
{
    self.maxConcurrentOperationCount = ck_maxConcurrentOperationCount;
}

-(NSInteger) ck_maxConcurrentOperationCount
{
    return self.maxConcurrentOperationCount;
}

-(BOOL) ck_isSuspended
{
    return  self.isSuspended;
}

-(NSArray *) ck_operations
{
    return self.operations;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    //在发送HEAD请求的时候莫名其妙会进去该请求
    if(self.isHead)
        return ;
    
    NSURLSessionDownloadTask<CKHTTPRequestProtocol> * task  = downloadTask;
    NSURL * url = task.originalRequest.URL;
    NSFileManager * mgr = [NSFileManager defaultManager];
    if([mgr fileExistsAtPath:[location path]])
    {
        NSString * toPath=nil;
        NSString * tmpPath=nil;
        [[CKDownloadPathManager sharedInstance] SetURL:url toPath:&toPath tempPath:&tmpPath];
        NSURL * toURL = [NSURL fileURLWithPath:toPath];
        
        NSError * error = nil;
        [mgr moveItemAtURL:location toURL:toURL error:&error];
        if(error)
        {
            NSLog(@"%@move temp file failed!",url);
        }
    }
    
    CKURLSessionTaskRequest * request = [self.url2RequestDic objectForKey:task.originalRequest.URL];
    if(request) {
        [request completeOperation];
    }
    
    if([request.ck_delegate respondsToSelector:@selector(ck_requestFinished:)])
    {
        [request.ck_delegate ck_requestFinished:request];
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //在发送HEAD请求的时候莫名其妙会进去该请求
    if(self.isHead)
        return ;
    
    NSURLSessionDownloadTask<CKHTTPRequestProtocol> * task  = downloadTask;
    CKURLSessionTaskRequest * request = [self.url2RequestDic objectForKey:task.originalRequest.URL];
    if(task != request.task)
        return ;
    if(request) {
        request.totalBytesWritten = totalBytesWritten;
        request.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
        [request ck_performDelegateDidReceiveResponseHeaders];
    }
    
    if([request.ck_delegate respondsToSelector:@selector(ck_request:didReceiveBytes:)])
    {
        [request.ck_delegate ck_request:request didReceiveBytes:bytesWritten];
    }
    
}


-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(!self.isHead)
    {
        CKURLSessionTaskRequest * request = [self.url2RequestDic objectForKey:task.originalRequest.URL];
        if(error)
        {
            /**
             *  downlod failed and save data
             */
            NSData* resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            if (resumeData) {
                id<CKDownloadModelProtocol> model = [[CKDownloadManager sharedInstance] getModelByURL:task.originalRequest.URL];
                [CKURLSessionTaskRequest __copyTempPathWithResumData:resumeData url:URL(model.URLString)];
                model.extraDownloadData = [CKURLSessionTaskRequest __changeResumDataWithData:resumeData url:URL(model.URLString)];
                [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
            }
            
            if(request)
            {
                [request completeOperation];
            }
            
            if([request.ck_delegate respondsToSelector:@selector(ck_requestFailed:)])
            {
                [request.ck_delegate ck_requestFailed:request];
            }
            
        }
    }
    else
    {
        //Head Request Invoke Delegate Method
        CKURLSessionTaskRequest * request = [self.url2RequestDic objectForKey:task.originalRequest.URL];
        if(request)
        {
            [request completeOperation];
        }
        if([request.ck_delegate respondsToSelector:@selector(ck_request:didReceiveResponseHeaders:)])
            [request.ck_delegate ck_request:request didReceiveResponseHeaders:nil];
        if([request.ck_delegate respondsToSelector:@selector(ck_request:didReceiveBytes:)])
            [request.ck_delegate ck_request:request didReceiveBytes:nil];
        if([request.ck_delegate respondsToSelector:@selector(ck_requestFinished:)])
            [request.ck_delegate ck_requestFinished:request];
    }
}

@end
