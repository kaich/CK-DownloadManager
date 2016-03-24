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


@interface CKDownloadManager ()
/**
 *  update model change to database
 *
 *  @param model downlaod task model
 */
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocal>) model;

@end


@interface CKURLSessionDownloadQueue()<NSURLSessionDownloadDelegate,NSURLSessionDelegate>
{
    BOOL _isSuspended;
    NSInteger  _maxConcurrentOperationCount;
}


@end

@implementation CKURLSessionDownloadQueue

+ (instancetype)sharedInstance {
    static CKURLSessionDownloadQueue *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CKURLSessionDownloadQueue alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if(self)
    {
        NSURLSessionConfiguration *configuration = nil;
        if (!configuration) {
            NSString *configurationIdentifier = @"CKURLSessionDownloadTask";
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

#pragma mark -  CKHTTPRequestQueueProtocal

+(instancetype) ck_createQueue
{
    return [CKURLSessionDownloadQueue sharedInstance];
}

-(void) ck_addRequest:(id<CKHTTPRequestProtocal>)request
{

    [request ck_resume];
    
    if ([request.ck_delegate respondsToSelector:@selector(ck_requestStarted:)])
    {
        [request.ck_delegate ck_requestStarted: request];
    }
}

-(void) ck_setSuspended:(BOOL)isSuspend
{
    
}

-(void) ck_go
{
    
}

-(void) ck_addDependency:(id) request
{
    
}


-(void) setCk_maxConcurrentOperationCount:(NSInteger)ck_maxConcurrentOperationCount
{
    _maxConcurrentOperationCount = ck_maxConcurrentOperationCount;
}

-(NSInteger) ck_maxConcurrentOperationCount
{
    return _maxConcurrentOperationCount;
}

-(BOOL) ck_isSuspended
{
    return  _isSuspended;
}

-(NSArray *) ck_operations
{
    return @[];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSURLSessionDownloadTask<CKHTTPRequestProtocal> * task  = downloadTask;
    NSURL * url = task.originalRequest.URL;
    NSFileManager * mgr = [NSFileManager defaultManager];
    if([mgr fileExistsAtPath:[location path]])
    {
        NSString * toPath=nil;
        NSString * tmpPath=nil;
        [[CKDownloadPathManager sharedInstance] SetURL:url toPath:&toPath tempPath:&tmpPath];
        
        NSError * error = nil;
        [mgr moveItemAtURL:location toURL:url error:&error];
        if(error)
        {
            NSLog(@"%@move temp file failed!",url);
        }
    }
    
    if([task.ck_delegate respondsToSelector:@selector(ck_requestFinished:)])
    {
        [task.ck_delegate ck_requestFinished:task];
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSURLSessionDownloadTask<CKHTTPRequestProtocal> * task  = downloadTask;
    [task ck_performDelegateDidReceiveResponseHeaders];
    
    if([task.ck_delegate respondsToSelector:@selector(ck_request:didReceiveBytes:)])
    {
        [task.ck_delegate ck_request:task didReceiveBytes:bytesWritten];
    }
   
}



-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSURLSessionDownloadTask<CKHTTPRequestProtocal> * downloadTask  = (NSURLSessionDownloadTask *)task;
   if(error)
   {
       if (error) {
           /**
            *  downlod failed and save data
            */
           NSData* resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
           if (resumeData) {
               id<CKDownloadModelProtocal> model = [[CKDownloadManager sharedInstance] getModelByURL:task.originalRequest.URL];
               [NSURLSessionTask __copyTempPathWithResumData:resumeData url:URL(model.URLString)];
               model.extraDownloadData = [NSURLSessionTask __changeResumDataWithData:resumeData url:URL(model.URLString)];
               [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
           }
       }
       
       if([downloadTask.ck_delegate respondsToSelector:@selector(ck_requestFailed:)])
       {
           [downloadTask.ck_delegate ck_requestFailed:downloadTask];
       }
       
   }
}

@end
