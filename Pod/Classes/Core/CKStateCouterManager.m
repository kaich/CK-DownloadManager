//
//  CKStateCouterManager.m
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "CKStateCouterManager.h"

@implementation CKStateCouterManager

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        _pauseCount = 0;
    }
    return self;
}


-(void) pauseCountIncrease
{
    @synchronized(self)
    {
        _pauseCount++;
        _isAllDownloading=NO;
    }
    
}


-(void) pauseCountDecrease
{
    @synchronized(self)
    {
        _pauseCount--;
        if(_pauseCount<=0)
        {
            _isAllDownloading=YES;
        }
        
    }
}

-(void) setPauseCount:(NSInteger) count
{
    @synchronized(self)
    {
        _pauseCount = count;
        
        if(_pauseCount<=0)
        {
            _isAllDownloading=YES;
        }
        else
        {
            _isAllDownloading=NO;
        }
    }
    
}

-(BOOL) isAllPausedWithDownloadTaskCount:(NSInteger) taskCount
{
    if(taskCount==_pauseCount)
        return YES;
    else
        return NO;
}


@end
