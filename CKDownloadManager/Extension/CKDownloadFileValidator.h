//
//  CKDwonalodFileValidator.h
//  aisiweb
//
//  Created by mac on 14/12/16.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//
//  Validate Download File . remember to call  pauseCountIncrease method when validate failed.

#import <Foundation/Foundation.h>
#import "CKValidatorModelProtocal.h"
#import "CKDownloadModelProtocal.h"



@class CKDownloadFileValidator,CKDownloadManager;
typedef void(^DownloadFileValidateCompleteBlock)(CKDownloadFileValidator * validator ,id<CKValidatorModelProtocal,CKDownloadModelProtocal> model , BOOL isSucessful);

@interface CKDownloadFileValidator : NSObject

@property(nonatomic,weak) CKDownloadManager * downloadManager;

/**
 *  free disk mininum
 */
@property(nonatomic,assign) long long mininumFreeSpaceBytes;

/**
 *  validate download file size
 *
 *  @model  download task model
 *  @param completeBlock  block called when validate complete
 */
-(void) validateFileSizeWithModel:(id<CKValidatorModelProtocal,CKDownloadModelProtocal>) model completeBlock:(DownloadFileValidateCompleteBlock) completeBlock;

/**
 *  validate download file content
 *
 *  @model  download task model
 *  @param completeBlock block called when validate complete
 */
-(void) validateFileContentWithModel:(id<CKValidatorModelProtocal,CKDownloadModelProtocal>) model completeBlock:(DownloadFileValidateCompleteBlock) completeBlock;


/**
 *  validate whether enougth free disk to download this task
 *
 *  @param model
 */
-(BOOL) validateEnougthFreeSpaceWithModel:(id<CKValidatorModelProtocal,CKDownloadModelProtocal>) model;

@end
