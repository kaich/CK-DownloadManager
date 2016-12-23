//
//  NSURLSessionTask+Download.m
//  Pods
//
//  Created by mac on 16/3/23.
//
//

#import "CKURLSessionTaskAdaptor.h"
#import "CKDownloadManager.h"
#import "CKDownloadPathManager.h"
#import "NSURLSession+ResumeData.h"

#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

@interface CKDownloadManager ()
/**
 *  update model change to database
 *
 *  @param model downlaod task model
 */
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocol>) model;

@end


@interface CKURLSessionTaskAdaptor ()<NSURLSessionDownloadDelegate>

@property(nonatomic,strong) NSURLSessionTask * task;

@property(nonatomic,strong) NSURLSession * session;

@property(nonatomic,assign) BOOL isHeaderDidReceive;

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

@end


@implementation CKURLSessionTaskAdaptor


+(instancetype) create
{
    return [[CKURLSessionTaskAdaptor alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    }
    return self;
}

-(void) ck_startDownloadRequestWithURL:(NSURL *) url
{
    id<CKDownloadModelProtocol> model = [[CKDownloadManager sharedInstance] getModelByURL:url];
    if(![CKURLSessionTaskAdaptor __isValidResumeData: model.extraDownloadData])
    {
        self.task = [self.session downloadTaskWithURL:url];
    }
    else
    {
        if(IS_IOS10ORLATER) {
            self.task = [self.session downloadTaskWithCorrectResumeData:model.extraDownloadData];
        }
        else {
            self.task = [self.session downloadTaskWithResumeData:model.extraDownloadData];
        }
        model.extraDownloadData = nil;
        [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
    }

    [self.task resume];
}

-(void) ck_startHeadRequestWithURL:(NSURL *) url
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        self.ck_contentLength = response.expectedContentLength;
        self.ck_totalContentLength = response.expectedContentLength;
       
        if(self.headersReceivedBlock)
            self.headersReceivedBlock();
        if(self.bytesReceivedBlock)
            self.bytesReceivedBlock();
        if(error)
        {
            if(self.failureBlock)
                self.failureBlock();
        }
        else
        {
            if(self.completionBlock)
                self.completionBlock();
        }
        
    }];
    
    [self.task resume];
}

-(void) ck_clearDelegatesAndCancel
{
    __weak typeof(self) weakSelf = self;
    if([self.task isKindOfClass: [NSURLSessionDownloadTask class]])
    {
        [(NSURLSessionDownloadTask *)self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if(resumeData)
            {
                id<CKDownloadModelProtocol> model = [[CKDownloadManager sharedInstance] getModelByURL:weakSelf.task.originalRequest.URL];
                [[self class] __copyTempPathWithResumData:resumeData url:URL(model.URLString)];
                NSData * resumeData = [[self class] __changeResumDataWithData:resumeData url:URL(model.URLString)];
                model.extraDownloadData = resumeData;
                [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
            }
        }];
    }
    else
    {
        [self.task cancel];
    }
    
}


//MARK: - Resume task only works before ios 10.NSURLSessionResumeInfoLocalPath isn't exist in data

/**
 *  validate resum data. If you are debugging mode ,It may be failed because of NSHomeDirectory() changed.
 *
 *  @param data resum data
 *
 *  @return valid return YES, otherwise return NO
 */
+ (BOOL)__isValidResumeData:(NSData *)data
{
    if (!data || [data length] < 1) return NO;
    
    if(!IS_IOS10ORLATER) {
        NSError *error;
        NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
        if (!resumeDictionary || error) return NO;
        
        NSString *localTmpFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
        if ([localTmpFilePath length] < 1) return NO;
        
        BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:localTmpFilePath];
        
        if (!result) {
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            NSString *localName = [localTmpFilePath lastPathComponent];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDir = [paths objectAtIndex:0];
            NSString *localCachePath = [[[cachesDir stringByAppendingPathComponent:@"com.apple.nsurlsessiond/Downloads"]stringByAppendingPathComponent:bundleIdentifier]stringByAppendingPathComponent:localName];
            result = [[NSFileManager defaultManager] moveItemAtPath:localCachePath toPath:localTmpFilePath error:nil];
        }
    
        return result;
    }
    else {
        NSError *error;
        NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
        if (!resumeDictionary || error) return NO;
    }
    
    return YES;
}


/**
 Copy temp file in system path to user custom path.To avoid system delete tmp file.

 @param data resume data
 @param url  download url
 */
+ (void) __copyTempPathWithResumData:(NSData *) data url:(NSURL *) url
{
    if(data && !IS_IOS10ORLATER)
    {
        NSError *error;
        NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
        if (resumeDictionary && !error)
        {
            NSString *localTmpFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
            
            NSString * toPath=nil;
            NSString * tmpPath=nil;
            [[CKDownloadPathManager sharedInstance] getURL:url toPath:&toPath tempPath:&tmpPath];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:localTmpFilePath] && ![localTmpFilePath isEqualToString:tmpPath])
            {
                [[NSFileManager defaultManager] copyItemAtPath:localTmpFilePath toPath:tmpPath error:&error];
            }
        }
        
    }
}


/**
 Change resume data tmp file path to resume task with tmp file in user custom path.

 @param data  resume data
 @param url   download url

 @return changed resume data
 */
+(NSData *) __changeResumDataWithData:(NSData *) data url:(NSURL *) url
{
    if(data && !IS_IOS10ORLATER)
    {
        NSError *error;
        NSMutableDictionary *resumeDictionary = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error] mutableCopy];
        if (resumeDictionary && !error)
        {
            NSString * toPath=nil;
            NSString * tmpPath=nil;
            [[CKDownloadPathManager sharedInstance] getURL:url toPath:&toPath tempPath:&tmpPath];
            
            [resumeDictionary setObject:tmpPath forKey:@"NSURLSessionResumeInfoLocalPath"];
        }
        
        NSData *changedData = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary
                                                                                        format:NSPropertyListBinaryFormat_v1_0
                                                                                       options:0
                                                                                         error:NULL];;
        return changedData;
    }
    
    return data;
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSURLSessionDownloadTask<CKHTTPRequestProtocol> * task  = downloadTask;
    NSURL * url = task.originalRequest.URL;
    NSFileManager * mgr = [NSFileManager defaultManager];
    if([mgr fileExistsAtPath:[location path]])
    {
        NSString * toPath=nil;
        NSString * tmpPath=nil;
        [[CKDownloadPathManager sharedInstance] getURL:url toPath:&toPath tempPath:&tmpPath];
        NSURL * toURL = [NSURL fileURLWithPath:toPath];
        
        NSError * error = nil;
        [mgr moveItemAtURL:location toURL:toURL error:&error];
        if(error)
        {
            NSLog(@"%@move temp file failed!",url);
        }
    }
    
    if(self.completionBlock)
        self.completionBlock();
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.ck_downloadBytes = totalBytesWritten;
    self.ck_contentLength = totalBytesExpectedToWrite;
    self.ck_totalContentLength = totalBytesWritten + totalBytesExpectedToWrite;
    
    if(!self.isHeaderDidReceive)
    {
        if(self.headersReceivedBlock)
            self.headersReceivedBlock();
        self.isHeaderDidReceive = YES;
    }
    
    if(self.bytesReceivedBlock)
        self.bytesReceivedBlock();
}


-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error)
    {
        /**
         *  downlod failed and save data
         */
        NSData* resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        if (resumeData) {
            id<CKDownloadModelProtocol> model = [[CKDownloadManager sharedInstance] getModelByURL:task.originalRequest.URL];
            [CKURLSessionTaskAdaptor __copyTempPathWithResumData:resumeData url:URL(model.URLString)];
            model.extraDownloadData = [CKURLSessionTaskAdaptor __changeResumDataWithData:resumeData url:URL(model.URLString)];
            [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
        }

        if(self.failureBlock)
            self.failureBlock();
        
    }

}

@end

