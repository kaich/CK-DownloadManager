//
//  ASINetworkQueue+Download.m
//  chengkai
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "NSOperationQueue+Download.h"

@implementation NSOperationQueue (Download)

+(instancetype) ck_createQueue
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount=3;
    
    return  queue;
}

-(void) ck_addRequest:(id<CKHTTPRequestProtocal>)request
{
    [self addOperation:request];
}

-(void) ck_setSuspended:(BOOL)isSuspend
{
    [self setSuspended:isSuspend];
}

-(void) ck_go
{
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

@end
