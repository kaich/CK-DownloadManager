//
//  CKDownloadSpeedAverageQueue.m
//  aisiweb
//
//  Created by Mac on 14-7-9.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadSpeedAverageQueue.h"

#ifndef  B_TO_KB
#define  B_TO_KB(_x_) (_x_)/1024.f
#endif

@interface CKDownloadSpeedAverageQueue ()
@property(nonatomic,strong) NSMutableArray * downloadSizeQueue;
@property(nonatomic,strong) NSMutableArray * downloadTimeQueue;

@property(nonatomic,assign) long long  previousDataSize;
@end

@implementation CKDownloadSpeedAverageQueue
@dynamic speed;

-(id) init
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.downloadSizeQueue=[NSMutableArray array];
    self.downloadTimeQueue=[NSMutableArray array];
    
    self.intervalLength=3;
    self.previousDataSize=0;
    
    return self;

}



-(CKDownloadSpeedAverageQueue *) pushCurrentDownloadSize:(long long)value
{
    if(self.downloadSizeQueue.count >=self.intervalLength)
    {
        [self.downloadSizeQueue removeObjectAtIndex:0];
    }
    
    
    [self.downloadSizeQueue addObject:[NSNumber numberWithLongLong:value]];
   
    
    return self;
}


-(CKDownloadSpeedAverageQueue *) pushCurrentDownloadTime:(NSTimeInterval)value
{
    if(self.downloadTimeQueue.count >=self.intervalLength)
    {
        [self.downloadTimeQueue removeObjectAtIndex:0];
    }
    
    [self.downloadTimeQueue addObject:[NSNumber numberWithDouble:value]];
    
    return  self;
}


-(void) reset
{
    
    self.previousDataSize=[[self.downloadSizeQueue lastObject] longLongValue] ;
    
    [self.downloadSizeQueue removeAllObjects];
    [self.downloadTimeQueue removeAllObjects];
}

#pragma mark -  dynamic method
-(CGFloat) speed
{
    long long downloadSizeInterval= 0;
    CGFloat downloadTimeInterval= self.downloadTimeQueue.count ==0 ? 0 : [[self.downloadTimeQueue lastObject] floatValue] -[self.downloadTimeQueue[0] floatValue];
 
    
    if(self.downloadSizeQueue.count==0)
    {
        downloadSizeInterval=0;
    }
    else if(self.downloadSizeQueue.count==1)
    {
        downloadSizeInterval=[[self.downloadSizeQueue lastObject] longLongValue] -  self.previousDataSize;
    }
    else
    {
        downloadSizeInterval=[[self.downloadSizeQueue lastObject] longLongValue]-[self.downloadSizeQueue[0] longLongValue];
    }
    
    
    CGFloat finalSpeed=0;
    
    if(downloadSizeInterval > 0)
    {
        finalSpeed = downloadTimeInterval ==0 ? downloadSizeInterval : ((CGFloat)downloadSizeInterval/(CGFloat)downloadTimeInterval);
    }

    return  finalSpeed;
}



@end
