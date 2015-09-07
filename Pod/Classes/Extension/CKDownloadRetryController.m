//
//  CKDownloadRetryController.m
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "CKDownloadRetryController.h"
#import "CKDownloadManager+MoveDownAndRetry.h"


@interface CKDownloadRetryController ()

@end


@implementation CKDownloadRetryController

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        self.retryMaxCount = 10;
        _resumCount=0;
    }
    return  self;
}

-(void) makeTaskAutoResum:(id<CKDownloadModelProtocal,CKRetryModelProtocal>) model
{
    if(model.downloadState == kDSWaitDownload || model.downloadState == kDSDownloading)
    {
        if(model.isNeedResumWhenNetWorkReachable==NO)
        {
            model.isNeedResumWhenNetWorkReachable=YES;
            _resumCount ++;
        }
    }
}

-(void) cancelTaskAutoResum:(id<CKDownloadModelProtocal,CKRetryModelProtocal>) model
{
    if(model.isNeedResumWhenNetWorkReachable==YES)
    {
         model.isNeedResumWhenNetWorkReachable=NO;
        _resumCount --;
    }
}

-(BOOL) isAutoResumWithModel:(id<CKDownloadModelProtocal,CKRetryModelProtocal>) model
{
    return model.isNeedResumWhenNetWorkReachable;
}

-(NSInteger) resumCount
{
    return _resumCount;
}

#pragma mark  - retry

-(void) resetRetryCountWithModel:(id<CKDownloadModelProtocal,CKRetryModelProtocal>) model
{
    model.retryCount = 0;
}


-(void) retryWithModel:(id<CKDownloadModelProtocal,CKRetryModelProtocal>) model  passed:(RetryBaseBlock) passedBlock  failed:(RetryBaseBlock) failureBlock
{
    model.retryCount +=1;
    if(model.retryCount > self.retryMaxCount)
    {
        if (failureBlock) {
            failureBlock(model);
        }
        
        [self.downloadManager moveDownAndRetryByURL:URL(model.URLString)];
    }
    else
    {
        if(passedBlock)
            passedBlock(model);
    }
    
    [self resetRetryCountWithModel:(id<CKDownloadModelProtocal,CKRetryModelProtocal>)model];
}

@end
