//
//  ASIHTTPRequestAdaptor.m
//  Pods
//
//  Created by mac on 16/12/16.
//
//

#import "ASIHTTPRequestAdaptor.h"
#import "ASIHTTPRequest.h"
#import "CKDownloadPathManager.h"

@interface ASIHTTPRequestAdaptor ()

@property(nonatomic,strong) ASIHTTPRequest * request;

@end

@implementation ASIHTTPRequestAdaptor

+(instancetype) create
{
    return [[ASIHTTPRequestAdaptor alloc] init];
}


-(void) ck_clearDelegatesAndCancel
{
    [self.request clearDelegatesAndCancel];
}


- (void) ck_startHeadRequestWithURL:(NSURL *) url
{
    
    ASIHTTPRequest * request=[ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"HEAD"];
    [request setCompletionBlock: self.completionBlock];
    [request setHeadersReceivedBlock:^(NSDictionary *responseHeaders){
       if(self.headersReceivedBlock)
           self.headersReceivedBlock();
    }];
    [request setBytesReceivedBlock: ^(unsigned long long size, unsigned long long total){
        if(self.bytesReceivedBlock)
            self.bytesReceivedBlock();
    }];
    [request setFailedBlock: ^(){
        if(self.failureBlock)
            self.failureBlock();
    }];
    
    self.request = request;
    [request startAsynchronous];
}


- (void) ck_startDownloadRequestWithURL:(NSURL *) url
{
    NSString * toPath=nil;
    NSString * tmpPath=nil;
    [[CKDownloadPathManager sharedInstance] getURL:url toPath:&toPath tempPath:&tmpPath];
    
    
    ASIHTTPRequest * request=[ASIHTTPRequest requestWithURL:url];
    request.downloadDestinationPath=toPath;
    request.temporaryFileDownloadPath=tmpPath;
    request.allowResumeForFileDownloads=YES;
    request.showAccurateProgress=YES;
    request.shouldContinueWhenAppEntersBackground=YES;
    request.numberOfTimesToRetryOnTimeout=INT_MAX;
    
    [request setCompletionBlock: self.completionBlock];
    [request setHeadersReceivedBlock:^(NSDictionary *responseHeaders){
        if(self.headersReceivedBlock)
            self.headersReceivedBlock();
    }];
    [request setBytesReceivedBlock: ^(unsigned long long size, unsigned long long total){
        if(self.bytesReceivedBlock)
            self.bytesReceivedBlock();
    }];
    [request setFailedBlock: ^(){
        if(self.failureBlock)
            self.failureBlock();
    }];
    
    self.request = request;
    [request startAsynchronous];
}

- (long long) ck_downloadBytes
{
    return  self.request.partialDownloadSize + self.request.totalBytesRead;
}

-(long long) ck_contentLength
{
    return self.request.contentLength;
}

-(long long) ck_totalContentLength
{
    return self.request.partialDownloadSize + self.request.contentLength;
}

@end
