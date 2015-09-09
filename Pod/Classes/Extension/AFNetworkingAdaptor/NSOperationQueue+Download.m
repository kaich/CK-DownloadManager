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

-(void) ck_go
{
}
@end
