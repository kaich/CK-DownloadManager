//
//  NSURLSessionTask+Download.m
//  Pods
//
//  Created by mac on 16/3/23.
//
//

#import "NSURLSessionTask+Download.h"
#import <objc/runtime.h>
#import "CKURLSessionDownloadQueue.h"
#import "CKDownloadManager.h"
#import "CKDownloadPathManager.h"

static NSString * HTTPRequestDelegate;
static NSString * IsExecutedDidReceiveHeader;


@interface CKDownloadManager ()
/**
 *  update model change to database
 *
 *  @param model downlaod task model
 */
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocal>) model;

@end

@implementation NSURLSessionTask (Download)

+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url
{

    CKURLSessionDownloadQueue * session = [CKURLSessionDownloadQueue ck_createQueue];
    id<CKDownloadModelProtocal> model = [[CKDownloadManager sharedInstance] getModelByURL:url];
    NSURLSessionDownloadTask * task = nil;
    if(![self __isValidResumeData: model.extraDownloadData])
    {
       task = [session.session downloadTaskWithURL:url];
    }
    else
    {
        task = [session.session downloadTaskWithResumeData:model.extraDownloadData];
        model.extraDownloadData = nil;
        [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
        
    }
    task.isExecutedDidReceiveHeader = NO;
    return task;
}


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

+ (void) __copyTempPathWithResumData:(NSData *) data url:(NSURL *) url
{
    if(data)
    {
        NSError *error;
        NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
        if (resumeDictionary && !error)
        {
            NSString *localTmpFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
            
            NSString * toPath=nil;
            NSString * tmpPath=nil;
            [[CKDownloadPathManager sharedInstance] SetURL:url toPath:&toPath tempPath:&tmpPath];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:localTmpFilePath])
            {
                [[NSFileManager defaultManager] copyItemAtPath:localTmpFilePath toPath:tmpPath error:&error];
            }
        }
        
    }
}

+(NSData *) __changeResumDataWithData:(NSData *) data url:(NSURL *) url
{
    if(data)
    {
        NSError *error;
        NSMutableDictionary *resumeDictionary = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error] mutableCopy];
        if (resumeDictionary && !error)
        {
            NSString * toPath=nil;
            NSString * tmpPath=nil;
            [[CKDownloadPathManager sharedInstance] SetURL:url toPath:&toPath tempPath:&tmpPath];
            
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


-(void) ck_setShouldContinueWhenAppEntersBackground:(BOOL)isNeed
{
    
}


-(void) ck_clearDelegatesAndCancel
{
    __weak typeof(self) weakSelf = self;
    [(NSURLSessionDownloadTask *)self cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        id<CKDownloadModelProtocal> model = [[CKDownloadManager sharedInstance] getModelByURL:weakSelf.originalRequest.URL];
        [[self class] __copyTempPathWithResumData:resumeData url:URL(model.URLString)];
        model.extraDownloadData = [[self class] __changeResumDataWithData:resumeData url:URL(model.URLString)];
        [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
    }];
}

-(void) ck_suspend
{
    [self suspend];
}

-(void) ck_resume
{
    [self resume];
}

-(void) ck_addDependency:(id) denpendRequest
{
    
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

-(id<CKHTTPRequestDelegate>) ck_delegate
{
    return objc_getAssociatedObject(self, &HTTPRequestDelegate);
}

-(void) setCk_delegate:(id<CKHTTPRequestDelegate>)ck_delegate
{
    objc_setAssociatedObject(self, &HTTPRequestDelegate, ck_delegate, OBJC_ASSOCIATION_RETAIN);
}

-(NSURL *) ck_url
{
    return self.originalRequest.URL;
}

-(long long) ck_contentLength
{
    return self.countOfBytesExpectedToReceive;
}

-(long long) ck_downloadBytes
{
    return self.countOfBytesReceived;
}

-(long long) ck_totalContentLength
{
    return self.ck_downloadBytes + self.ck_contentLength;
}

-(BOOL) isExecutedDidReceiveHeader
{
   return [objc_getAssociatedObject(self, &IsExecutedDidReceiveHeader) boolValue];
}

-(void) setIsExecutedDidReceiveHeader:(BOOL)isExecutedDidReceiveHeader
{
   objc_setAssociatedObject(self, &IsExecutedDidReceiveHeader, @(isExecutedDidReceiveHeader), OBJC_ASSOCIATION_RETAIN);
}

-(CKHTTPRequestStatus) ck_status
{
    CKHTTPRequestStatus status = kRSReady;
    
    if (self.state == NSURLSessionTaskStateCanceling) {
        status= kRSCanceled;
    }
    else if(self.state == NSURLSessionTaskStateCompleted)
    {
        status= kRSFinished;
    }
    else if(self.state == NSURLSessionTaskStateRunning)
    {
        status= kRSExcuting;
    }
    else if(self.state == NSURLSessionTaskStateSuspended)
    {
        status= kRSReady;
    }
    
    return status;
}

@end

