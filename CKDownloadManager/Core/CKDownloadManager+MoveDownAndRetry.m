//
//  CKDownloadManager+MoveDownAndRetry.m
//  aisiweb
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import "CKDownloadManager+MoveDownAndRetry.h"

@interface CKDownloadManager ()
/**
 *  update model change to database
 *
 *  @param model downlaod task model
 */
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocal>) model;

/**
 *  retry to download file when header file length is not equal to expect file length
 *
 *  @param url download url
 */
-(void) retryDownloadWhenHeaderErrorOcurWithURL:(NSURL *) url;

/**
 *  delete download task
 *
 *  @param url                      task url
 *  @param isNeed                   YES delete file
 *  @param isNeedDeleteDependencies YES delete dependencies task
 *
 *  @return deleted task
 */
-(id<CKDownloadModelProtocal>) deleteWithURL:(NSURL *)url deleteFile:(BOOL) isNeed deleteDependencies:(BOOL) isNeedDeleteDependencies;

/**
 *  start download task
 *
 *  @param url          task url
 *  @param entity       task model
 *  @param prepareBlock if return YES  start , or stop.
 */
-(void) startDownloadWithURL:(NSURL *)url  entity:(id<CKDownloadModelProtocal>)entity prepareBlock:(DownloadPrepareBlock) prepareBlock;

@end

@implementation CKDownloadManager (MoveDownAndRetry)

-(void) moveDownAndRetryByURL:(NSURL *) url
{
    id<CKDownloadModelProtocal>  model=[_downloadingEntityOrdinalDic objectForKey:url];
    
    if(model)
    {
        
       id<CKDownloadModelProtocal,CKRetryModelProtocal> model =(id<CKDownloadModelProtocal,CKRetryModelProtocal>)[self deleteWithURL:url deleteFile:NO deleteDependencies:NO];
        if(self.retryController)
        {
            [self.retryController resetRetryCountWithModel:(id<CKDownloadModelProtocal,CKRetryModelProtocal>)model];
        }
        
        [self startDownloadWithURL:url entity:model prepareBlock:nil];
    }
}

@end
