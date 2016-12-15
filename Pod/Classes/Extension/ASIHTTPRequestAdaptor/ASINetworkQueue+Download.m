//
//  ASINetworkQueue+Download.m
//  chengkai
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "ASINetworkQueue+Download.h"

@implementation ASINetworkQueue (Download)

+(instancetype) ck_createQueue:(BOOL) isHead
{
    ASINetworkQueue *queue = [[ASINetworkQueue alloc] init];
    queue.maxConcurrentOperationCount=3;
    queue.shouldCancelAllRequestsOnFailure=NO;
    [queue setShowAccurateProgress:YES];
    
    return  queue;
}

-(void) ck_go
{
    [self go];
}

-(void) ck_addRequest:(id<CKHTTPRequestProtocol>)request
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
