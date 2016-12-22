//
//  AFDownloadRequestOperationAdaptor.m
//  Pods
//
//  Created by mac on 16/12/21.
//
//

#import "AFNetWorkingAdaptor.h"
#import "AFNetworking.h"
#import "AFDownloadRequestOperation.h"
#import "CKDownloadPathManager.h"
#import "CKDownloadManager.h"
#import "NSURLSessionTask+Download.h"

@interface AFNetWorkingAdaptor ()

@property(nonatomic,strong) AFURLSessionManager * manager;

@property(nonatomic,strong) NSURLSessionTask * task;

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


@implementation AFNetWorkingAdaptor

+(instancetype) create
{
    [CKDownloadPathManager sharedInstance].tmpPathBlock = ^(NSURL * url){
        id<CKDownloadModelProtocol> model = [[CKDownloadManager sharedInstance] getModelByURL:url];
        return model.downloadTempPath;
    };
    return [[AFNetWorkingAdaptor alloc] init];
}


-(void) ck_startDownloadRequestWithURL:(NSURL *) url
{
    NSString * finalPath = nil;
    NSString * tmpPath = nil;
    [[CKDownloadPathManager sharedInstance] getURL:url toPath:&finalPath tempPath:&tmpPath];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    
    void(^completeBlock)(NSError * error) = ^(NSError * error) {
        if(error)
        {
            if(self.failureBlock)
                self.failureBlock(error);
        }
        else
        {
            if(self.completionBlock)
                self.completionBlock();
        }
    };
    
    __block BOOL isReceiveResponse = NO;
    
    NSData * resumeData = [self getLocalResumeDataByURL:url];
    if(resumeData)
    {
        self.task = [self.manager downloadTaskWithResumeData:resumeData progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:finalPath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            completeBlock(error);
        }];
    }
    else
    {
        self.task = [self.manager downloadTaskWithRequest:request progress: nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:finalPath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            completeBlock(error);
        }];
    }
    
    [self.manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        self.ck_downloadBytes = totalBytesWritten;
        self.ck_contentLength = totalBytesExpectedToWrite;
        self.ck_totalContentLength = totalBytesExpectedToWrite + totalBytesWritten;

        if(!isReceiveResponse)
        {
            if(self.headersReceivedBlock)
                self.headersReceivedBlock(nil);
            isReceiveResponse = YES;
        }
        
        if(self.bytesReceivedBlock)
            self.bytesReceivedBlock(bytesWritten,totalBytesExpectedToWrite);
    }];

    NSString * fullTmpPath = [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),[self.task downloadTmpFileName]];
    [[CKDownloadPathManager sharedInstance] setURL:url toPath:nil tempPath: fullTmpPath];
    
    [self.task resume];
}


-(void) ck_startHeadRequestWithURL:(NSURL *) url
{
    self.task = [[AFHTTPSessionManager manager] HEAD:url.absoluteString parameters:nil success:^(NSURLSessionDataTask * task) {
        self.ck_contentLength = task.countOfBytesExpectedToReceive;
        self.ck_totalContentLength = task.countOfBytesExpectedToReceive;
        
        if(self.headersReceivedBlock)
            self.headersReceivedBlock(nil);
        if(self.completionBlock)
            self.completionBlock();
    } failure:^(NSURLSessionDataTask *  task, NSError * _Nonnull error) {
        if(self.failureBlock)
            self.failureBlock(error);
    }];
    [self.task resume];
}


-(void) ck_clearDelegatesAndCancel
{
    [self.task cancel];
}


#pragma mark - Private Method
-(NSData *) getLocalResumeDataByURL:(NSURL *) url
{
    NSString * tmpPath = nil;
    [[CKDownloadPathManager sharedInstance] getURL:url toPath:nil tempPath:&tmpPath];
    if(tmpPath)
    {
        long long bytes = [[CKDownloadPathManager sharedInstance] downloadContentSizeWithURL:url];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        [request addValue:[NSString stringWithFormat:@"bytes=%lld-",bytes] forHTTPHeaderField:@"Range"];
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:request];
        
        NSMutableDictionary * resumeDataDic = [NSMutableDictionary dictionary];
        resumeDataDic[@"NSURLSessionResumeBytesReceived"] = @(bytes);
        resumeDataDic[@"NSURLSessionResumeCurrentRequest"] = data;
        resumeDataDic[@"NSURLSessionResumeInfoTempFileName"] = tmpPath.lastPathComponent;
        resumeDataDic[@"NSURLSessionDownloadURL"] = url.absoluteString;
        
        NSError * error = nil;
        NSData * resumeData = [NSPropertyListSerialization dataFromPropertyList:resumeDataDic format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
        if(error)
        {
            NSLog(@"生成临时文件失败:%@",error);
        }
        return resumeData;
    }
    
    return nil;
}

@end
