//
//  ASINetworkQueue+Download.m
//  aisiweb
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import "ASINetworkQueue+Download.h"

@implementation ASINetworkQueue (Download)

+(instancetype) ck_createQueue
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
@end
