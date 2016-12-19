//
//  CKDownloadManager+MoveDownAndRetry.m
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "CKDownloadManager+MoveDownAndRetry.h"

@interface CKDownloadManager ()
/**
 *  update model change to database
 *
 *  @param model downlaod task model
 */
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocol>) model;

/**
 *  delete download task
 *
 *  @param url                      task url
 *  @param isNeed                   YES delete file
 *  @param isNeedDeleteDependencies YES delete dependencies task
 *
 *  @return deleted task
 */
-(id<CKDownloadModelProtocol>) deleteWithURL:(NSURL *)url deleteFile:(BOOL) isNeed deleteDependencies:(BOOL) isNeedDeleteDependencies;

/**
 *  start download task
 *
 *  @param url          task url
 *  @param entity       task model
 *  @param prepareBlock if return YES  start , or stop.
 */
-(void) startDownloadWithURL:(NSURL *)url  entity:(id<CKDownloadModelProtocol>)entity prepareBlock:(DownloadPrepareBlock) prepareBlock;

@end

@implementation CKDownloadManager (MoveDownAndRetry)

-(void) moveDownAndRetryByURL:(NSURL *) url
{
    id<CKDownloadModelProtocol>  model=[_downloadingEntityOrdinalDic objectForKey:url];
    
    if(model)
    {
        
       id<CKDownloadModelProtocol,CKRetryModelProtocol> model =(id<CKDownloadModelProtocol,CKRetryModelProtocol>)[self deleteWithURL:url deleteFile:NO deleteDependencies:NO];

        [self startDownloadWithURL:url entity:model prepareBlock:nil];
    }
}

-(id<CKHTTPRequestProtocol>) createRequestOperationWithURL:(NSURL *) url
{
    id<CKHTTPRequestProtocol> operation = [_HTTPRequestClass ck_createDownloadRequestWithURL: url];
    operation.ck_delegate = self;
    operation.downloadManager = self;
    operation.downloadTaskClass = _downloadTaskClass;
    return operation;
}

-(id<CKHTTPRequestQueueProtocol>) createRequestQueue
{
    return [_HTTPRequestQueueClass ck_createQueue];
}

@end
