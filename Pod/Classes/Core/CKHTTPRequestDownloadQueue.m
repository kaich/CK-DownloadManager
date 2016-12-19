//
//  CKHTTPRequestDownloadQueue.m
//  Pods
//
//  Created by mac on 16/12/16.
//
//

#import "CKHTTPRequestDownloadQueue.h"

@implementation CKHTTPRequestDownloadQueue

+(instancetype) ck_createQueue
{
    CKHTTPRequestDownloadQueue *queue = [[CKHTTPRequestDownloadQueue alloc] init];
    queue.maxConcurrentOperationCount=3;
    return  queue;
}

-(void) ck_go
{
    [self setSuspended:NO];
}

-(void) ck_addRequest:(CKHTTPRequestOperation *)request
{
    [self addOperation:request];
}

-(void) setCk_maxConcurrentOperationCount:(NSInteger)ck_maxConcurrentOperationCount
{
    self.maxConcurrentOperationCount = ck_maxConcurrentOperationCount;
}

-(NSInteger) ck_maxConcurrentOperationCount
{
    return self.maxConcurrentOperationCount;
}

-(void) ck_setSuspended:(BOOL)isSuspend
{
    [self setSuspended:isSuspend];
}

-(BOOL) ck_isSuspended
{
    return  self.isSuspended;
}

-(NSArray *) ck_operations
{
    return self.operations;
}

@end
