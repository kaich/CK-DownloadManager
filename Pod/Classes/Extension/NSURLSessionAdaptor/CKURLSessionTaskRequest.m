//
//  NSURLSessionTask+Download.m
//  Pods
//
//  Created by mac on 16/3/23.
//
//

#import "CKURLSessionTaskRequest.h"
#import "CKURLSessionDownloadQueue.h"
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


@interface CKURLSessionTaskRequest ()
{
    BOOL        executing;
    BOOL        finished;
}

@property(nonatomic,strong) NSURL * url;

@end


@implementation CKURLSessionTaskRequest

+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url
{
    return [[CKURLSessionTaskRequest alloc] initWithURL:url];
}


- (void) createTask  {
    
    CKURLSessionDownloadQueue * session = [CKURLSessionDownloadQueue ck_createQueue];
    id<CKDownloadModelProtocol> model = [[CKDownloadManager sharedInstance] getModelByURL:self.url];
    if(![CKURLSessionTaskRequest __isValidResumeData: model.extraDownloadData])
    {
        self.task = [session.session downloadTaskWithURL:self.url];
    }
    else
    {
        if(IS_IOS10ORLATER) {
            self.task = [session.session downloadTaskWithCorrectResumeData:model.extraDownloadData];
        }
        else {
            self.task = [session.session downloadTaskWithResumeData:model.extraDownloadData];
        }
        model.extraDownloadData = nil;
        [[CKDownloadManager sharedInstance] updateDataBaseWithModel:model];
    }
}


- (id)initWithURL:(NSURL *) url {
    self = [super init];
    if (self) {
        self.url = url;
        executing = NO;
        finished = NO;
        [self createTask];
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
    
    // If the operation is not canceled, begin executing the task.
    [self.task resume];
    if ([self.ck_delegate respondsToSelector:@selector(ck_requestStarted:)])
    {
        [self.ck_delegate ck_requestStarted: self];
    }
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
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
            [[CKDownloadPathManager sharedInstance] SetURL:url toPath:&toPath tempPath:&tmpPath];
            
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


@end

